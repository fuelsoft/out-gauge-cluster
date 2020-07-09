
# OutGaugeCluster
A nice set of virtual displays for your virtual car.

## How do I use it?

Open BeamNG.drive and start a map (free mode is a good choice as the game won't try to make you complete objectives). Hit ESC, go to settings and go to the "other" tab. *(You may need to enable advanced settings to see some of these options)*. At the bottom, enable OutGauge support and enter your target IP and port.

 - The default port is 5555
 - If you're running the program on the same machine, enter 127.0.0.1 as the IP
 - If you're running the program on a different machine, enter that machine's local IP
 - If you're trying to run it over the internet, good luck and have fun

## What is OutGauge?

OutGauge is a vehicle-simulator-focused packet specification that was developed for the game [Live For Speed](https://www.lfs.net/). The [BeamNG](https://beamng.com/) team has implemented it in their game as well, and that is what this project targets. The data is the same, and this virtual dash should work with LFS as well, but it remains untested and unsupported officially.

## What is Processing? All I have is a .pde file and I can't run that

A Java-based, graphically-focused program/language. You will need Java to run it and any programs you create.
See [here](https://processing.org/) for details and to download the IDE needed to write and build programs.

### I don't need to write anything, I just want to run this!

Alright, great. Open Processing and open the .pde file. 

This project requires ControlP5:

 1. Sketch > Import Library > Add Library
 2. Type *ControlP5* in the search box, select ControlP5 and click *install*.
 3. Once it's done installing, you can close the package manager window.

You now have two options:

 1. Run the program once, using the play button at the top of the editor.
 2. Create an executable.
	 - File > Export Application (CTRL + SHIFT + E)
	 - Choose any platform you want to export to. Note that OS X output is only available on a Mac.
	 - Embed Java if you expect that your target machine will not have it installed.

## General

### What are all these gauges?
<img src="/assets/cluster.png">

 1. Tachometer
 2. Speedometer
 3. Temperature - Coolant
 4. Temperature - Oil
 5. Transmission Gear
 6. Fuel Remaining
 7. Fuel Consumption
 8. Boost Pressure
 9. Parking Brake/Emergency Brake/Hand Brake
 10. Anti-lock Brake Activity
 11. Traction/Stability Control Activity
 12. High-beam
 13. Turn Signals

----------

### Could I get some extra details about those gauges?
#### Sure.
 1. A *tachometer* displays engine RPM. The large marks denote 1000 RPM increments and the small marks are every 100 RPM.
 2. The *speedometer* displays vehicle wheel speed. It is presented in KM/H. The large marks denote 10 KM/H increments and the small marks are every 1 KM/H.
 3. The *coolant temperature* is the temperature of the engine's coolant in degrees Celsius.
 4. The *oil temperature* is the temperature of the engine's oil in degrees Celsius.
 5. The *gear* is the transmission's current gear. If the gear is higher than F6 or lower than R1, this will display the highest or lowest value possible respectively.
 6. The *fuel remaining* is the percentage of fuel remaining in the tank.
 7. The *fuel consumption* is a somewhat arbitrary but consistent use metric. It's based on the rate of depletion of fuel. It does not account for tank size, speed, engine load or anything else.
 8. The *boost pressure* is the air pressure coming out of the turbo, if one is equipped. The default 9 o'clock position is 0 PSI, 12 o'clock is 14.5 PSI (1 BAR), 3 o'clock is 29 PSI (2 BAR), etc. This can be negative at low RPMs as the turbo *actually obstructs airflow*, which is accounted for at the same rate as positive pressure (0.322 PSI/DEGREE).
 9. The *parking brake* or *emergency brake* or *hand brake* is the secondary brake that can lock up most vehicle's rear wheels. This light indicates braking force is being applied using this brake.
 10. The *anti-lock braking system* will automatically feather the brakes under extreme conditions such as low grip braking or very hard braking to avoid wheel lockup. This light indicates the system is taking action to avoid lockup.
 11. The *traction control* or *stability control* systems use a combination of power reduction and individual-wheel-braking to try to keep a vehicle facing forward and under control. This light indicates one or more system is currently taking action to keep the vehicle under control.
 12. *High-beams* are bright headlights that point higher than standard headlights to illuminate a greater area ahead. Typically used on unlit roads, it's important that they have a dashboard warning as they are prone to blinding oncoming traffic.
 13. *Turn signals* indicate intention to move laterally (turning, changing lane, parking, etc.). These will also both blink together if you have your hazard lights on.

## Questions:

----------

### The tachometer and speedometer aren't set up properly and go off the top end/will never reach the top end.

This is a problem both with the implementation of OutGauge in BeamNG.drive and with OutGauge itself. Among other issues, the game does not properly report vehicle IDs, so the program has no way of knowing what vehicle is being used. For it's part, OutGauge also does not provide a way to express engine/vehicle details like maximum values. Because of this, the program can only know some things, like default details about fuel and temperatures. Anything else must be manually adjusted, including max RPM and max speed.

Good news though! There's now an easy way to change these values without rebuilding the program every time!

Upon launching the program, the values will be the same as previously. However, at the bottom of the display there are now sliders that can be used to adjust these values to match the specifics of your car. Engine RPM is 1:100 scale, so to set a maximum RPM of 7000, set the slider to 70.00. Speed is 1:1 and works the same way. Boost is disabled by default (by setting it to 0 the gauge will hide) but simply slide the slider to match your wastegate pressure and the gauge will scale. For fuel, set the value to match fuel *capacity* not fuel *volume*.

All sliders are set to truncate values after the decimal. There does not seem to be a way to force values to be integers in ControlP5; if you know of such a thing, please let me know.

The defaults are for the base model D15.

----------

### The gauges aren't working!

I can almost guarantee that either OutGauge is disabled, or the wrong IP/port is set. Please double-check that you have set them right. See "**How do I use it?**" above for more info.

Also check that you don't have a firewall blocking incoming connections.

----------

### The gauges lag/stutter, how can I fix this?

If you're running the program on a different computer, particularly over WiFi, this is not unusual. If you can connect with a wired connection, you will almost certainly have a better experience. This happens because OutGauge is a UDP-based system and packets do sometimes get lost or delayed. **I can't fix this.**

*Don't forget to update the IP in the game if you change connections!*

----------

### My car has more than 8 total gears, but I still only see 8!

This is a limitation of OutGauge, it uses a single byte to represent gear, with only one bit set at a time. Because it has only 8 bits, only 8 gears can be represented, anything higher than F6 or lower than R1 will be represented by the highest/lowest light, as appropriate. **Again, I can't fix this.**

----------

## Other notes:
 
### I've discovered the lua file responsible for OutGauge support in BeamNG.

BeamNG.drive > lua > vehicle > extensions > outgauge.lua

It doesn't help me much now that I've done most of the work understanding the format but it could be useful in the future - there are a number of comments and TODOs listed in there.
Many of the fields that I suspected were not working properly are now confirmed to simply not be implemented - *time*, *car*, *oil pressure* and others are simply set to 0.
