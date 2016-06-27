//Common Functions used by LA

// Special Thanks to a "deLuxe" for the following PDF on orbital insertion:
// https://www.docdroid.net/zc9j/orbitalinsertion.pdf.html

Global lName to "Launch Alpha".
Global lVersion to 0.1.



Global THROTTLEROLL_LASTTICK to Time:SECONDS.
Global DEBUG_LASTTICK to Time:SECONDS.


//Main program for Launch Alpha. This runs a loop to execute launch functions.
Declare Function RunLaunchAlpha {
  //We lock throttle to 100% for launch.
  LOCK THROTTLE TO 1.0.

  //Generate Heading Data for
  Set MYSTEER TO HEADING(MyHEADING,90).
  LOCK STEERING TO MYSTEER.

  //Begin Launch Sequence
  LaunchSequence().

  //We should be moving now. Wait to start our turn.
  UNTIL SHIP:VERTICALSPEED > SPEED_STARTTURN {

  }

  Print "Initiating Turn.".

  PRINT "Rolling to " + ANGLE_STARTTURN.
  Set ROLLANGLE TO ANGLE_STARTTURN.
  Set MYSTEER TO HEADING(MyHEADING,ROLLANGLE).
  LOCK THROTTLE TO MYTHROTTLE.

  Print "Throttling down to " + Stage1MinThrottle.

  //Throttle down for maxQ, drag reasons.
  Set MYTHROTTLE to Stage1MinThrottle.

  Set ROLLANGLE to 80.

  //We are going up and we need to ensure prograde is locked in.
  WAIT 10.

  UNTIL SHIP:PERIAPSIS > MYORBITPE {

    //Control Throttle for MaxQ.
    if not ThroughMaxQ {
      if Ship:Q < MAXQ {
        Set ThroughMaxQ to true.
        Print "MaxQ reached!".
      } else {
        Set MAXQ to Ship:Q.
      }
    } else if MYTHROTTLE < 1 {
      THROTTLEROLL(5). //Roll the throttle up 2% every 5 seconds
    }

    CheckStage().
    DoSteerLogic().

    //PRINT "Rolling to " + ROLLANGLE + ".".
    //PRINT "Throttle to " + MYTHROTTLE + ".".
    Set MYSTEER TO HEADING(MyHEADING,ROLLANGLE).
    WAIT 0. //Wait 1 physics frame.
  }  // UNTIL SHIP:PERIAPSIS > MYORBITPE

  Set SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
} // function Run()

// Function for Rolling the Throttle up. Rolls Throttle up every N seconds.
// To be called each physics frame/
Declare Function THROTTLEROLL {
  Declare Parameter N.
  //Roll up the throttle 2% each N seconds
  if Time:SECONDS > THROTTLEROLL_LASTTICK + N {
    Set THROTTLEROLL_LASTTICK to Time:SECONDS.
    Set MYTHROTTLE to MYTHROTTLE + 0.02.
    if MYTHROTTLE > 1 {
      Set MYTHROTTLE to 1.
    }
  }
} // Function THROTTLEROLL

// Perform steering logic
Declare Function DoSteerLogic {
  if STAGEBDone = false {
    FirstStageLogic().
  } else {
    SecondStageLogic().
  }
} //Function DoLogic

// Determin Velocity Aceleration Target
// When Velocity > 0, returns a negitive accelleration
// When Velocity < 0, returns a positive accelleration
// paramaters:
// B: Determins slope of graph, 0 is hyperbolic, 1 is linear
// VVert: Vertical Speed.
// Vmax: Maximum accelleration allowed, both positve and negitive.
// Vtol: Tollerance, outside this the min/max accelleration is returned
// Reference https://www.desmos.com/calculator/yztlco2plp
Declare Function VACCTGT {
  Declare Parameter B.
  Declare Parameter Vvert.
  Declare Parameter Vmax.
  Declare Parameter Vtol.
  return MMAX(Vmax,(1-B)*Vmax*(-Vvert/Vtol)^3 + B*Vmax*(-Vvert/Vtol)).
} //Function VACCTGT

// Return either X if it falls within ± RANGE or ± RANGE
// paramaters:
// RANGE: The absolute minimum and maximum values allowed
// X: The value to check.
Declare Function MMAX {
  Declare Parameter RANGE.
  Declare Parameter X.
  return MINMAX(-RANGE,RANGE, X).
}

// Return either X if it falls within MIN and MAX, or MIN / MAX limut reached
// NO ERROR CHECKING TO SEE IF MIN < MAX !
// paramaters:
// MIN: Minimum value allowed to return
// MAX: Maximum value allowed to return
// X: The value to check.
Declare Function MINMAX {
  Declare Parameter MIN.
  Declare Parameter MAX.
  Declare Parameter X.
  if X > MAX { return MAX. }
  if X < MIN { return MIN. }
  return X.
}

//Return Current Thrust of ship, as SHIP:THRUST doesn't exsist.
Declare Function GetCurrentThrust {
  Local ThrustTotal to 0.
  List Engines IN EngineList.
  FOR E IN EngineList {
    Set ThrustTotal to ThrustTotal + E:Thrust.
  }
  return ThrustTotal.
}

// Execute first stage steering logic.
Declare Function FirstStageLogic {
  Local Radius is PLANET_RADIUS + ALTITUDE.
  Local StgGravParam is PLANET_MASS * constant:G.
  Local AccCent is  abs(SHIP:VERTICALSPEED^2 - Ship:Velocity:orbit:Mag^2) / Radius.
  Local Grav is StgGravParam / Radius ^2.
  Local Ge is AccCent-Grav.
  Local Weight is constant:G * ((PLANET_MASS * SHIP:MASS)/Radius^2).
  Local cTWR to GetCurrentThrust() / Weight.

  Local DebugTick is false.
  if Time:SECONDS > DEBUG_LASTTICK + 1 {
    set DebugTick to true.
    set DEBUG_LASTTICK to Time:SECONDS.
  }

  if DebugTick {
    CLEARSCREEN.
    Print "============================================".
    Print "                       Radius: " + Radius.
    Print "                 StgGravParam: " + StgGravParam.
    Print "                      AccCent: " + AccCent.
    Print "                         Grav: " + Grav.
    Print "                       Thrust: " + GetCurrentThrust().
    Print "                         MASS: " + SHIP:MASS.
    Print "                       Weight: " + Weight.
    Print "                         cTWR: " + cTWR.
    Print "                           Ge: " + Ge.
  }
  if cTWR = 0 {
    if DebugTick {
      Print "              Our current goal: No Thrust!" .
      Print "============================================".
    }
    return.
  } //Math breaks down so just skip

  Local TargetAcc is GetFirstStageAccelleration().

  if(SHIP:APOAPSIS > MYORBITAP-1000) {
    Set TargetAcc to 0.
  }

  if(TargetAcc-Ge < 0) {
    Set TargetAcc to Ge.
  }

  Local Angle is (TargetAcc+Ge)/(cTWR*Grav).

  Local AddAngle is 0.

  if DebugTick {
    Print "               (TargetAcc+Ge): " + (TargetAcc+Ge).
    Print "                  (cTWR*Grav): " + (cTWR*Grav).
    Print "                        Angle: " + Angle.
    Print "                        Angle: " + Angle.
    Print "                    TargetAcc: " + TargetAcc.
  }
  if ABS(Angle) > 1 {
    if (Angle < 1) {
      //I really have no idea, its telling us to go down?
      //Should not happen as above accelleration is contant.
      print "SCRIPT IS SAYING TO POINT OUR NOSE DOWN DURING MAIN STAGE ASCENT".
    }
    //We just want to Set it to 80 to go up.
    if DebugTick {
      Print "              Our current goal: GO UP faster!" .
      Print "============================================".
    }
    Global ROLLANGLE to 80.
    return.
  }

  Set FinalAngle to arcsin(Angle).


  //Ship Prograde
  Local surfPrograde is 90 - VANG(SHIP:SRFPROGRADE:VECTOR, UP:VECTOR).
  if DebugTick {
    Print "                         Angle: " + Angle.
    Print "                    FinalAngle: " + FinalAngle.
    Print "                  surfPrograde: " + surfPrograde.
    Print "                        aVert: " + ((ge)+(cTWR*Grav*sin(surfPrograde))).
  }
  //We don't want to be outside 5 degrees from prograde.
  //Consider ajusting TWR / Throttle limits
  if abs(FinalAngle - surfPrograde) > Stage1MaxAOT {
    if (FinalAngle > surfPrograde ) Set FinalAngle to surfPrograde + Stage1MaxAOT.
    if (FinalAngle < surfPrograde ) Set FinalAngle to surfPrograde - Stage1MaxAOT.
  }

  //Final Sanity check
  if FinalAngle < 0 {
    Set FinalAngle to 0.
  }
  if DebugTick {
    Print "abs(FinalAngle - surfPrograde): " + abs(FinalAngle - surfPrograde).
    Print "                    FinalAngle: " + FinalAngle.
    Print "============================================".
    if abs(FinalAngle - surfPrograde) = Stage1MaxAOT {
      if (FinalAngle > surfPrograde ) Set DEBUG_goal to "More Height".
      if (FinalAngle < surfPrograde ) Set DEBUG_goal to "Less Height".
    } else {
      Set DEBUG_goal to "Maintain Height".
    }
    Print "              Our current goal: " + DEBUG_goal.
    Print "============================================".
  }
  Global ROLLANGLE to FinalAngle.
} // Function FirstStageLogic

// Execute second stage steering logic
Declare Function SecondStageLogic {
  Local Radius is PLANET_RADIUS + ALTITUDE.
  Local StgGravParam is PLANET_MASS * constant:G.
  Local AccCent is  abs(SHIP:VERTICALSPEED^2 - Ship:Velocity:orbit:Mag^2) / Radius.
  Local Grav is StgGravParam / Radius ^2.
  Local Ge is AccCent-Grav.
  Local Weight is constant:G * ((PLANET_MASS * SHIP:MASS)/Radius^2).
  Local cTWR to GetCurrentThrust() / Weight.
  Local Vvert is SHIP:VERTICALSPEED.
  Local B is 0.15.
  Local Vlimit is 5. //limit of 5m/s^2 of accelleration up or down
  Local Vtol is 2000. //Velicity tollerance, Within this the accelleration slopes

  Local DebugTick is false.
  if Time:SECONDS > DEBUG_LASTTICK + 1 {
    set DebugTick to true.
    set DEBUG_LASTTICK to Time:SECONDS.
  }
  if DebugTick {
    CLEARSCREEN.
    Print "============================================".
    Print "                       Radius: " + Radius.
    Print "                 StgGravParam: " + StgGravParam.
    Print "                      AccCent: " + AccCent.
    Print "                         Grav: " + Grav.
    Print "                       Thrust: " + GetCurrentThrust().
    Print "                         MASS: " + SHIP:MASS.
    Print "                       Weight: " + Weight.
    Print "                         cTWR: " + cTWR.
    Print "                           Ge: " + Ge.
    Print "                        Vvert: " + Vvert.
  }
  if cTWR = 0 {
    if DebugTick {
      Print "              Our current goal: No Thrust!" .
      Print "============================================".
    }
    return.
  } //Math breaks down so just skip

  //If we are above or below  we want to inject some verticle Accelleration
  Local AVertTgt is VACCTGT(B,Vvert,Vlimit,Vtol).

  IF ABS(SHIP:APOAPSIS - MYORBITAP) > 1000 {
    if(SHIP:APOAPSIS > MYORBITAP)  {
      Set AVertTgt to AVertTgt - 5.
      if DebugTick { Print "              VERTICAL MODIFIED: -5m/s^2" . }
    } else {
      Set AVertTgt to AVertTgt + 5.
      if DebugTick { Print "              VERTICAL MODIFIED: +5m/s^2" . }
    }
  } else {
    set AVertTgt to 0.
  }


  Local Angle is (AVertTgt+Ge)/(cTWR*Grav).

  Local AddAngle is 0.
  Local surfPrograde is 90 - VANG(SHIP:SRFPROGRADE:VECTOR, UP:VECTOR).

  if DebugTick {
    Print "                (AVertTgt+Ge): " + (AVertTgt+Ge).
    Print "                  (cTWR*Grav): " + (cTWR*Grav).
    Print "                        Angle: " + Angle.
    Print "                        Angle: " + Angle.
    Print "                     AVertTgt: " + AVertTgt.
    Print "                        aVert: " + ((ge)+(cTWR*Grav*sin(surfPrograde))).
  }
  Local FinalAngle is 0.
  Local AngleLimit is 20.

  if ABS(Angle) < 1  {
    Set FinalAngle to MMAX(AngleLimit,arcsin(Angle)).
  } else {
    if AVertTgt - Ge < 0 {
        Set FinalAngle to 0.
    } else {
        Set FinalAngle to AngleLimit.
    }
  }

  if DebugTick {
    Print "                    ABS(Angle): " + ABS(Angle).
    Print "                    FinalAngle: " + FinalAngle.
    Print "============================================".
    if ABS(Angle) > 1 {
      if (AVertTgt - Ge > 0 ) Set DEBUG_goal to "More Height".
      if (AVertTgt - Ge < 0) Set DEBUG_goal to "Less Height".
    } else {
      Set DEBUG_goal to "Maintain Height".
    }
    Print "              Our current goal: " + DEBUG_goal.
    Print "============================================".
  }
  Global ROLLANGLE to FinalAngle.

} //Function SecondStageLogic
