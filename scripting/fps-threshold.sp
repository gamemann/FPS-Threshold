#include <sourcemod>
#include <fps-threshold>

#define MAXSTORE 256

public Plugin myinfo =
{
    name = "FPS Threshold",
    author = "Roy (Christian Deacon)",
    description = "A plugin that offers forwards for other plugins after average FPS goes under a certain threshold.",
    version = "1.0.0",
    url = "https://github.com/gamemann"
};

int g_lastfps = 67;
int g_lasttick = 0;
int g_index = 0;
int g_fpsarr[MAXSTORE];

bool g_uptospeed = false;

ConVar g_cvMaxStore = null;
ConVar g_cvThreshold = null;

GlobalForward g_fwdOnDetect;

public void OnPluginStart()
{
    g_cvMaxStore = CreateConVar("sm_fpsth_avgtime", "6", "How long ago should we calculate the FPS average from");
    g_cvThreshold = CreateConVar("sm_fpsth_threshold", "3", "If the average server FPS goes below this, start FPSTH_OnDetect() forward for all associated plugins.");

    g_fwdOnDetect = CreateGlobalForward("FPSTH_OnDetect", ET_Event, Param_Cell, Param_Cell);

    RegAdminCmd("sm_fps", Command_FPS, ADMFLAG_SLAY);

    CreateTimer(1.0, Timer_FPS, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);

    AutoExecConfig(true, "plugin.fpsth");
}

public Action Command_FPS(int client, int args)
{
    ReplyToCommand(client, "Latest FPS => %d", g_lastfps);

    return Plugin_Handled;
}

public Action Timer_FPS(Handle timer)
{
    int now = GetGameTickCount();
    int fps = now - g_lasttick;
    g_lasttick = now;
    g_lastfps = fps;

    // Reset g_indexlasttick if it exceeds g_cvMaxStore value.
    if (g_index > (g_cvMaxStore.IntValue - 1))
    {
        g_uptospeed = true;
        g_index = 0;
    }

    g_fpsarr[g_index] = fps;
    
    if (g_uptospeed)
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

            j--;
        }

        avg /= g_cvMaxStore.IntValue;

        if (avg < g_cvThreshold.IntValue)
        {
            // Call On Detection forward.
            Call_StartForward(g_fwdOnDetect);
            Call_PushCell(avg);
            Call_PushCell(fps);
            Call_Finish();
        }
    }

    g_index++;

    return Plugin_Continue;
}