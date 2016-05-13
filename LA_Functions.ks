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
  if BoostBDone = false {
    FirstStageLogic().
  } else {
    SecondStageLogic().
  }
  //Second Stage
}
DECLARE FUNCTION SecondStageLogic {

  LOCAL Radius is Earth:Radius + ALTITUDE.
  // Earth:Mass
  Local StgGravParam is Earth:Mass * constant:G.
  Local AccCent is  Ship:Velocity:orbit:Mag^2 / Radius.
  Local Grav is ( StgGravParam / Radius ^2).
  Local EquGrav is Grav - AccCent.
  Local Ge is AccCent - EquGrav.
  Local cTWR to SHIP:MAXTHRUST / (SHIP:MASS * EquGrav).
  Local Vvert is SHIP:VERTICALSPEED.
  Local B is 0.15.
  Local Vlimit is 2.
  Local Vtol is 4.

  //If we are above or below  we want to inject some verticle Accelleration
  IF ABS(SHIP:APOAPSIS - MYORBITAP) < 1000 {
    if(SHIP:APOAPSIS > MYORBITAP)  {
      SET Vvert to Vvert - 5.
    } else {
      SET Vvert to Vvert + 5.
    }
  }

  Local AVertTgt is MMAX(Vlimit,VACCTGT(B,Vvert,Vlimit,Vtol)).

  Local Angle is (AVertTgt-Ge)/(cTWR*Grav).
  Local FinalAngle is 0.
  Local AngleLimit is 20.


  if ABS(Angle) < 1  {
    set FinalAngle to MMAX(AngleLimit,arcsin(Angle)).
  } else {
    if AVertTgt - Ge < 0 {
        set FinalAngle to -AngleLimit.
    } else {
        set FinalAngle to AngleLimit.
    }
  }
  GLOBAL ROLLANGLE to FinalAngle.

}

DECLARE FUNCTION VACCTGT {
  DECLARE PARAMETER B.
  DECLARE PARAMETER Vvert.
  DECLARE PARAMETER Vmax.
  DECLARE PARAMETER Vtol.
  return (1-B)*Vmax*(-Vvert/Vtol)^3 + B*Vmax*(-Vvert/Vtol).
}

DECLARE FUNCTION MMAX {
  DECLARE PARAMETER RANGE.
  DECLARE PARAMETER X.
  return MINMAX(-RANGE,RANGE, X).
}

DECLARE FUNCTION MINMAX {
  DECLARE PARAMETER MIN.
  DECLARE PARAMETER MAX.
  DECLARE PARAMETER X.
  if X > MAX { return MAX. }
  if X < MIN { return MIN. }
  return X.
}

DECLARE FUNCTION FirstStageLogic {

  LOCAL Radius is Earth:Radius + ALTITUDE.
  // Earth:Mass
  Local StgGravParam is Earth:Mass * constant:G.
  Local AccCent is  Ship:Velocity:orbit:Mag^2 / Radius.
  Local Grav is ( StgGravParam / Radius ^2).
  Local EquGrav is Grav - AccCent.
  Local cTWR to SHIP:MAXTHRUST / (SHIP:MASS * EquGrav).
  Local Ge is AccCent - EquGrav.
  if cTWR = 0 { return. } //Math breaks down so just skip

  //Our goal is to maintain ~20m/s^2 up
  Local Angle is (20-Ge)/(cTWR*Grav).

  Local AddAngle is 0.

  if ABS(Angle) > 1 {
    if (Angle < 1) {
      //I really have no idea, its telling us to go down?
      //Should not happen as above accelleration is contant.
      print "SCRIPT IS SAYING TO POINT OUR NOSE DOWN DURING MAIN STAGE ASCENT".
    }
    //We just want to set it to 80 to go up.
    GLOBAL ROLLANGLE to 80.
    return.
  }

  set FinalAngle to arcsin(Angle).


  //Ship Prograde
  LOCAL surfPrograde is 90 - VANG(SHIP:SRFPROGRADE:VECTOR, UP:VECTOR).

  //We don't want to be outside 5 degrees from prograde.
  if abs(FinalAngle - surfPrograde) > 5 {
    if (FinalAngle > surfPrograde ) set FinalAngle to surfPrograde + 10.
    if (FinalAngle < surfPrograde ) set FinalAngle to surfPrograde - 10.
  }

  //Final Sanity check
  if FinalAngle < 0 {
    SET FinalAngle to 0.
  }

  GLOBAL ROLLANGLE to FinalAngle.


}
