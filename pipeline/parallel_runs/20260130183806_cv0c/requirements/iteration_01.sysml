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
    in variationEnabled: Boolean;
    variationEnabled = true
  }
  requirement def RQ_003 {
    text = "The system shall support use by players and coaches during practice sessions.";
  }
  constraint def C_003 {
    in stakeholdersSupported: Boolean;
    stakeholdersSupported = true
  }
  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass/dirt fields, gymnasiums, and backyards.";
  }
  constraint def C_004 {
    in environmentList: String;
    (environmentList = "grass") or (environmentList = "dirt") or (environmentList = "gymnasium") or (environmentList = "backyard")
  }
  requirement def RQ_005 {
    text = "The system shall deliver a regulation softball or equivalent practice ball from a machine output location toward a batter's hitting area.";
  }
  constraint def C_005 {
    in ballDiameter_mm: Real;
    (ballDiameter_mm >= 88.9) and (ballDiameter_mm <= 96.0)
  }
  requirement def RQ_006 {
    text = "The system shall be capable of varying toss height, speed, and direction across successive tosses.";
  }
  constraint def C_006 {
    in heightVar_cm: Real;
    (heightVar_cm >= 5.0) and (heightVar_cm <= 200.0)
  }
  requirement def RQ_007 {
    text = "The system shall be capable of delivering tosses to different locations within a user-defined target region appropriate for batting drills.";
  }
  constraint def C_007 {
    in targetRegion_m: Real;
    (targetRegion_m >= 0.5) and (targetRegion_m <= 3.0)
  }
  requirement def RQ_008 {
    text = "The system shall provide a user-defined toss interval including the ability to adjust the interval during practice.";
  }
  constraint def C_008 {
    in interval_s: Real;
    (interval_s >= 0.5) and (interval_s <= 30.0)
  }
  requirement def RQ_009 {
    text = "The system shall support a repeatable mode where toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_009 {
    in landingRepeatability_m: Real;
    (landingRepeatability_m >= 0.0) and (landingRepeatability_m <= 0.5)
  }
  requirement def RQ_010 {
    text = "The system shall prevent or detect common feed or launch faults and shall respond in a safe, predictable manner.";
  }
  constraint def C_010 {
    in faultDetectionRate_pct: Real;
    (faultDetectionRate_pct >= 90.0) and (faultDetectionRate_pct <= 100.0)
  }
  requirement def RQ_011 {
    text = "The system shall be portable and lightweight enough for a single person to transport and set up for practice.";
  }
  constraint def C_011 {
    in mass_kg: Real;
    (mass_kg >= 0.5) and (mass_kg <= 12.0)
  }
  requirement def RQ_012 {
    text = "The system shall tolerate dust dirt exposure and outdoor weather variability typical of practice environments.";
  }
  constraint def C_012 {
    in ingressProtection: String;
    (ingressProtection = "IP54") or (ingressProtection = "IP55") or (ingressProtection = "IP43")
  }
  requirement def RQ_013 {
    text = "The system shall provide user controls for enabling disabling operation setting toss timing and selecting or enabling variation of toss outcomes.";
  }
  constraint def C_013 {
    in controlSetPresent: Boolean;
    controlSetPresent = true
  }
  requirement def RQ_014 {
    text = "The system shall provide an emergency stop function that immediately transitions the system to a safe state.";
  }
  constraint def C_014 {
    in eStopResponse_ms: Real;
    (eStopResponse_ms >= 0.0) and (eStopResponse_ms <= 500.0)
  }
}