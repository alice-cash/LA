//Settings used by the Craft. This can be modified per ship

GLOBAL MinThrottle to 0.5.

GLOBAL BoostA to ship:partstagged("BoostA")[0]. //SRB
GLOBAL BoostB to ship:partstagged("BoostB")[0]. //First Stage
GLOBAL BoostC to ship:partstagged("BoostC")[0]. //Second Stage

GLOBAL BoostADone to false.
GLOBAL BoostBDone to false.
GLOBAL BoostCDone to false.

//Staging function. Should be modified to any
DECLARE FUNCTION CheckStage {
   if not BoostADone {
    if BoostA:FLAMEOUT {
      Wait 2.
      STAGE. //Decouple SRB
      set BoostADone to true.
    }
  } else if not BoostBDone {
    if BoostB:FLAMEOUT {
      set mythrottle to 1.
      PRINT "Released".
      STAGE. //Decouple
      rcs on.
      SET SHIP:CONTROL:FORE TO 1. //Activate RCS to set utilage
      PRINT "RCS On".
      Wait 1.
      STAGE. //Fire engines after 1 second of RCS
      SET SHIP:CONTROL:FORE to 0.0.
      PRINT "Stage Fired".
      rcs off.
      PRINT "RCS Off".
      Wait 1. // burn for a second before returning control
      set BoostBDone to true.
    }
  } else if not BoostCDone {
    if BoostC:FLAMEOUT {
      Wait 1.
      STAGE. //Decouple
      set BoostCDone to true.
      Wait 1.
      //STAGE. //Fire Third Stage (hypergolic, no utilage)

    }
  }
}
