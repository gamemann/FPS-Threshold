/**
 * Called when the server is caught going under the average FPS threshold.
 * 
 * @return void
 */
forward void OnDectect();

/**
 * Called when the timer is up after OnDetect().
 * 
 * @return void
 */
forward void OnDectectEnd();