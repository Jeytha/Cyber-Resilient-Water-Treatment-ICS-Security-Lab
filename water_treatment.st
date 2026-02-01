PROGRAM WaterTreatment
VAR
  TankLevel : INT;
  Pump : BOOL;
  ChlorineValve : BOOL;
END_VAR

(* Normal operation *)
IF TankLevel < 40 THEN
  Pump := TRUE;
  ChlorineValve := TRUE;
ELSIF TankLevel > 90 THEN
  Pump := FALSE;
  ChlorineValve := FALSE;
END_IF;
