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

float g_lastfps = 67.00;
int g_lasttick = 0;
int g_index = 0;
float g_fpsarr[MAXSTORE];
int g_framecount = 0;

float last_time = 0.0;

bool g_uptospeed = false;

ConVar g_cvMaxStore = null;
ConVar g_cvThreshold = null;

GlobalForward g_fwdOnDetect;

public void OnPluginStart()
{
    g_cvMaxStore = CreateConVar("sm_fpsth_avgtime", "6", "How long ago should we calculate the FPS average from");
    g_cvThreshold = CreateConVar("sm_fpsth_threshold", "3", "If the average server FPS goes below this, start FPSTH_OnDetect() forward for all associated plugins.");

    g_fwdOnDetect = CreateGlobalForward("FPSTH_OnDetect", ET_Event, Param_Float, Param_Cell);

    RegAdminCmd("sm_fps", Command_FPS, ADMFLAG_SLAY);

    AutoExecConfig(true, "plugin.fpsth");
}

public Action Command_FPS(int client, int args)
{
    ReplyToCommand(client, "Latest FPS => %.6f", g_lastfps);

    return Plugin_Handled;
}

public void OnGameFrame()
{
    // Always increase frame count.
    g_framecount++;

    // Get engine time and compare against last time.
    float current_time = GetEngineTime();
    float time = current_time - last_time;

    // Check to see if we exceed a second.
    if (time >= 1)
    {
        last_time = current_time;

        float fps = float(g_framecount);
        g_lastfps = fps;

        // Reset frame count to 0.
        g_framecount = 0;

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
            float avg;
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

            avg /= g_cvMaxStore.FloatValue;

            if (avg <= 0)
            {
                return;
            }

            if (avg < g_cvThreshold.FloatValue)
            {
                // Call On Detection forward.
                Call_StartForward(g_fwdOnDetect);
                Call_PushFloat(avg);
                Call_PushCell(fps);
                Call_Finish();
            }
        }

        // Increase index.
        g_index++;
    }
}