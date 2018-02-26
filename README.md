
# OutGaugeCluster
A nice set of virtual displays for your virtual car.

## How do I use it?

Open BeamNG.drive and start a map (free mode is a good choice as the game won't try to make you complete objectives). Hit ESC, go to settings and go to the "other" tab. *(You may need to enable advanced settings to see some of these options)*. At the bottom, enable OutGauge support and enter your target IP and port.

 - The default port is 5555
 - If you're running the program on the same machine, enter 127.0.0.1 as the IP
 - If you're running the program on a different machine, enter that machine's local IP
 - If you're trying to run it over the internet, good luck and have fun

## What is OutGauge?

OutGauge is a vehicle-simulator-focused protocol that was developed for the game [Live For Speed](https://www.lfs.net/). The [BeamNG](https://beamng.com/) team has implemented it in their game as well, and that is what this project targets. The protocol is the same, and this virtual dash should work with LFS as well, but it remains untested and unsupported officially.

## What is Processing? All I have is a .pde file and I can't run that

A Java-based, visual-focused program/language. You will need Java to run it and any programs you create.
See [here](https://processing.org/) for details and to download the IDE needed to write and build programs.

### I don't need to write anything, I just want to run this!

Alright, great. Open Processing and open the .pde file. You now have two options:

 1. Run the program once, using the play button at the top of the editor.
 2. Create an executable. (This is not recommended for this particular project as RPM and speed numbers are hard-coded and cannot be changed after building)
	 - File > Export Application (CTRL + SHIFT + E)
	 - Choose any platform you want to export to. Note that OS X output is only available on a Mac.
	 - Embed Java if you expect that your target machine will not have it installed

## General

### What are all these gauges?
![The cluster](https://i.imgur.com/AuxGAij.png)

 1. Tachometer - Tracks engine RPM
 2. Speedometer - Vehicle speed
 3. Engine (coolant) temperature
 4. Engine (oil) temperature
 5. Transmission gear - Green is neutral, below is reverse, above is forward
 6. Fuel - Bar will drain with driving
 7. [Unmarked] Turn signals

----------

### The tachometer and speedometer aren't set up properly and go off the top end/will never reach the top end.

This is a problem with the half-assed implementation of OutGauge in BeamNG.drive. Among other issues, the game does not properly report vehicle IDs, so the program has no way of knowing what vehicle is being used. Because of this, it can only know some things, like default details about fuel and temperatures. Anything else must be hard-coded, including max RPM and max speed. 

These are located near the top of the file and are very easy to change:

    [27] final int MAX_RPM = 5800;
    [28] final int MAX_SPEED = 190; //in km/h

The defaults are for the base model D15.

*Devs: Please fix this. It would let me add a single file with a list of known cars that would allow the program to be built and not require changing hardcoded values.*

----------

### The gauges aren't working!

I can almost guarantee that either OutGauge is disabled, or the wrong IP/port is set. Please double-check that you have set them right. See "**How do I use it?**" above for more info.

----------

### The gauges lag/stutter, how can I fix this?

If you're running the program on a different computer, particularly over WiFi, this is not unusual. If you can connect with a wired connection, you will almost certainly have a better experience. 
*Don't forget to update the IP in the game if you change connections!*

----------

### My car has more than 8 total gears, but I still only see 8!

This is a limitation of OutGauge, it uses a single byte to represent gear, with only one 1 at a time. Because it has only 8 bits, only 8 gears can be represented, anything higher than F6 or lower than R1 will be represented by the highest/lowest light, as appropriate. **I can't fix this.**
