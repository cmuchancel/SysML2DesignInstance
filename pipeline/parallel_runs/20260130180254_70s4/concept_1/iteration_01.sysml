package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be portable for single-person carry and setup.";
  }
  constraint def C_001 {
    in mass_g: Real;
    (mass_g <= 500.0)
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall include a PM2.5 air-quality sensor to report particulate concentration near the device.";
  }
  constraint def C_002 {
    in pm25_min_ugm3: Real;
    in pm25_max_ugm3: Real;
    in pm25_resolution_ugm3: Real;
    in pm25_accuracy_ugm3: Real;
    (pm25_min_ugm3 <= 0.0) and (pm25_max_ugm3 >= 500.0) and (pm25_resolution_ugm3 <= 1.0) and (pm25_accuracy_ugm3 <= 10.0)
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall include a CO2 sensor to report ambient CO2 concentration relevant to indoor practice monitoring.";
  }
  constraint def C_003 {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature in typical practice ranges.";
  }
  constraint def C_004 {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_accuracy_c: Real;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_accuracy_c <= 1.0)
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity in typical practice ranges.";
  }
  constraint def C_005 {
    in hum_min_percent: Real;
    in hum_max_percent: Real;
    in hum_accuracy_percent: Real;
    (hum_min_percent <= 10.0) and (hum_max_percent >= 90.0) and (hum_accuracy_percent <= 5.0)
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate on an internal rechargeable battery while wireless sync is active for a practice-duration interval.";
  }
  constraint def C_006 {
    in rechargeable: Boolean;
    in wireless_on: Boolean;
    in runtime_hours: Real;
    (rechargeable == true) and (wireless_on == true) and (runtime_hours >= 4.0)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization of basic state and settings via Wi-Fi or an equivalent wireless link.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported == true) or (bluetooth_supported == true)
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization of basic state and settings via Bluetooth or an equivalent wireless link.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in wifi_supported: Boolean;
    (bluetooth_supported == true) or (wifi_supported == true)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Component {
    attribute name: String;
    attribute mass_g: Real;
  }

  part def System {
    attribute modelName: String;
    part sensing: EnvironmentalSensors;
    part compute: ComputeUnit;
    part power: PowerUnit;
    part connectivity: ConnectivityUnit;
    part storage: StorageUnit;
    part ui: UserInterface;
    part enclosure: Enclosure;
    part ballHandling: BallHandlingSubsystem;
    part ballFeed: BallFeedSubsystem;
    part ballDelivery: BallDeliverySubsystem;
    part aiming: AimingSubsystem;
    part timingControl: TimingControlSubsystem;
    part safety: SafetySubsystem;
  }

  part def EnvironmentalSensors extends Component { } 

  part def ComputeUnit {
    attribute cpuCycles_MIPS: Real;
    attribute ram_MB: Real;
    attribute flash_MB: Real;
    attribute mass_g: Real;
  }

  part def PowerUnit {
    attribute batteryCapacity_mAh: Real;
    attribute avg_power_W: Real;
    attribute rechargeable: Boolean;
    attribute mass_g: Real;
  }

  part def ConnectivityUnit {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute connectivityAvailability_percent: Real;
    attribute mass_g: Real;
  }

  part def StorageUnit {
    attribute flash_MB: Real;
    attribute sd_present: Boolean;
    attribute mass_g: Real;
  }

  part def UserInterface {
    attribute displaySize_in: Real;
    attribute controls_count: Integer;
    attribute emergencyStop_present: Boolean;
    attribute mass_g: Real;
  }

  part def Enclosure {
    attribute ingressProtection_IP: Real;
    attribute material_mass_g: Real;
    attribute mass_g: Real;
    attribute protective_shielding: Boolean;
  }

  part def BallHandlingSubsystem {
    attribute capacity_balls: Integer;
    attribute singlePresenting_mechanism: Boolean;
    attribute jamClearing_accessible: Boolean;
    attribute mass_g: Real;
  }

  part def BallFeedSubsystem {
    attribute feedConsistency_index: Real; // lower is better
    attribute feedCadence_max_per_min: Real;
    attribute mass_g: Real;
  }

  part def BallDeliverySubsystem {
    attribute tossSpeed_mps: Real;
    attribute tossSpeed_max_mps: Real;
    attribute tossHeight_m: Real;
    attribute tossAngle_deg: Real;
    attribute tossRepeatability_cm: Real;
    attribute usefulRange_m: Real;
    attribute mass_g: Real;
  }

  part def AimingSubsystem {
    attribute aimingResolution_deg: Real;
    attribute aimAdjustable_range_deg: Real;
    attribute aimRepeatability_deg: Real;
    attribute mass_g: Real;
  }

  part def TimingControlSubsystem {
    attribute minInterval_s: Real;
    attribute maxInterval_s: Real;
    attribute adjustableDuringRun: Boolean;
    attribute mass_g: Real;
  }

  part def SafetySubsystem {
    attribute emergencyStop_response_ms: Real;
    attribute guarding_present: Boolean;
    attribute impactTolerance_J: Real;
    attribute mass_g: Real;
  }

  part def EnvironmentalSensors {
    attribute pm25_min_ugm3: Real;
    attribute pm25_max_ugm3: Real;
    attribute pm25_resolution_ugm3: Real;
    attribute pm25_accuracy_ugm3: Real;
    attribute co2_min_ppm: Real;
    attribute co2_max_ppm: Real;
    attribute co2_accuracy_ppm: Real;
    attribute temp_min_c: Real;
    attribute temp_max_c: Real;
    attribute temp_accuracy_c: Real;
    attribute hum_min_percent: Real;
    attribute hum_max_percent: Real;
    attribute hum_accuracy_percent: Real;
    attribute mass_g: Real;
  }

  // Mid-level budget constraints and verification budgets

  constraint def C_runtime_budget {
    in batteryCapacity_mAh: Real;
    in avg_power_W: Real;
    // runtime_hours derived and required to be >= 4.0 hours
    ((batteryCapacity_mAh * 3.7 / 1000.0) / avg_power_W) >= 4.0
  }

  constraint def C_pm25_range {
    in pm25_max_ugm3: Real;
    pm25_max_ugm3 >= 500.0
  }

  constraint def C_co2_range {
    in co2_max_ppm: Real;
    co2_max_ppm >= 5000.0
  }

  constraint def C_connectivity_availability {
    in connectivityAvailability_percent: Real;
    connectivityAvailability_percent >= 95.0
  }

  constraint def C_toss_repeatability {
    in tossRepeatability_cm: Real;
    tossRepeatability_cm <= 10.0
  }

  constraint def C_mass_portability {
    in mass_g: Real;
    mass_g <= 9000.0
  }

}
