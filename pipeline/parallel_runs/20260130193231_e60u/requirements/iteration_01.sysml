package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "The system shall deliver a soft-toss ball to a batter to support batting practice.";
  }
  constraint def C_001 {
    in deliverableProvided: Boolean;
    deliverableProvided = true
  }

  requirement def RQ_002 {
    text = "The system shall provide a non-repetitive practice experience by varying toss outcomes rather than repeating a single fixed toss.";
  }
  constraint def C_002 {
    in variationEnabled: Boolean;
    in variationRange: Real;
    variationEnabled = true and variationRange >= 0.10
  }

  requirement def RQ_003 {
    text = "The system shall support use by players and coaches during practice sessions.";
  }
  constraint def C_003 {
    in supportedUsers: Integer;
    supportedUsers >= 1
  }

  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass/dirt fields, gymnasiums, and backyards.";
  }
  constraint def C_004 {
    in environments: Integer;
    environments >= 3
  }

  requirement def RQ_005 {
    text = "The system shall vary toss height, speed, and direction/angle across successive tosses.";
  }
  constraint def C_005 {
    in heightRange: Real;
    in speedRange: Real;
    in directionRangeDeg: Real;
    heightRange >= 0.30 and speedRange >= 1.0 and directionRangeDeg >= 10.0
  }

  requirement def RQ_006 {
    text = "The system shall deliver tosses to different locations within a user-defined target region appropriate for batting drills.";
  }
  constraint def C_006 {
    in targetRegionArea: Real;
    targetRegionArea >= 0.50
  }

  requirement def RQ_007 {
    text = "The system shall provide a user-defined toss interval and allow adjusting the interval during practice.";
  }
  constraint def C_007 {
    in intervalMin: Real;
    in intervalMax: Real;
    intervalMin >= 0.5 and intervalMax >= intervalMin
  }

  requirement def RQ_008 {
    text = "The system shall support a repeatable mode where toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_008 {
    in repeatabilityToleranceMeters: Real;
    repeatabilityToleranceMeters <= 0.50
  }

  requirement def RQ_009 {
    text = "The system shall detect or prevent common feed/launch faults and respond in a safe, predictable manner.";
  }
  constraint def C_009 {
    in faultDetect: Boolean;
    in safeResponse: Boolean;
    faultDetect = true and safeResponse = true
  }

  requirement def RQ_010 {
    text = "The system shall be portable and lightweight enough for a single person to transport and set up for practice.";
  }
  constraint def C_010 {
    in massKg: Real;
    in singlePersonTransportable: Boolean;
    massKg <= 18.0 and singlePersonTransportable = true
  }

  requirement def RQ_011 {
    text = "The system shall tolerate dust/dirt exposure and outdoor weather variability typical of practice environments.";
  }
  constraint def C_011 {
    in ingressProtectionLevel: Integer;
    ingressProtectionLevel >= 2
  }

  requirement def RQ_012 {
    text = "The system shall provide user controls for enabling/disabling operation, setting toss timing, and selecting variation of toss outcomes.";
  }
  constraint def C_012 {
    in controlFunctionsProvided: Integer;
    controlFunctionsProvided >= 3
  }

  requirement def RQ_013 {
    text = "The system shall provide an emergency stop that immediately transitions the system to a safe state.";
  }
  constraint def C_013 {
    in eStopPresent: Boolean;
    in eStopResponseTimeSec: Real;
    eStopPresent = true and eStopResponseTimeSec <= 0.5
  }

  requirement def RQ_014 {
    text = "The system shall be verifiable by tests for accuracy, repeatability, variation, environmental exposure, and single-person portability.";
  }
  constraint def C_014 {
    in verifiableAccuracy: Boolean;
    in verifiableRepeatability: Boolean;
    in verifiableVariation: Boolean;
    in verifiableEnvironment: Boolean;
    in verifiablePortability: Boolean;
    verifiableAccuracy = true and verifiableRepeatability = true and verifiableVariation = true and verifiableEnvironment = true and verifiablePortability = true
  }
}