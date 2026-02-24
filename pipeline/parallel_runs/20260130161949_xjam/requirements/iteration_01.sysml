package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 { text = "Handheld form factor suitable for single-hand use." }
  requirement def RQ_002 { text = "PM2.5 sensing capability." }
  requirement def RQ_003 { text = "CO2 sensing capability." }
  requirement def RQ_004 { text = "Temperature sensing capability." }
  requirement def RQ_005 { text = "Humidity sensing capability." }
  requirement def RQ_006 { text = "Operational runtime of at least 8 hours on a single charge." }
  requirement def RQ_007 { text = "Rechargeable battery with charging support." }
  requirement def RQ_008 { text = "Wi‑Fi wireless data synchronization capability." }
  requirement def RQ_009 { text = "Bluetooth wireless data synchronization capability." }
  requirement def RQ_010 { text = "Local data logging of measured values." }
  requirement def RQ_011 { text = "User interface and indicators for status and measurements." }

  constraint def C_001 {
    in mass: Real;
    (mass > 0.