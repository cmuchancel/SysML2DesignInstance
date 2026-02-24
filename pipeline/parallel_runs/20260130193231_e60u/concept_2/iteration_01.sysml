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
  import ScalarValues.*;

  part def MechanicalCamSpringSequencer {
    attribute conceptName: String;
    attribute massKg: Real;
    attribute packedVolume_m3: Real;
    attribute targetCost_USD: Real;
    part SpringEnergy springEnergy;
    part CamDrum camDrum;
    part LeverArm leverArm;
    part Magazine ballMagazine;
    part FeedGate feedGate;
    part AimingAdjust aimingAdjust;
    part TimingMechanism timingMechanism;
    part Enclosure enclosure;
    part UserControls userControls;
    part SafetyInterlock safetyInterlock;
    part CarryHandle carryHandle;
  }

  part def SpringEnergy {
    attribute springType: String;
    attribute storedEnergy_J: Real;
    attribute maxWindTurns: Integer;
    attribute windRequiredTurns: Integer;
    attribute manualCrankRequired: Boolean;
  }

  part def CamDrum {
    attribute camProfilesCount: Integer;
    attribute camProfileSelectionMechanical: Boolean;
    attribute camDiameter_mm: Real;
    attribute camLobeAngles_deg: Real;
    attribute drumMaterial: String;
  }

  part def LeverArm {
    attribute leverLength_mm: Real;
    attribute pivotFriction_Nm: Real;
    attribute tipVelocity_m_per_s: Real;
    attribute releaseAngle_deg: Real;
    attribute repeatabilityStdDev_m: Real;
  }

  part def Magazine {
    attribute capacityBalls: Integer;
    attribute feedOrientation: String;
    attribute ballRetentionMechanism: String;
    attribute jamClearAccess: Boolean;
    attribute singleBallPresentSensorMechanical: Boolean;
  }

  part def FeedGate {
    attribute antiDoubleFeedMechanical: Boolean;
    attribute gateCycleTime_s: Real;
    attribute feedReliabilityPct: Real;
    attribute manualJamClearable: Boolean;
  }

  part def AimingAdjust {
    attribute horizontalAdjustRange_deg: Real;
    attribute verticalAdjustRange_deg: Real;
    attribute adjustmentStep_deg: Real;
    attribute lockableSetting: Boolean;
    attribute aimingReferenceMarkPresent: Boolean;
  }

  part def TimingMechanism {
    attribute minInterval_s: Real;
    attribute maxInterval_s: Real;
    attribute adjustableOnTheFly: Boolean;
    attribute mechanicalCamSpacing: Integer;
    attribute cycleCapacityPerWind: Integer;
  }

  part def Enclosure {
    attribute ingressProtectionLevel: Integer;
    attribute material: String;
    attribute weatherResistantSeals: Boolean;
    attribute impactResistance_J: Real;
    attribute removablePanelsForMaintenance: Boolean;
  }

  part def UserControls {
    attribute enableDisableLeverPresent: Boolean;
    attribute tossTimingControlMechanical: Boolean;
    attribute variationSelectionKnobPresent: Boolean;
    attribute statusFlagsVisibleMechanical: Boolean;
    attribute eStopPullCablePresent: Boolean;
  }

  part def SafetyInterlock {
    attribute preventsLaunchWhenOpen: Boolean;
    attribute eStopResponseTime_s: Real;
    attribute guardingForMovingParts: Boolean;
    attribute safeStateOnFaultMechanical: Boolean;
  }

  part def CarryHandle {
    attribute handleLocation: String;
    attribute singlePersonCarrySuitable: Boolean;
    attribute foldableForStorage: Boolean;
  }

  constraint def EnergyBudget {
    in storedEnergy_J: Real;
    storedEnergy_J >= 15.0
  }

  constraint def PortabilityMass {
    in massKg: Real;
    massKg <= 18.0
  }

  constraint def RepeatabilityCheck {
    in repeatabilityStdDev_m: Real;
    repeatabilityStdDev_m <= 0.50
  }

  constraint def EmergencyStopResponse {
    in eStopResponseTime_s: Real;
    eStopResponseTime_s <= 0.5
  }

  constraint def CostTarget {
    in targetCost_USD: Real;
    targetCost_USD <= 300.0
  }
}
