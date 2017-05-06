


//Settings used by the Craft. This can be modified for ship reqiorements.

GLOBAL STAGEB to ship:partstagged("STAGEB")[0]. //First Stage
GLOBAL STAGEC to ship:partstagged("STAGEC")[0]. //Second Stage

GLOBAL STAGEBDone to false.
GLOBAL STAGECDone to false.

//Minimum throttle for First Stage. This will be dropped to this after roll
//Engine will return to 100% after MaxQ. Ensure your TWR is OK at this level
//Also ensure your engine can throttle this far down. Some mod conditions
//may set a minimum throttle limit.
Global Stage1MinThrottle to 0.4.

Global CheckStageTiming to Time:SECONDS.
Global StagingLevel to 0.
Global DoingStaging to false.
Global StageDelay to 0.

Declare Function LaunchSequence {
  //Fire the SRBs.
  WAIT 1.
  Print "Main Engine Firing.".
  STAGE.
  WAIT 1. //Long engine startup.
  Print "RELEASE.".
  //release clamps
  STAGE.
}

//Basic curve going from a positive to negitive accelleration after ~40,000 meters
//The reason we have a negitive accelleration is the rocket needs to remove vertical speed
// and add horozontal speed.
Declare Function GetFirstStageAccelleration {
  return ((((140000 - ALTITUDE) * (100000 - ALTITUDE)) * 0.000000002) - 17) + EquGrav.
}

//returns a range of ~5 AoA to 30 AoA.
Declare Function GetSafeAoA {
  return ((ALTITUDE)*0.00022)+5.
  //return ((ALTITUDE * ALTITUDE) * 0.0000000033) + 5.
}

//First Stage
Declare Function StagingB {
  //Delay 2, Stage, Delay 10 more seconds
  //Fire RCS, Delay 1 seconds, Stage, Delay 1, RCS off.
  if Time:SECONDS > CheckStageTiming + StageDelay {
    if StagingLevel = 0 {
      PRINT "First Stage Seperation".
      STAGE.
      set StagingLevel to 1.
      set StageDelay to 1. //1 second wait before firing next step.
      set CheckStageTiming to Time:SECONDS.

      return.
    } else if StagingLevel = 1 {
      //wait until vertical speed < 200m/s
      //if SHIP:VERTICALSPEED > 400 { return. }
      rcs on.
      PRINT "RCS On".
      SET SHIP:CONTROL:FORE TO 1. //Activate RCS to set utilage
      set StagingLevel to 2.
      set StageDelay to 1. //1 second delay before firing next step.
      set CheckStageTiming to Time:SECONDS.
      return.
    }  else if StagingLevel = 2 {
      STAGE.
      Print "Second Stage Startup.".
      set StagingLevel to 3.
      set CheckStageTiming to Time:SECONDS.
      return.
    } else if StagingLevel = 3 {
      PRINT "RCS Off".
      rcs off.
      SET SHIP:CONTROL:FORE to 0.0.
      set STAGEBDone to true.
      set DoingStaging to false.
    }
  }
} // Function StagingB

Declare Function StagingC {
  if Time:SECONDS > CheckStageTiming + StageDelay {
    if StagingLevel = 0 {
      STAGE. //Decouple
      set StagingLevel to 1.
      set StageDelay to 2. //1 second delay before firing next step.
      set CheckStageTiming to Time:SECONDS.

      return.
    }  else if StagingLevel = 1 {
      Stage. //Fire third stage (Hypergolic)
      set STAGECDone to true.
      set DoingStaging to false.
    }
  }
} // Function StagingC

Declare Function CheckStage {
  if DoingStaging {
    if not STAGEBDone {
      StagingB().
    } else if not STAGECDone {
      StagingC().
    }
  } else {
    if not STAGEBDone {
      if STAGEB:FLAMEOUT {
        set CheckStageTiming to Time:SECONDS.
        set DoingStaging to true.
        set StagingLevel to 0.
        set StageDelay to 2.
      }
    } else if not STAGECDone {
      if STAGEC:FLAMEOUT {
        set CheckStageTiming to Time:SECONDS.
        set DoingStaging to true.
        set StagingLevel to 0.
        set StageDelay to 1.
        //STAGE. //Fire Third Stage (hypergolic, no utilage)
      }
    }
  }
}
