package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "The system shall deliver a pqr-toss xyz to a batter to support abc practice.";
  }
  constraint def C_001 {
    in delivers: Boolean;
    (delivers == true)
  }
  requirement def RQ_002 {
    text = "The system shall provide a non-repetitive practice experience by varying toss outcomes rather than repeating a single fixed toss.";
  }
  constraint def C_002 {
    in variationEnabled: Boolean;
    (variationEnabled == true)
  }
  requirement def RQ_003 {
    text = "The system shall support use by players and coaches during practice sessions.";
  }
  constraint def C_003 {
    in supportsPlayers: Boolean;
    in supportsCoaches: Boolean;
    ((supportsPlayers == true) and (supportsCoaches == true))
  }
  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass/dirt fields, gymnasiums, and backyards.";
  }
  constraint def C_004 {
    in envGrassOK: Boolean;
    in envDirtOK: Boolean;
    in envGymnasiumOK: Boolean;
    in envBackyardOK: Boolean;
    ((envGrassOK == true) and (envDirtOK == true) and (envGymnasiumOK == true) and (envBackyardOK == true))
  }
  requirement def RQ_005 {
    text = "The system shall deliver a regulation pqrball (or equivalent practice xyz) from a machine output location toward a batter’s hitting area.";
  }
  constraint def C_005 {
    in deliversRegulation: Boolean;
    (deliversRegulation == true)
  }
  requirement def RQ_006 {
    text = "The system shall be capable of varying toss height, speed, and direction/angle across successive tosses.";
  }
  constraint def C_006 {
    in heightRangeMeters: Real;
    in speedRangeMps: Real;
    in angleRangeDeg: Real;
    ((heightRangeMeters >= 0.1) and (speedRangeMps >= 0.1) and (angleRangeDeg >= 1.0))
  }
  requirement def RQ_007 {
    text = "The system shall be capable of delivering tosses to different locations within a user-defined target region appropriate for abc drills.";
  }
  constraint def C_007 {
    in targetRegionDefined: Boolean;
    in targetRegionAreaSqM: Real;
    ((targetRegionDefined == true) and (targetRegionAreaSqM >= 0.5))
  }
  requirement def RQ_008 {
    text = "The system shall provide a user-defined toss interval (time between tosses), including the ability to adjust the interval during practice.";
  }
  constraint def C_008 {
    in minIntervalSec: Real;
    in maxIntervalSec: Real;
    in intervalAdjustableDuringOperation: Boolean;
    ((minIntervalSec >= 0.5) and (maxIntervalSec <= 60.0) and (intervalAdjustableDuringOperation == true))
  }
  requirement def RQ_009 {
    text = "The system shall support a repeatable mode where, for a given configuration, toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_009 {
    in repeatabilityToleranceMeters: Real;
    in consistencyModeAvailable: Boolean;
    ((repeatabilityToleranceMeters <= 0.5) and (consistencyModeAvailable == true))
  }
  requirement def RQ_010 {
    text = "The system shall prevent or detect common feed/launch faults (e.g., no-toss events, weak tosses, or multiple xyzs entering the launch path at once) and shall respond in a safe, predictable manner.";
  }
  constraint def C_010 {
    in faultDetectionRate: Real;
    in safeResponseAvailable: Boolean;
    ((faultDetectionRate >= 0.90) and (safeResponseAvailable == true))
  }
  requirement def RQ_011 {
    text = "The system shall be portable and lightweight enough for a single person to transport and set up for practice.";
  }
  constraint def C_011 {
    in maxMassKg: Real;
    in singlePersonTransportable: Boolean;
    ((maxMassKg <= 25.0) and (singlePersonTransportable == true))
  }
  requirement def RQ_012 {
    text = "The system shall tolerate dust/dirt exposure and outdoor weather variability typical of practice environments.";
  }
  constraint def C_012 {
    in ingressTolerant: Boolean;
    in operatingTempMinC: Real;
    in operatingTempMaxC: Real;
    ((ingressTolerant == true) and (operatingTempMinC <= -10.0) and (operatingTempMaxC >= 40.0))
  }
  requirement def RQ_013 {
    text = "The system shall be designed to achieve a target end-user price range of $150–$300.";
  }
  constraint def C_013 {
    in targetPriceUSD: Real;
    ((targetPriceUSD >= 150.0) and (targetPriceUSD <= 300.0))
  }
  requirement def RQ_014 {
    text = "The system shall provide an emergency stop function that immediately transitions the system to a safe state.";
  }
  constraint def C_014 {
    in emergencyStopAvailable: Boolean;
    in emergencyStopResponseTimeSec: Real;
    ((emergencyStopAvailable == true) and (emergencyStopResponseTimeSec <= 1.0))
  }
}

package ConceptDesign {
  import RequirementsOnly::*;
  import ScalarValues::*;

  part def PneumaticPlungerTosser {
    attribute modelName: String;
    attribute mass_kg: Real;
    attribute price_USD: Real;
    attribute ingressTolerant: Boolean;
    attribute singlePersonTransportable: Boolean;
    attribute repeatability_mm: Real;
    attribute faultDetectionRate: Real;
    attribute emergencyStopAvailable: Boolean;
    attribute emergencyStopResponseTimeSec: Real;

    part def Actuation_PneumaticPlunger {
      attribute plungerStroke_mm: Real;
      attribute plungerPistonDiameter_mm: Real;
      attribute plungerPressure_kPa: Real;
      attribute maxPlungerForce_N: Real;
      attribute shotEnergyJ: Real;
      attribute shotCycleSec: Real;
      attribute solenoidValveResponseMs: Real;
      attribute accumulatorVolume_L: Real;
    };

    part def Feed_RotaryMagazine {
      attribute magazineCapacity: Integer;
      attribute currentLoadDetected: Boolean;
      attribute doubleFeedDetectEnabled: Boolean;
      attribute feedIndexSpeed_rpm: Real;
      attribute jamDetected: Boolean;
      attribute feedPresentSensorLatencyMs: Real;
    };

    part def Delivery_GuideTube {
      attribute guideLength_mm: Real;
      attribute guideInnerDiameter_mm: Real;
      attribute plungerPadMaterial: String;
      attribute tossSpeed_mps: Real;
      attribute tossAngle_deg: Real;
      attribute usableRange_m: Real;
    };

    part def Power_Onboard {
      attribute batteryCapacity_mAh: Real;
      attribute backupCapacitor_mF: Real;
      attribute compressorPower_W: Real;
      attribute peakCompressorCurrent_A: Real;
      attribute averageCurrentDraw_mA: Real;
      attribute mainsAdapterIncluded: Boolean;
    };

    part def Control_TimingAiming {
      attribute controlMode: String;
      attribute intervalSecMin: Real;
      attribute intervalSecMax: Real;
      attribute intervalAdjustableDuringOperation: Boolean;
      attribute variationEnabled: Boolean;
      attribute consistencyModeAvailable: Boolean;
      attribute wifiEnabled: Boolean;
      attribute calibrationDone: Boolean;
    };

    part def Sensing_Safety {
      attribute shotVelocitySensorAvailable: Boolean;
      attribute ballPresenceSensorAvailable: Boolean;
      attribute pressureSensor_kPa: Real;
      attribute faultDetectionTimeoutSec: Real;
      attribute safeStateEngaged: Boolean;
    };

    part def UI_WiFiTablet {
      attribute uiControlAppProvided: Boolean;
      attribute wifiSignalStrength_dBm: Real;
      attribute statusIndicators: String;
      attribute userSelectablePressure_kPa: Real;
      attribute userSelectableCadenceSec: Real;
      attribute userSelectableVariationProfile: String;
    };

    part def Enclosure_PortableRugged {
      attribute enclosureMaterial: String;
      attribute ingressProtectionCode: String;
      attribute handleIntegrated: Boolean;
      attribute foldedStowVolume_L: Real;
      attribute impactTolerance_J: Real;
    };

    part def Maintenance_Access {
      attribute routineToolsRequired: String;
      attribute accessPanelsToolless: Boolean;
      attribute wearPartReplaceIntervalCycles: Integer;
    };
  };

  constraint def C_mass_portability {
    in mass_kg: Real;
    (mass_kg <= 25.0)
  }

  constraint def C_price_target {
    in price_USD: Real;
    (price_USD >= 150.0 and price_USD <= 300.0)
  }

  constraint def C_emergency_stop {
    in emergencyStopAvailable: Boolean;
    in emergencyStopResponseTimeSec: Real;
    ((emergencyStopAvailable == true) and (emergencyStopResponseTimeSec <= 1.0))
  }

  constraint def C_environment_ingress {
    in ingressTolerant: Boolean;
    (ingressTolerant == true)
  }

  constraint def C_repeatability {
    in repeatability_mm: Real;
    (repeatability_mm <= 500.0)
  }
}
