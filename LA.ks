//(L)aunch (A)lpha V (0).1

//Initilize Libraries
run LA_Functions.
run LA_CraftSettings.

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.
Print lName + " " + lVersion. " Running!".

// ==========vvv Planet paramaters vvv==========
GLOBAL PLANET to Body("Earth").
//GLOBAL PLANET to Body("Kerbin").
GLOBAL PLANET_RADIUS to PLANET:Radius.
GLOBAL PLANET_MASS to PLANET:Mass.
// ==========^^^ Planet paramaters ^^^==========

// ==========vvv Launch paramaters vvv==========
GLOBAL MyHEADING to 90.   //Ship launch heading
GLOBAL MYORBITAP to 170000.
GLOBAL MYORBITPE to 160000.
// ==========^^^ Launch paramaters ^^^==========

// ==========vvv Static paramaters vvv==========
GLOBAL SPEED_STARTTURN to 100. // When to begin turn
GLOBAL ANGLE_STARTTURN to 80. // Inital Turn angle
// ==========^^^ Static paramaters ^^^==========

// ==========vvv Global Variables vvv==========
GLOBAL ROLLANGLE to 90.
GLOBAL MYSTEER TO HEADING(MyHEADING,ANGLE_STARTTURN).
GLOBAL MYTHROTTLE to 1.
GLOBAL MAXQ to 0.
GLOBAL ThroughMaxQ to false.
// ==========^^^ Global Variables ^^^==========

//Launch Craft.
RunLaunchAlpha().
