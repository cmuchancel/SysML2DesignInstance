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
  private import RequirementsOnly::*;
  private import ScalarValues::*;

  partdef PneumaticPulseLauncher {
    attribute systemMass_kg: Real;
    attribute foldedDimensions_cm: String;
    attribute handlePresent: Boolean;
    attribute expectedOperatingDistance_m: Real;
    attribute requiredCycleRate_perMin: Integer;
    attribute achievableCycleRate_perMin: Integer;
    attribute repeatabilityTolerance_m: Real;
    attribute targetPriceUSD: Real;
    attribute singlePersonTransportable: Boolean;
  }

  partdef Structure_Enclosure {
    attribute ingressProtectionLevel: Integer;
    attribute chassisMaterial: String;
    attribute protectiveSealsPresent: Boolean;
    attribute impactTolerance_J: Real;
    attribute stowFootprint_cm2: String;
  }

  partdef Power_System {
    attribute powerSourceType: String;
    attribute batteryCapacity_mAh: Real;
    attribute compressorPower_W: Real;
    attribute supportsCO2Cartridge: Boolean;
    attribute externalPowerInput_V: Real;
  }

  partdef Pneumatic_Reservoir {
    attribute reservoirVolume_L: Real;
    attribute reservoirPressure_psi: Real;
    attribute maxPressure_psi: Real;
    attribute pressureRegulatorPresent: Boolean;
    attribute reservoirMaterial: String;
  }

  partdef Valve_And_Pulse {
    attribute solenoidValveResponse_ms: Real;
    attribute pulseDuration_ms: Real;
    attribute pulseRepeatability_ms: Real;
    attribute valveRatedCycles: Integer;
    attribute valveFailSafeEnabled: Boolean;
  }

  partdef Nozzle_Aiming {
    attribute nozzleAngle_elev_deg: Real;
    attribute nozzleAngle_azim_deg: Real;
    attribute nozzleAngleRepeatability_deg: Real;
    attribute servoTorque_Nm: Real;
    attribute aimingRange_deg: Real;
  }

  partdef Ball_Clamp_And_Feed {
    attribute magazineCapacity: Integer;
    attribute clampForce_N: Real;
    attribute feedCycleTime_ms: Real;
    attribute doubleFeedPreventionEnabled: Boolean;
    attribute jamClearingAccessPresent: Boolean;
  }

  partdef Sensors {
    attribute opticalFeedSensorPresent: Boolean;
    attribute pressureSensorPresent: Boolean;
    attribute imuPresent: Boolean;
    attribute sensorFaultDetected: Boolean;
    attribute sensorSampleRate_Hz: Real;
  }

  partdef Control_ECUs {
    attribute microcontrollerModel: String;
    attribute controlMode: String;
    attribute storedVariationProfiles: Integer;
    attribute realTimeFaultDetectionEnabled: Boolean;
    attribute userAdjustableParametersCount: Integer;
  }

  partdef User_Interface {
    attribute physicalEStopPresent: Boolean;
    attribute tossInterval_sec: Real;
    attribute controlModeSelector: String;
    attribute statusIndicatorsPresent: Boolean;
    attribute mobileAppSupported: Boolean;
  }

  partdef Safety_Systems {
    attribute eStopResponseTime_sec: Real;
    attribute guardingEnabled: Boolean;
    attribute safeStateOnFault: Boolean;
    attribute lockoutDuringMaintenance: Boolean;
  }

  partdef Maintenance_Access {
    attribute servicePanelsAccessible: Boolean;
    attribute commonToolsOnly: Boolean;
    attribute wearPartReplacementTime_min: Real;
    attribute recommendedMaintenanceInterval_hours: Real;
  }

  constraint def Energy_Budget {
    in batteryCapacity_mAh: Real;
    batteryCapacity_mAh >= 2000
  }

  constraint def Runtime_Target {
    in requiredContinuousRunMin: Real;
    in achievableContinuousRunMin: Real;
    achievableContinuousRunMin >= requiredContinuousRunMin
  }

  constraint def Pressure_Limits {
    in reservoirPressure_psi: Real;
    in maxPressure_psi: Real;
    reservoirPressure_psi <= maxPressure_psi
  }

  constraint def CycleRate_Performance {
    in achievableCycleRate_perMin: Integer;
    in requiredCycleRate_perMin: Integer;
    achievableCycleRate_perMin >= requiredCycleRate_perMin
  }

  constraint def Safety_Interlock {
    in eStopResponseTime_sec: Real;
    eStopResponseTime_sec <= 0.5
  }
}
