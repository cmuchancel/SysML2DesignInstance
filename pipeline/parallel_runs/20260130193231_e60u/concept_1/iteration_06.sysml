package RequirementsOnly {
  private import ScalarValues::*;
  requirement def RQ_001 {
    text = "The system shall deliver a soft-toss ball to a batter to support batting practice.";
  }
  constraint def C_001 {
    in deliverableProvided: Boolean;
    deliverableProvided == true
  }

  requirement def RQ_002 {
    text = "The system shall provide a non-repetitive practice experience by varying toss outcomes rather than repeating a single fixed toss.";
  }
  constraint def C_002 {
    in variationEnabled: Boolean;
    in variationRangeMeters: Real;
    variationEnabled == true and variationRangeMeters >= 0.10
  }

  requirement def RQ_003 {
    text = "The system shall support use by players and coaches during practice sessions.";
  }
  constraint def C_003 {
    in supportsPlayers: Boolean;
    in supportsCoaches: Boolean;
    supportsPlayers == true and supportsCoaches == true
  }

  requirement def RQ_004 {
    text = "The system shall be operable in typical practice environments including grass/dirt fields, gymnasiums, and backyards.";
  }
  constraint def C_004 {
    in environmentTypesSupported: Integer;
    environmentTypesSupported >= 3
  }

  requirement def RQ_005 {
    text = "The system shall vary toss height, speed, and direction/angle across successive tosses.";
  }
  constraint def C_005 {
    in heightRangeMeters: Real;
    in speedRangeMetersPerSec: Real;
    in directionRangeDegrees: Real;
    heightRangeMeters >= 0.30 and speedRangeMetersPerSec >= 1.0 and directionRangeDegrees >= 10.0
  }

  requirement def RQ_006 {
    text = "The system shall deliver tosses to different locations within a user-defined target region appropriate for batting drills.";
  }
  constraint def C_006 {
    in targetRegionWidthMeters: Real;
    in targetRegionHeightMeters: Real;
    targetRegionWidthMeters >= 0.50 and targetRegionHeightMeters >= 0.50
  }

  requirement def RQ_007 {
    text = "The system shall provide a user-defined toss interval and allow adjusting the interval during practice.";
  }
  constraint def C_007 {
    in intervalMinSec: Real;
    in intervalMaxSec: Real;
    intervalMinSec >= 0.5 and intervalMaxSec >= intervalMinSec
  }

  requirement def RQ_008 {
    text = "The system shall support a repeatable mode where toss outcomes remain consistent within a defined tolerance for training drills.";
  }
  constraint def C_008 {
    in repeatabilityToleranceMeters: Real;
    repeatabilityToleranceMeters <= 0.50
  }

  requirement def RQ_009 {
    text = "The system shall detect or prevent common feed or launch faults and respond in a safe, predictable manner.";
  }
  constraint def C_009 {
    in faultDetectionPresent: Boolean;
    in safeResponsePresent: Boolean;
    faultDetectionPresent == true and safeResponsePresent == true
  }

  requirement def RQ_010 {
    text = "The system shall be portable and lightweight enough for a single person to transport and set up for practice.";
  }
  constraint def C_010 {
    in massKg: Real;
    in singlePersonTransportable: Boolean;
    massKg <= 18.0 and singlePersonTransportable == true
  }

  requirement def RQ_011 {
    text = "The system shall tolerate dust, dirt exposure, and outdoor weather variability typical of practice environments.";
  }
  constraint def C_011 {
    in ingressProtectionLevel: Integer;
    ingressProtectionLevel >= 2
  }

  requirement def RQ_012 {
    text = "The system shall provide user controls for enabling/disabling operation, setting toss timing, and selecting or enabling variation of toss outcomes.";
  }
  constraint def C_012 {
    in controlFunctionsCount: Integer;
    controlFunctionsCount >= 3
  }

  requirement def RQ_013 {
    text = "The system shall provide an emergency stop that immediately transitions the system to a safe state.";
  }
  constraint def C_013 {
    in eStopPresent: Boolean;
    in eStopResponseTimeSec: Real;
    eStopPresent == true and eStopResponseTimeSec <= 0.5
  }

  requirement def RQ_014 {
    text = "The system shall be verifiable by tests for accuracy, repeatability, variation, environmental exposure, and single-person portability.";
  }
  constraint def C_014 {
    in verAcc: Boolean;
    in verRep: Boolean;
    in verVar: Boolean;
    in verEnv: Boolean;
    in verPort: Boolean;
    verAcc == true and verRep == true and verVar == true and verEnv == true and verPort == true
  }
}

package ConceptDesign {
  import RequirementsOnly::*;
  import ScalarValues::*;

  part def SoftTossSystem {
    attribute systemMass_kg: Real;
    attribute batteryCapacity_mAh: Real;
    attribute nominalVoltage_V: Real;
    attribute maxContinuousCurrent_A: Real;
    attribute tossInterval_s: Real;
    attribute repeatability_mm: Real;
    attribute eStopResponseTime_s: Real;
    attribute ingressProtectionLevel: Integer;
    attribute costUSD: Real;
    attribute practiceSessionDuration_hr: Real;
  }

  part def BallStorage {
    attribute capacityBalls: Integer;
    attribute magazineAccess_openable: Boolean;
    attribute doubleFeedPreventionEnabled: Boolean;
    attribute storageSealRating_IP: Integer;
  }

  part def BallFeed {
    attribute feedMotorTorque_Nm: Real;
    attribute feedCycleTime_s: Real;
    attribute feedSensorPresent: Boolean;
    attribute jamClearanceAccess: Boolean;
  }

  part def DualWheelLauncher {
    attribute wheel1Speed_rpm: Real;
    attribute wheel2Speed_rpm: Real;
    attribute wheelDifferential_rpm: Real;
    attribute wheelDiameter_m: Real;
    attribute launchEnergy_J: Real;
    attribute maxWheelSpeed_rpm: Real;
    attribute wheelEncoderPresent: Boolean;
  }

  part def PanTiltAiming {
    attribute panAngle_deg: Real;
    attribute tiltAngle_deg: Real;
    attribute panRange_deg: Real;
    attribute tiltRange_deg: Real;
    attribute aimingResolution_deg: Real;
    attribute panMotorTorque_Nm: Real;
    attribute tiltMotorTorque_Nm: Real;
  }

  part def SensorsAndSense {
    attribute opticalBallSensorPresent: Boolean;
    attribute encoderResolution_cpr: Integer;
    attribute speedMeasurementError_pct: Real;
    attribute ballDetectLatency_ms: Real;
  }

  part def PowerAndElectrical {
    attribute batteryPackCells: Integer;
    attribute batteryMass_kg: Real;
    attribute batteryEnergy_Wh: Real;
    attribute chargerInput_V: Real;
    attribute electricalProtectionPresent: Boolean;
    attribute maxDischargeCurrent_A: Real;
  }

  part def ControlAndSafety {
    attribute microcontrollerType: String;
    attribute controlMode: String;
    attribute variationModeEnabled: Boolean;
    attribute eStopPresent: Boolean;
    attribute faultDetectionPresent: Boolean;
    attribute safeStateOnFault: Boolean;
  }

  part def UserInterface {
    attribute hasEnableDisableControl: Boolean;
    attribute hasIntervalControl: Boolean;
    attribute hasVariationSelect: Boolean;
    attribute feedbackIndicators_count: Integer;
    attribute uiIngressRating_IP: Integer;
  }

  part def EnclosureAndStructure {
    attribute enclosureMaterial: String;
    attribute impactResistance_J: Real;
    attribute packableVolume_L: Real;
    attribute carryHandlesPresent: Boolean;
    attribute enclosureIngressRating_IP: Integer;
  }

  constraint def MassAndPortability {
    in systemMass_kg: Real;
    systemMass_kg <= 18.0
  }

  constraint def BatteryCapacityMinimum {
    in batteryCapacity_mAh: Real;
    batteryCapacity_mAh >= 3000.0
  }

  constraint def WheelSpeedLimit {
    in maxWheelSpeed_rpm: Real;
    in wheel1Speed_rpm: Real;
    wheel1Speed_rpm <= maxWheelSpeed_rpm
  }

  constraint def EmergencyStopLatency {
    in eStopResponseTime_s: Real;
    eStopResponseTime_s <= 0.5
  }

  constraint def RepeatabilityRequirement {
    in repeatability_mm: Real;
    repeatability_mm <= 50.0
  }
}
