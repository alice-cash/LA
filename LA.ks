//(L)aunch (A)lpha V (0).01

//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.
Print lName + " " + lVersion. " Running!".

//Initilize Libraries
run LA_Functions.
run LA_CraftSettings.

// ==========vvv Launch paramaters vvv==========
GLOBAL MyHEADING to 90.   //Ship launch heading
GLOBAL MYORBITAP to 100000. //Not the final aptosis but shitty math
GLOBAL MYORBITPE to 160000.

// ==========^^^ Launch paramaters ^^^==========

// ==========vvv Static paramaters vvv==========

GLOBAL SPEED_STARTTURN to 100. // When to begin turn
GLOBAL ANGLE_STARTTURN to 80. // Inital Turn angle

GLOBAL LOW_ALTITUDE to 20000. // Low Altitide Hight
GLOBAL LOW_ALTITUDE_TURN to 55. // Maximum Turn angle below LOW_ALTITUDE
GLOBAL HIGH_ALTITUDE to 100000. // High Altitide Height

Global LOW_ALTITUDE_SPEED to 600. //Target verticle speed
Global HIGH_ALTITUDE_SPEED to 200. //Target verticle speed
Global SPACE_ALTITUDE_SPEED to 100. //Space verticle speed

// ==========^^^ Static paramaters ^^^==========

// ==========vvv Global Variables vvv==========
GLOBAL ROLLANGLE to 90.
GLOBAL MYSTEER TO HEADING(MyHEADING,ANGLE_STARTTURN).
GLOBAL MYTHROTTLE to 0.9.
GLOBAL MYLASTSPEED TO 0.
// ==========^^^ Global Variables ^^^==========

// Steps: reach 100m/s
// Begin Roll to heading
// Once Vertical Speed > 700 throttle to keep at 700
// Once at target speed Begin .5/s roll to 65 while keeping speed at 700
// When past 30,000 allow unlimited roll to 0
// Once aptosis = MyOrbitAP roll to keep aptosis at that
// Kill Throttle when perhapis is MYORBITPE

// ship control works as:
// If Throttle > 0.9 and vertical speed < target, Roll Up
// If Throttle > 0.9 and vertical speed > target, Throttle down
// If Throttle < 0.9 and vertical speed < target, Throttle Up
// If Throttle < 0.9  and vertical speed > target, Roll Down


//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

SET MYSTEER TO HEADING(MyHEADING,90).
SAS ON.
//LOCK STEERING TO MYSTEER.

//This is our countdown loop, which cycles from 10 to 0
//PRINT "Counting down:".
//FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
//    PRINT "..." + countdown.
//    WAIT 1. // pauses the script here for 1 second.
//}

//Fire the main
Print "Main Engine Firing.".
STAGE.
WAIT 1.
Print "RELEASE.".
//Fire Boosters and release clamps
STAGE.

UNTIL SHIP:VERTICALSPEED > SPEED_STARTTURN {

}
Print "Initating Turn.".
SAS OFF.
LOCK STEERING TO MYSTEER.

PRINT "Rolling to " + ANGLE_STARTTURN + ".".
GLOBAL ROLLANGLE TO ANGLE_STARTTURN.
GLOBAL MYSTEER TO HEADING(MyHEADING,ROLLANGLE).
LOCK THROTTLE TO MYTHROTTLE.
GLOBAL MYLASTSPEED TO SHIP:VERTICALSPEED.

UNTIL SHIP:PERIAPSIS > 140000 {

  CheckStage().
  DoLogic().

  PRINT "Rolling to " + ROLLANGLE + ".".
  PRINT "Throttle to " + MYTHROTTLE + ".".
  GLOBAL MYSTEER TO HEADING(MyHEADING,ROLLANGLE).
  WAIT 0.25.

}
