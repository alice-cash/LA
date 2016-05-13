//Common Functions used by LA
GLOBAL lName to "Launch Alpha".
GLOBAL lVersion to 0.01.

DECLARE FUNCTION TestFunction {
  return "Test Function!".
}

DECLARE FUNCTION PITCH {
  return 90 - vang(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR).
}


DECLARE FUNCTION DoLogic {
  //if BoostBDone = false {
    FirstStageLogic().
  //}
  //Second Stage
}
DECLARE FUNCTION FirstStageLogic {
  // If Throttle > 0.9 and vertical speed < target, Roll Up
  // If Throttle < 0.9 and vertical speed < target, Throttle Up
  // If vertical speed > target, Roll down

  //Edge cases due to roll limits:
  //Cannot roll up: Throttle up
  //Cannot roll down: Throttle down

  LOCAL lspd to LOW_ALTITUDE_SPEED.
  LOCAL hiang to ANGLE_STARTTURN.
  LOCAL loturn to LOW_ALTITUDE_TURN.
  LOCAL turnrate to 0.5.

  IF ALTITUDE < LOW_ALTITUDE {
    print "Low Alt.".
    SET lspd to LOW_ALTITUDE_SPEED.
    SET hiang to ANGLE_STARTTURN.
    SET loturn to LOW_ALTITUDE_TURN.

  } //  IF ALTITUDE < LOW_ALTITUDE

  IF ALTITUDE >= LOW_ALTITUDE and ALTITUDE < HIGH_ALTITUDE {
    //High altitude, focus on going fast sizeways while sitll going up
    print "High Alt.".
    SET lspd to HIGH_ALTITUDE_SPEED.
    SET hiang to ANGLE_STARTTURN.
    SET loturn to 0.

}

  IF ALTITUDE >= HIGH_ALTITUDE {
    print "Space Alt.".
    //Space, Focus on going sideways very fast.
    //If AP is below target roll up
    //If AP is above target roll down
    SET lspd to SPACE_ALTITUDE_SPEED.
    SET hiang to ANGLE_STARTTURN.
    SET loturn to -10.
    SET turnrate to 1.
  }

  //Calculate Accelleration
  //Local Accelleration is SHIP:VERTICALSPEED - MYLASTSPEED.
  //GLOBAL MYLASTSPEED is SHIP:VERTICALSPEED.
  //print "Accelleration " + Accelleration.
//y=\left(\frac{x-160000}{6000}\right)^2
//\log \left(\frac{x}{100}\right)\cdot 30000+100000
//Test hax

//SET lspd to Constant:DegToRad * (arctan((ALTITUDE+10000)/30000))*80999.
//Close - Orbitor 3
SET lspd to Constant:DegToRad * (arctan(ALTITUDE/30000))*78203.

///SET lspd to Constant:DegToRad * (arctan(ALTITUDE/40000))*142823.

  IF SHIP:APOAPSIS > 100000 {
    print "Target Get Alt.".
    SET lspd to MYORBITAP.
    SET hiang to ANGLE_STARTTURN.
    SET turnrate to 2.
    if SHIP:VERTICALSPEED > 0 {
      SET loturn to -15.
    } else {
      SET loturn to 15.
    }

  }

  IF ABS(SHIP:APOAPSIS - MYORBITAP) < 1000 {
    print "Target Get Alt.".
    SET lspd to MYORBITAP.
    SET turnrate to 0.
    if SHIP:VERTICALSPEED > 0 {
      SET hiang to 0.
      SET loturn to 0.
    } else {
      SET hiang to 10.
    SET loturn to 10.
    }
  }


  Print "Altitude " + ALTITUDE.
  Print "APOAPSIS " + SHIP:APOAPSIS.
  Print "Target " + lspd.

    //Low altitude, Focus on very slow rolls and going up fast.
    //If SHIP:VERTICALSPEED < lspd {
    If SHIP:APOAPSIS < lspd {
      //More Throttle, less turn
      if MYTHROTTLE >= 0.9 {
        //roll up as throttle is at 0.9
        GLOBAL ROLLANGLE to ROLLANGLE + turnrate.
        if ROLLANGLE > hiang {
          GLOBAL ROLLANGLE to hiang.
          GLOBAL MYTHROTTLE to 1.
        }
      } else {
        GLOBAL MYTHROTTLE to MYTHROTTLE + 0.1.
      }
      //If SHIP:VERTICALSPEED < LOW_ALTITUDE_SPEED
    } else {

      GLOBAL ROLLANGLE to ROLLANGLE - turnrate.
      if ROLLANGLE < loturn {
        GLOBAL ROLLANGLE to loturn.
        //GLOBAL MYTHROTTLE to MYTHROTTLE - 0.05.
        if MYTHROTTLE < MinThrottle  {
          //GLOBAL MYTHROTTLE TO MinThrottle.
        }
      }
    }
}
