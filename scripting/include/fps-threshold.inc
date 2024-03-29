/**
 * Called when the server is caught going under the average FPS threshold.
 *
 * @param avgfps The average FPS detected.
 * @param curfps The current FPS detected.
 * 
 * @return void
 */
forward void FPSTH_OnDetect(float avgfps, int fps);