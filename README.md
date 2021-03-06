# FPS Threshold
## Description
A simple SourceMod plugin that calculates the server FPS every second and when it goes under a certain threshold based off of the average FPS in *x* seconds, offers a forward on detection,

I've made this in hopes to mitigate damage on [Elite Hunterz](https://forum.elite-hunterz.com/)'s Zombie Hunting server from poor performance issues when multiple players are stuck inside of each other.

## ConVars
* **sm_fpsth_avgtime** - Calculate the average FPS for *x* seconds (*x* representing the CVar value).
* **sm_fpsth_threshold** - If the average FPS goes below this average, call `OnDetect()` forward.

## Forwards
This plugin comes with one forward to allow other plugins to interact. The forward may be found below.

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
```

## Useful Plugins
* [Force Noblock](https://github.com/gamemann/FPS-Threshold-Noblock) - Forces Noblock on all players when average FPS goes under threshold.

## Credits
* [Christian Deacon](https://github.com/gamemann)