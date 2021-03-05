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

int collision;

int lastfps = 67;
int lasttick = 0;
int index = 0;
int fpsarr[MAXSTORE];

bool insequence = false;
bool uptospeed = false;

ConVar cvMaxStore = null;
ConVar cvThreshold = null;
ConVar cvNoblockTime = null;
ConVar cvNotify = null;
ConVar cvDebug = null;

GlobalForward g_fwdOnDetect;
GlobalForward g_fwdOnDetectEnd;

public void OnPluginStart()
{
    cvMaxStore = CreateConVar("sm_nol_avgtime", "6", "How long ago should we calculate the FPS average from");
    cvThreshold = CreateConVar("sm_nol_theshold", "3", "If the average server FPS goes below this, force noblock on all plugins.");
    cvNoblockTime = CreateConVar("sm_nol_time", "5", "How long to force noblock on all players for.");
    cvNotify = CreateConVar("sm_nol_notify", "1", "Print to chat all when the server is lagging.");
    cvDebug = CreateConVar("sm_nol_debug", "0", "Debug calculations or not.");

    g_fwdOnDetect = CreateGlobalForward("OnDetect", ET_Event);
    g_fwdOnDetectEnd = CreateGlobalForward("OnDetectEnd", ET_Event);

    RegAdminCmd("sm_fps", Command_FPS, ADMFLAG_SLAY);

    collision = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");

    if (collision == -1)
    {
        SetFailState("Could not find offset for => CBaseEntity::m_CollisionGroup. Plugin failed.");
    }

    CreateTimer(1.0, Timer_FPS, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

    AutoExecConfig(true, "plugin.nol");
}

public Action Command_FPS(int client, int args)
{
    ReplyToCommand(client, "Latest FPS => %d", lastfps);

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
            SetEntData(i, collision, 5, 4, true);
        }
        else
        {
            SetEntData(i, collision, 2, 4, true);
        }
    }
}

public Action Timer_Block(Handle timer)
{
    ForceCollision(true);

    // Call On Detection End forward.
    Call_StartForward(g_fwdOnDetectEnd);
    Call_Finish();

    insequence = false;
}

public Action Timer_FPS(Handle timer)
{
    int now = GetGameTickCount();
    int fps = now - lasttick;
    lasttick = now;
    lastfps = fps;

    // Reset index if it exceeds cvMaxStore value.
    if (index > (cvMaxStore.IntValue - 1))
    {
        uptospeed = true;
        index = 0;
    }

    fpsarr[index] = fps;
    
    if (uptospeed && !insequence)
    {
        // Calculate average FPS.
        int avg;
        int j = index;

        for (int i = 0; i < cvMaxStore.IntValue; i++)
        {
            if (j < 0)
            {
                j = (cvMaxStore.IntValue - 1);
            }

            avg += fpsarr[j];

            if (cvDebug.BoolValue)
            {
                PrintToServer("Avg => %d. J => %d", avg, j);
            }

            j--;
        }

        if (cvDebug.BoolValue)
        {
            PrintToServer("Checking %d/%d = %d > %d ", avg, cvMaxStore.IntValue, (avg / cvMaxStore.IntValue), cvThreshold.IntValue);
        }

        avg /= cvMaxStore.IntValue;

        if (avg < cvThreshold.IntValue)
        {
            // Call On Detection forward.
            Call_StartForward(g_fwdOnDetect);
            Call_Finish();

            insequence = true;

            if (cvNotify.BoolValue)
            {
                PrintToChatAll("[NOL] Detected poor server performance. Enforcing noblock on all players.");
            }

            if (cvDebug.BoolValue)
            {
                PrintToServer("[NOL] Average server FPS went under threshold (%d > %d) (Index => %d => %d)", cvThreshold.IntValue, avg, index, fpsarr[index]);
            }

            ForceCollision(false);

            CreateTimer(cvNoblockTime.FloatValue, Timer_Block, _, TIMER_FLAG_NO_MAPCHANGE);
        }
    }

    index++;

    return Plugin_Continue;
}