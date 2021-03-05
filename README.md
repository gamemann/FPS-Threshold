# Noblock On "Lag"
## Description
A simple SourceMod plugin that calculates the server FPS every second and when it goes under a certain threshold based off of the average FPS in *x* seconds, it will force noblock on all players for *y* seconds.

I've made this in hopes to mitigate damage on [Elite Hunterz](https://forum.elite-hunterz.com/)'s Zombie Hunting server from poor performance issues when multiple players are stuck inside of each other.

## ConVars
* **sm_nol_avgtime** - Calculate the average FPS for *x* seconds (*x* representing the CVar value).
* **sm_nol_theshold** - If the average FPS goes below this average, force noblock on all players.
* **sm_nol_time** - How long to enforce noblock on all players for before enforcing block again.
* **sm_nol_notify** - Whether to print a message to everybody when poor performance is detected.
* **sm_nol_debug** - Whether to insert debug messages into the console.

## Forwards
This plugins comes with two forwards to allow other plugins to interact. The forwards may be found below.

```C
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
```

## Credits
* [Christian Deacon](https://github.com/gamemann)