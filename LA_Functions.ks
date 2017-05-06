//Common Functions used by LA

// Special Thanks to a "deLuxe" for the following PDF on orbital insertion:
// https://www.docdroid.net/zc9j/orbitalinsertion.pdf.html

Global lName to "Launch Alpha".
Global lVersion to 0.1.


Global THROTTLE_TARGET to 0.
Global THROTTLEROLL_LASTTICK to Time:SECONDS.
Global THROTTLE_BIIAS to 0.
Global DEBUG_LASTTICK to Time:SECONDS.
Global ROLLANGLE_TARGET to 0.
Global ROLLANGLE_LASTTICK to Time:SECONDS.



Global Radius to 0.
Global StgGravParam to 0.
Global AccCent to 0.
Global Grav to 0.
Global EquGrav to 0.
Global Weight to 0.
Global cTWR to 0.
Global Ge to 0.

Global DebugTick is false.
Global DebugGoal is false.

Global ActualAcc is 0.

Global VertVLast to 0.
Global VertTLast to 0.

Global VertV to 0.

Global TargetAcc is 0.
Global Angle is 0.
Global FinalAngle is 0.
Global FinalAngleSafe is 0.
Global surfPrograde is 0.
Global SafeAoA is 0.

//Main program for Launch Alpha. This runs a loop to execute launch functions.
Declare Function RunLaunchAlpha {
  //We lock throttle to 100% for launch.

  Set MYTHROTTLE to 1.
  Set THROTTLE_TARGET to 1.
  Set ROLLANGLE to 90.

  //Generate Heading Data for
  Set MYSTEER TO HEADING(MyHEADING,ROLLANGLE).
  LOCK STEERING TO MYSTEER.
  LOCK THROTTLE TO MYTHROTTLE.

  //Begin Launch Sequence
  LaunchSequence().

  //We should be moving now. Wait to start our turn.
  UNTIL SHIP:VERTICALSPEED > SPEED_STARTTURN {

  }

  Print "Initiating Turn.".

  PRINT "Rolling to " + ANGLE_STARTTURN.
  Set ROLLANGLE_TARGET TO ANGLE_STARTTURN.

  //Print "Throttling down to " + Stage1MinThrottle.

  //Throttle down for maxQ, drag reasons.
  //Set MYTHROTTLE to Stage1MinThrottle.

  UNTIL SHIP:PERIAPSIS > MYORBITPE {

    //Control Throttle for MaxQ.

    if Ship:Q > 0 {
      //Q tends to be <1 so this should work
      Set THROTTLE_TARGET to 1 - (Ship:Q - 0.2 ).


    //  Set THROTTLE_TARGET to THROTTLE_TARGET + THROTTLE_BIIAS.


    } else {
      Set THROTTLE_TARGET to 1.
    }

    DoMath().
    CheckStage().
    DoSteerLogic().
    ROLLANGLEROLL(0.2).
    THROTTLEROLL(0.2).
    DoDebug().


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

    if(abs(MYTHROTTLE - THROTTLE_TARGET) < 0.02) {
      Set MYTHROTTLE to THROTTLE_TARGET.
    } else {
      if(MYTHROTTLE - THROTTLE_TARGET > 0) {
        Set MYTHROTTLE to THROTTLE_TARGET - 0.01.
      } else {
        Set MYTHROTTLE to THROTTLE_TARGET + 0.01.
      }
    }

    if MYTHROTTLE > 1 {
      Set MYTHROTTLE to 1.
    }
    if MYTHROTTLE < Stage1MinThrottle {
      Set MYTHROTTLE to Stage1MinThrottle.
    }
  }
} // Function THROTTLEROLL

Declare Function ROLLANGLEROLL {
  Declare Parameter N.
  //Roll up the angle 2% each N seconds
  if Time:SECONDS > ROLLANGLE_LASTTICK + N {
    Set ROLLANGLE_LASTTICK to Time:SECONDS.

    if(abs(ROLLANGLE - ROLLANGLE_TARGET) < 0.2) {
      Set ROLLANGLE to ROLLANGLE_TARGET.
    } else {
      if(ROLLANGLE - ROLLANGLE_TARGET > 0) {
        Set ROLLANGLE to ROLLANGLE_TARGET - 0.1.
      } else {
        Set ROLLANGLE to ROLLANGLE_TARGET + 0.1.
      }

    }
  }
} // Function ROLLANGLEROLL {

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

Declare Function DoMath {
  set Radius to PLANET_RADIUS + ALTITUDE.
  set StgGravParam to PLANET_MASS * constant:G.
  set AccCent to  abs(SHIP:VERTICALSPEED^2 - Ship:Velocity:orbit:Mag^2) / Radius.
  set Grav to -( StgGravParam / Radius ^2).
  set EquGrav to abs(Grav + AccCent).
  set Weight to (constant:G * ((PLANET_MASS)/Radius^2)) * SHIP:MASS.
  set cTWR to GetCurrentThrust() / Weight.
  set Ge to EquGrav - AccCent.
  set surfPrograde to 90 - VANG(SHIP:SRFPROGRADE:VECTOR, UP:VECTOR).
  set VertV to SHIP:VERTICALSPEED.
  //a = Δv / Δt = (vf - vi)/(tf - ti).
  set ActualAcc to (VertV - VertVLast)/(Time:SECONDS - VertTLast).

  set VertVLast to VertV.
  set VertTLast to Time:SECONDS.
}

Declare Function DoDebug {
    set DebugTick to false.
    if Time:SECONDS > DEBUG_LASTTICK + 1 {
      set DebugTick to true.
      set DEBUG_LASTTICK to Time:SECONDS.
    }

    if DebugTick {
      CLEARSCREEN.
      Print "============================================".
      Print "        Script State".
      Print "                    STAGEBDone " + STAGEBDone.
      Print "                    STAGECDone " + STAGECDone.
      Print "                  StagingLevel " + StagingLevel.
      Print "                    StageDelay " + StageDelay.
      Print "        Ship State".
      Print "                       Ship:Q: " + Ship:Q.
      Print "                       Radius: " + Radius.
      Print "                 StgGravParam: " + StgGravParam.
      Print "                      AccCent: " + AccCent.
      Print "                         Grav: " + Grav.
      Print "                      EquGrav: " + EquGrav.
      Print "                       Thrust: " + GetCurrentThrust().
      Print "                         MASS: " + SHIP:MASS.
      Print "                       Weight: " + Weight.
      Print "                         cTWR: " + cTWR.
      Print "                           Ge: " + Ge.
      Print "                 surfPrograde: " + surfPrograde.
      Print "                        VertV: " + VertV.
      Print "                    ActualAcc: " + ActualAcc.
      Print " Flight Plan State".
      Print "                    TargetAcc: " + TargetAcc.
      Print "                        Angle: " + Angle.
      Print "                   FinalAngle: " + FinalAngle.
      Print "                      SafeAoA: " + SafeAoA.
      Print "               FinalAngleSafe: " + FinalAngleSafe.
      Print "                          AoA: " + abs(FinalAngleSafe - surfPrograde).
      Print "                    DebugGoal: " + DebugGoal.
    }
}



// Execute first stage steering logic.
Declare Function FirstStageLogic {

  if cTWR = 0 {
    set DebugGoal to "No Thrust!" .
    return.
  } //Math breaks down so just skip

  set TargetAcc to GetFirstStageAccelleration().

  //Our goal is to maintain ~28m/s^2 up
  set Angle to (TargetAcc/(abs(GetCurrentThrust() - Weight) / SHIP:MASS )).
  //set Angle to (TargetAcc+Ge)/(cTWR*EquGrav).

  set AddAngle to 0.

  if ABS(Angle) > 1 {
    if (Angle < 1) {
      //I really have no idea, its telling us to go down?
      //Should not happen as above accelleration is contant.
      set DebugGoal to "SCRIPT IS SAYING TO POINT OUR NOSE DOWN DURING MAIN STAGE ASCENT".
    }
    //We just want to Set it to 80 to go up.
    set DebugGoal to "GO UP!" .

    Set THROTTLE_BIIAS to 0.3.
    Global ROLLANGLE_TARGET to 80.
    return.
  }

  Set FinalAngle to arcsin(Angle).

  //We don't want to be outside 5 degrees from prograde.
  //Consider ajusting TWR / Throttle limits
  Set SafeAoA to GetSafeAoA().
  if abs(FinalAngle - surfPrograde) > SafeAoA {
    if (FinalAngle > surfPrograde ) {
      Set FinalAngleSafe to surfPrograde + SafeAoA.
      Set THROTTLE_BIIAS to 0.1.
    }
    if (FinalAngle < surfPrograde ) {
        Set FinalAngleSafe to surfPrograde - SafeAoA.
        Set THROTTLE_BIIAS to -0.1.
      }
  } else {
    Set THROTTLE_BIIAS to 0.
    Set FinalAngleSafe to FinalAngle.
  }

  //Final Sanity check
  if FinalAngleSafe < 0 {
    Set FinalAngleSafe to 0.
  }
  if abs(FinalAngleSafe - surfPrograde) > 0.1 {
    if (FinalAngleSafe > surfPrograde ) Set DebugGoal to "More Height".
    if (FinalAngleSafe < surfPrograde ) Set DebugGoal to "Less Height".
  } else {
    Set DebugGoal to "Maintain Height".
  }


  Set ROLLANGLE_TARGET to FinalAngleSafe.
} // Function FirstStageLogic

// Execute second stage steering logic
Declare Function SecondStageLogic {
//  Local Radius is PLANET_RADIUS + ALTITUDE.
  //Local StgGravParam is PLANET_MASS * constant:G.
  //Local AccCent is  abs(SHIP:VERTICALSPEED^2 - Ship:Velocity:orbit:Mag^2) / Radius.
//  Local Grav is -( StgGravParam / Radius ^2).
  //Local EquGrav is abs(Grav + AccCent).
//  Local cTWR to GetCurrentThrust() / (SHIP:MASS * EquGrav).
  //Local Ge is EquGrav - AccCent.
//  Local Vvert is SHIP:VERTICALSPEED.
  Local B is 0.15.
  Local Vlimit is 5. //limit of 5m/s^2 of accelleration up or down
  Local Vtol is 20. //Velicity tollerance, Within this the accelleration slopes

  if cTWR = 0 {
      Set DebugGoal to "No Thrust!" .

    return.
  } //Math breaks down so just skip

  set TargetAcc to VACCTGT(B,SHIP:APOAPSIS - MYORBITAP,Vlimit,Vtol).

  //If we are below  we want to inject some verticle Accelleration
  IF ABS(SHIP:APOAPSIS - MYORBITAP) > 1000  {
    if(SHIP:APOAPSIS < MYORBITAP and VertV >100)  {
      Set TargetAcc to TargetAcc + 10.
      Set DebugGoal to "VERTICAL MODIFIED: +10m/s^2" .
    }
  } else {
    set TargetAcc to 0.
  }

  set Angle to (TargetAcc/(abs(GetCurrentThrust() - Weight) / SHIP:MASS )).
  //set Angle to (TargetAcc+abs(Ge))/(cTWR*EquGrav).

  set FinalAngle to 0.
  set AngleLimit to 20.

  if ABS(Angle) < 1  {
    Set FinalAngle to MMAX(AngleLimit,arcsin(Angle)).
  } else {
    if TargetAcc < 0 {
        Set FinalAngle to 0.
    } else {
        Set FinalAngle to AngleLimit.
    }
  }
  Set FinalAngleSafe to FinalAngle.

  if ABS(Angle) > 1 {
    if (TargetAcc - Ge > 0 ) Set DebugGoal to "More Height".
    if (TargetAcc - Ge < 0) Set DebugGoal to "Less Height".
  } else {
    Set DebugGoal to "Maintain Height".
  }

  Global ROLLANGLE_TARGET to FinalAngleSafe.

} //Function SecondStageLogic
