package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "The system shall deliver a soft-toss ball to a batter to support batting practice.";
  }
  constraint def C_001 {
    in deliverable: Boolean;
    (deliverable = true)
  }
  requirement def RQ_002 {
    text = "The system shall provide a non-repetitive practice experience by varying toss outcomes rather than repeating a single fixed toss.";
  }
  constraint def C_002 {
    in variationModes: Integer;
    (variationModes >= 2)
  }
  requirement def RQ_003 {
    text = "The system shall support use by players and coaches during practice sessions.";
  }
  constraint def C_003 {
    in stakeholderSupport: Boolean;
    (stakeholderSupport = true)
  }
  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass dirt fields gymnasiums and backyards.";
  }
  constraint def C_004 {
    in operableEnvironments: Integer;
    (operableEnvironments >= 3)
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
    in heightVar_m: Real;
    (heightVar_m >= 0.1) and (heightVar_m <= 3.0)
  }
  requirement def RQ_007 {
    text = "The system shall be capable of delivering tosses to different locations within a user-defined target region appropriate for batting drills.";
  }
  constraint def C_007 {
    in targetRegionWidth_m: Real;
    (targetRegionWidth_m >= 0.5) and (targetRegionWidth_m <= 4.0)
  }
  requirement def RQ_008 {
    text = "The system shall provide a user-defined toss interval time between tosses including the ability to adjust the interval during practice.";
  }
  constraint def C_008 {
    in interval_s: Real;
    (interval_s >= 0.5) and (interval_s <= 30.0)
  }
  requirement def RQ_009 {
    text = "The system shall support a repeatable mode where for a given configuration toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_009 {
    in landingTolerance_m: Real;
    (landingTolerance_m >= 0.0) and (landingTolerance_m <= 0.5)
  }
  requirement def RQ_010 {
    text = "The system shall prevent or detect common feed launch faults such as no toss weak tosses or multiple balls entering the launch path and shall respond in a safe predictable manner.";
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
    text = "The system shall include protective measures to shield internal components from field conditions and weather exposure.";
  }
  constraint def C_012 {
    in protectiveEnclosure: Boolean;
    (protectiveEnclosure = true)
  }
  requirement def RQ_013 {
    text = "The system shall be designed to achieve a target end user price range of 150 to 300 US dollars.";
  }
  constraint def C_013 {
    in targetPrice_USD: Real;
    (targetPrice_USD >= 150.0) and (targetPrice_USD <= 300.0)
  }
  requirement def RQ_014 {
    text = "The system shall provide user controls for enabling disabling operation setting toss timing and selecting or enabling variation of toss outcomes.";
  }
  constraint def C_014 {
    in controlFunctions: Integer;
    (controlFunctions >= 3)
  }
  requirement def RQ_015 {
    text = "The system shall provide an emergency stop function that immediately transitions the system to a safe state.";
  }
  constraint def C_015 {
    in eStopResponse_ms: Real;
    (eStopResponse_ms >= 0.0) and (eStopResponse_ms <= 500.0)
  }
}