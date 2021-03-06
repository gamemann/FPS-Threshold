/**
 * Called when the server is caught going under the average FPS threshold.
 *
 * @param avgfps The average FPS detected.
 * @param curfps The current FPS  detected.
 * 
 * @return void
 */
forward void OnDectect(int avgfps, int curFPS);

/**
 * Called when the timer is up after OnDetect().
 * 
 * @return void
 */
forward void OnDectectEnd();