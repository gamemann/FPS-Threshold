#include <sourcemod>
#include <noblock-on-lag>

#define MAXSTORE 256

public Plugin myinfo =
{
    name = "Noblock On Lag",
    author = "Roy (Christian Deacon)",
    description = "Forces noblock on players when server FPS averages between a certain threshold.",
    version = "1.0.0",
    url = "https://github.com/gamemann"
};

int g_collisionoff;

int g_lastfps = 67;
int g_lasttick = 0;
int g_index = 0;
int g_fpsarr[MAXSTORE];

bool g_insequence = false;
bool g_uptospeed = false;

ConVar g_cvMaxStore = null;
ConVar g_cvThreshold = null;
ConVar g_cvNoblockTime = null;
ConVar g_cvNotify = null;
ConVar g_cvDebug = null;

GlobalForward g_fwdOnDetect;
GlobalForward g_fwdOnDetectEnd;

public void OnPluginStart()
{
    g_cvMaxStore = CreateConVar("sm_nol_avgtime", "6", "How long ago should we calculate the FPS average from");
    g_cvThreshold = CreateConVar("sm_nol_theshold", "3", "If the average server FPS goes below this, force noblock on all plugins.");
    g_cvNoblockTime = CreateConVar("sm_nol_time", "5", "How long to force noblock on all players for.");
    g_cvNotify = CreateConVar("sm_nol_notify", "1", "Print to chat all when the server is lagging.");
    g_cvDebug = CreateConVar("sm_nol_debug", "0", "Debug calculations or not.");

    g_fwdOnDetect = CreateGlobalForward("OnDetect", ET_Event, Param_Cell);
    g_fwdOnDetectEnd = CreateGlobalForward("OnDetectEnd", ET_Event);

    RegAdminCmd("sm_fps", Command_FPS, ADMFLAG_SLAY);

    g_collisionoff = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

    if (g_collisionoff == -1)
    {
        SetFailState("Could not find offset for => CBaseEntity::m_CollisionGroup. Plugin failed.");
    }

    CreateTimer(1.0, Timer_FPS, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

    AutoExecConfig(true, "plugin.nol");
}

public Action Command_FPS(int client, int args)
{
    ReplyToCommand(client, "Latest FPS => %d", g_lastfps);

    return Plugin_Handled;
}

public void ForceCollision(bool block)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i) || !IsValidEntity(i))
        {
            continue;
        }

        if (block)
        {
            SetEntData(i, g_collisionoff, 5, 4, true);
        }
        else
        {
            SetEntData(i, g_collisionoff, 2, 4, true);
        }
    }
}

public Action Timer_Block(Handle timer)
{
    ForceCollision(true);

    // Call On Detection End forward.
    Call_StartForward(g_fwdOnDetectEnd);
    Call_Finish();

    g_insequence = false;
}

public Action Timer_FPS(Handle timer)
{
    int now = GetGameTickCount();
    int fps = now - g_lasttick;
    g_lasttick = now;
    g_lastfps = fps;

    // Reset g_lasttick if it exceeds g_cvMaxStore value.
    if (g_lasttick > (g_cvMaxStore.IntValue - 1))
    {
        g_uptospeed = true;
        g_index = 0;
    }

    g_fpsarr[g_index] = fps;
    
    if (g_uptospeed && !g_insequence)
    {
        // Calculate average FPS.
        int avg;
        int j = g_index;

        for (int i = 0; i < g_cvMaxStore.IntValue; i++)
        {
            if (j < 0)
            {
                j = (g_cvMaxStore.IntValue - 1);
            }

            avg += g_fpsarr[j];

            if (g_cvDebug.BoolValue)
            {
                PrintToServer("Avg => %d. J => %d", avg, j);
            }

            j--;
        }

        if (g_cvDebug.BoolValue)
        {
            PrintToServer("Checking %d/%d = %d > %d ", avg, g_cvMaxStore.IntValue, (avg / g_cvMaxStore.IntValue), g_cvThreshold.IntValue);
        }

        avg /= g_cvMaxStore.IntValue;

        if (avg < g_cvThreshold.IntValue)
        {
            // Call On Detection forward.
            Call_StartForward(g_fwdOnDetect);
            Call_PushCell(avg);
            Call_Finish();

            g_insequence = true;

            if (g_cvNotify.BoolValue)
            {
                PrintToChatAll("[NOL] Detected poor server performance. Enforcing noblock on all players.");
            }

            if (g_cvDebug.BoolValue)
            {
                PrintToServer("[NOL] Average server FPS went under threshold (%d > %d) (g_lasttick => %d => %d)", g_cvThreshold.IntValue, avg, g_lasttick, g_fpsarr[g_lasttick]);
            }

            ForceCollision(false);

            CreateTimer(g_cvNoblockTime.FloatValue, Timer_Block, _, TIMER_FLAG_NO_MAPCHANGE);
        }
    }

    g_index++;

    return Plugin_Continue;
}