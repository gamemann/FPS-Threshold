# Noblock On "Lag"
## Description
A simple SourceMod plugin that calculates the server FPS every second and when it goes under a certain threshold based off of the average FPS in *x* seconds, it will force noblock on all players for *y* seconds.

I've made this in hopes to mitigate damage on [Elite Hunterz](https://forum.elite-hunterz.com/)'s Zombie Hunting server from poor performance issues when multiple players are stuck inside of each other.

## ConVars
* **sm_fpsth_avgtime** - Calculate the average FPS for *x* seconds (*x* representing the CVar value).
* **sm_nol_theshhold** - If the average FPS goes below this average, force noblock on all players.

## Forwards
This plugin comes with two forwards to allow other plugins to interact. The forwards may be found below.

```C
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
```

## Useful Plugins
* [Force Noblock](https://github.com/gamemann/FPS-Threshold-Noblock) - Forces Noblock on all players when average FPS goes under threshold.

## Credits
* [Christian Deacon](https://github.com/gamemann)