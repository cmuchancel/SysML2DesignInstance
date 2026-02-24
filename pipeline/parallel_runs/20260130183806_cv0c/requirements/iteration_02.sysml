package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "The system shall deliver a soft-toss ball to a batter to support batting practice.";
  }
  constraint def C_001 {
    in deliverable: Boolean;
    deliverable = true
  }
  requirement def RQ_002 {
    text = "The system shall provide a non-repetitive practice experience by varying toss outcomes rather than repeating a single fixed toss.";
  }
  constraint def C_002 {
    in variationModes: Real;
    (variationModes >= 1.0) and (variationModes <= 100.0)
  }
  requirement def RQ_003 {
    text = "The system shall support use by players and coaches during practice sessions.";
  }
  constraint def C_003 {
    in stakeholderSupport: Boolean;
    stakeholderSupport = true
  }
  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass dirt fields gymnasiums and backyards.";
  }
  constraint def C_004 {
    in outdoorTolerance: Boolean;
    outdoorTolerance = true
  }
  requirement def RQ_005 {
    text = "The system shall deliver a regulation softball or equivalent practice ball from a machine output location toward a batter's hitting area.";
  }
  constraint def C_005 {
    in ballDiameter_mm: Real;
    (ballDiameter_mm >= 88.9) and (ballDiameter_mm <= 96.0)
  }
  requirement def RQ_006 {
    text = "The system shall be capable of varying toss height speed and direction across successive tosses.";
  }
  constraint def C_006 {
    in speedVar_mps: Real;
    (speedVar_mps >= 0.5) and (speedVar_mps <= 20.0)
  }
  requirement def RQ_007 {
    text = "The system shall provide a user-defined toss interval including the ability to adjust the interval during practice.";
  }
  constraint def C_007 {
    in interval_s: Real;
    (interval_s >= 0.5) and (interval_s <= 30.0)
  }
  requirement def RQ_008 {
    text = "The system shall support a repeatable mode where toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_008 {
    in landingRepeatability_m: Real;
    (landingRepeatability_m >= 0.0) and (landingRepeatability_m <= 0.5)
  }
  requirement def RQ_009 {
    text = "The system shall prevent or detect common feed or launch faults and shall respond in a safe predictable manner.";
  }
  constraint def C_009 {
    in faultDetectPct: Real;
    (faultDetectPct >= 90.0) and (faultDetectPct <= 100.0)
  }
  requirement def RQ_010 {
    text = "The system shall be portable and lightweight enough for a single person to transport and set up for practice.";
  }
  constraint def C_010 {
    in mass_kg: Real;
    (mass_kg >= 0.5) and (mass_kg <= 12.0)
  }
  requirement def RQ_011 {
    text = "The system shall tolerate dust dirt exposure and outdoor weather variability typical of practice environments and include protective measures for internal components.";
  }
  constraint def C_011 {
    in protectiveEnclosure: Boolean;
    protectiveEnclosure = true
  }
  requirement def RQ_012 {
    text = "The system shall be designed to achieve a target end user price range of 150 to 300 US dollars.";
  }
  constraint def C_012 {
    in targetPrice_USD: Real;
    (targetPrice_USD >= 150.0) and (targetPrice_USD <= 300.0)
  }
  requirement def RQ_013 {
    text = "The system shall provide an emergency stop function that immediately transitions the system to a safe state.";
  }
  constraint def C_013 {
    in eStopResponse_ms: Real;
    (eStopResponse_ms >= 0.0) and (eStopResponse_ms <= 500.0)
  }
}