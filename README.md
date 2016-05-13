# LA
Launch Alpha - A KOS script for (not so) intelligent launches in KSP.    
Its currently aimed at use with Real Solar System where launches require more precise planning and lateral speed.


# Install
This requires the KOS mod for KSP.  The files go into your @Kerbal Space Program/Ships/Scripts folder.


# Use
This does not work well in its current state. To use this you will need to modify a few lines:

LA_CraftSettings.ks - This file contains functions spesific to your ship. 
It is currently designed for 2 stage operations with SRBs. The first Staging has no ullage activation
as it is assumes to be activated with the SRB is released.
The second stage has an example for RCS based Ullage but also works well if you have SRB Ullage 
rockets. Such rockets would just need to stage with the decoupler.

To use it as is:    
Tag an SRB with the tag BoostA    
Tag your(a) Main stage engine with tag BoostB    
Tag your Second stage engine with tag BoostC    

LA_Functions.ks - This contains the current logic under the "FirstStageLogic" section.

This is the current line of focus:    
SET lspd to Constant:DegToRad * (arctan(ALTITUDE/30000))*78203.

This uses a formula tested here to find a math function that creates a reasonable ascent trajctory.

-->>>NOTE<<<--    
The graphs below is Altitide Vs Apoapsis, it is NOT Altitide vs Distance traveled.    
-->>>NOTE<<<--

The X axis is the target APOAPSIS and the Y is the current altitiude. 
The main goal for this is the First stage, as the Second stage will move to controlling vertical
ascent and controling thrust based on TWR(It does not do this now)    
https://www.desmos.com/calculator/mbyzmgnxhw

# Craft Design
The design of your launcher can greatly impact the performance of the script. Testing has occured on a 3 stage rocket with the following attributes:
2 Stage rocket with SRB providing aditional TWR.
First Staging fires liquid engines, This is due to RealFuels and other mods adding a spoolup period
Second Staging Fires SRBs and releases clamps
Third Staging fires releasing SRBs
Fourth Staging fires releasing first stage and firing second state ullage motors
Fith Staging fires second stage

The rockets have the following design:
Total DeltaV: 10,400m/s
First Stage W. SRB: ~2,300 m/s, TWR: 1.5 (4.3)
First Stage On SRB release: ~4,000 m/s, TWR: 1.2 (3.3)
Second Stage: ~4,000 m/s: TWR: 2.3 (6.7)

Design Considerations: First Stage final TWR should not be high, This is due to RealFuels and engine Performance as testing had "Vapor in Fuel Line" issues due to the thrust change.
First and second stages need Roll or Gibal control and a lot of it. The rocket may be forced to extreme turn angles in lower atphosphere so Winglets on the SRBs or first stage may be required.

# Running
Running is simple. Open a terminal and run:    
>switch to 0.    
>run install.    

This copies the files to the local storage. You will need an upgraded storage unit as the program does not fit in the default 5000

It will confirm it is installed and you can run the following to initate the launch
>run la.

# TODO
 * Update first stage logic to do a proper gravity turn and follow atmopheric prograge as close as possible, ajusting high or low off if there is too much or not enough thrust. This will reduce steering loss greatly.     
 * Update Second stage to use TWR and fancy math to determine best pitch setting. This will be intended so it controlls its vertical acceleration and idealy cancel that out.
