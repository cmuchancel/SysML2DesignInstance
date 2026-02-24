package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "The system shall deliver a pqr-toss xyz to a batter to support abc practice.";
  }
  constraint def C_001 {
    in delivers: Boolean;
    delivers = true
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
    in supportedUsers: String;
    supportedUsers = "players,coaches"
  }
  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass/dirt fields, gymnasiums, and backyards.";
  }
  constraint def C_004 {
    in supportedEnvironments: String;
    supportedEnvironments = "grass,dirt,gymnasium,backyard"
  }
  requirement def RQ_005 {
    text = "The system shall deliver a regulation pqrball (or equivalent practice xyz) from a machine output location toward a batter’s hitting area.";
  }
  constraint def C_005 {
    in deliversRegulation: Boolean;
    deliversRegulation = true
  }
  requirement def RQ_006 {
    text = "The system shall be capable of varying toss height, speed, and direction/angle across successive tosses.";
  }
  constraint def C_006 {
    in heightRange: Real;
    in speedRange: Real;
    in angleRange: Real;
    (heightRange >= 0.1) and (speedRange >= 0.1) and (angleRange >= 1.0)
  }
  requirement def RQ_007 {
    text = "The system shall be capable of delivering tosses to different locations within a user-defined target region appropriate for abc drills.";
  }
  constraint def C_007 {
    in targetRegionDefined: Boolean;
    in targetRegionArea: Real;
    targetRegionDefined = true and (targetRegionArea >= 0.5)
  }
  requirement def RQ_008 {
    text = "The system shall provide a user-defined toss interval (time between tosses), including the ability to adjust the interval during practice.";
  }
  constraint def C_008 {
    in minInterval: Real;
    in maxInterval: Real;
    in intervalAdjustableDuringOperation: Boolean;
    (minInterval >= 0.5) and (maxInterval <= 60.0) and intervalAdjustableDuringOperation = true
  }
  requirement def RQ_009 {
    text = "The system shall support a repeatable mode where, for a given configuration, toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_009 {
    in repeatabilityToleranceMeters: Real;
    in consistencyModeAvailable: Boolean;
    (repeatabilityToleranceMeters <= 0.5) and consistencyModeAvailable = true
  }
  requirement def RQ_010 {
    text = "The system shall prevent or detect common feed/launch faults (e.g., no-toss events, weak tosses, or multiple xyzs entering the launch path at once) and shall respond in a safe, predictable manner.";
  }
  constraint def C_010 {
    in faultDetectionRate: Real;
    in safeResponseAvailable: Boolean;
    (faultDetectionRate >= 0.90) and safeResponseAvailable = true
  }
  requirement def RQ_011 {
    text = "The system shall be portable and lightweight enough for a single person to transport and set up for practice.";
  }
  constraint def C_011 {
    in maxMassKg: Real;
    in singlePersonTransportable: Boolean;
    (maxMassKg <= 25.0) and singlePersonTransportable = true
  }
  requirement def RQ_012 {
    text = "The system shall tolerate dust/dirt exposure and outdoor weather variability typical of practice environments.";
  }
  constraint def C_012 {
    in ingressTolerant: Boolean;
    in operatingTempMinC: Real;
    in operatingTempMaxC: Real;
    ingressTolerant = true and (operatingTempMinC <= -10.0) and (operatingTempMaxC >= 40.0)
  }
  requirement def RQ_013 {
    text = "The system shall be designed to achieve a target end-user price range of $150–$300.";
  }
  constraint def C_013 {
    in targetPriceUSD: Real;
    (targetPriceUSD >= 150.0) and (targetPriceUSD <= 300.0)
  }
  requirement def RQ_014 {
    text = "The system shall provide an emergency stop function that immediately transitions the system to a safe state.";
  }
  constraint def C_014 {
    in emergencyStopAvailable: Boolean;
    in emergencyStopResponseTimeSec: Real;
    emergencyStopAvailable = true and (emergencyStopResponseTimeSec <= 1.0)
  }
}