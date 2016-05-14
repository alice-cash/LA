# LA
Launch Alpha - A KOS script for (not so) intelligent launches in KSP.    
Its currently aimed at use with Real Solar System where launches require more precise planning and lateral speed.


# Install
This requires the KOS mod for KSP.  The files go into your @Kerbal Space Program/Ships/Scripts folder.


# Use
To use this you will need to modify a few lines and ensure your rocket follows some guyidelines.

LA_CraftSettings.ks - This file contains functions spesific to your ship. 
It is currently designed for 3 stage rocket with SRBs. The first Staging has no ullage activation
as it is assumes to be activated before the SRB is released.
The second stage has an example for RCS based Ullage but also works well if you have SRB Ullage 
rockets. Ullage  rockets would need to stage with the decoupler.

To use it as is:    
Tag an SRB with the tag StageA    
Tag your(a) Main stage engine with tag StageB    
Tag your Second stage engine with tag StageC    

There are some aditional launch paramaters in LA.ks you can modify.

To automatically install LA, use the Boot option to select "Boot_LA".

# Craft Design
The design of your launcher can greatly impact the performance of the script. Testing has occured on a 3 stage rocket with the following attributes:
2 Stage rocket with SRB providing aditional TWR.
First Staging fires liquid engines first, This is due to RealFuels and other mods adding a spoolup period.     
Second Staging Fires SRBs and releases clamps     
Third Staging fires releasing SRBs     
Fourth Staging fires releasing first stage and firing second state ullage motors(If applicable)     
Fith Staging fires second stage     

The rockets I have tested have the following design:    
Total DeltaV: 10,400m/s    
First Stage W. SRB: ~2,300 m/s, TWR: 1.5 (4.3)    
First Stage On SRB release: ~4,000 m/s, TWR: 1.2 (3.3)    
Second Stage: ~4,000 m/s: TWR: 2.3 (6.7)    

Design Considerations: First Stage final TWR should not be high, This is due to RealFuels and engine Performance as testing has had "Vapor in Fuel Line" issues due to the thrust change.
First and second stages need strong Roll or Gibal control. The rocket may be forced to extreme turn angles in lower atphosphere so Winglets on the SRBs or first stage may be required.

# Running
Running is simple. If not using the boot scriot, open a terminal and run:    
>switch to 0.    
>run boot_LA.    

This copies the files to the local storage. You will need a storage unit with at least 20000 storage.

The boot script will confirm it is installed and you can run the following to initate the launch
>run la.

# TODO
 * ~~Update first stage logic to do a proper gravity turn and follow atmopheric prograge as close as possible, ajusting high or low off if there is too much or not enough thrust. This will reduce steering loss greatly.~~ Done
 * ~~Update Second stage to use TWR and fancy math to determine best pitch setting. This will be intended so it controlls its vertical acceleration and idealy cancel that out.~~ Done
 * Further refine LA_Function's First and Second stage functions to better handle uknowns.
