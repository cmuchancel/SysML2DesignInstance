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
    attribute mass_g: Real;
    attribute volume_cc: Real;
  }

  part def SensingSubsystem {
    attribute imu_present: Boolean;
    attribute distanceSensor_range_m: Real;
    attribute co2Sensor_present: Boolean;
    attribute co2_max_ppm: Real;
    attribute pm25_present: Boolean;
    attribute temp_sensor_present: Boolean;
  }

  part def ComputeSubsystem {
    attribute cpu_mhz: Real;
    attribute ram_mb: Real;
    attribute flash_mb: Real;
    attribute control_loop_hz: Real;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute avg_power_W: Real;
    attribute rechargeable: Boolean;
    attribute runtime_hours: Real;
  }

  part def ConnectivitySubsystem {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute link_availability_percent: Real;
  }

  part def StorageSubsystem {
    attribute ball_reservoir_count: Integer;
    attribute feed_hopper_capacity: Integer;
    attribute storage_flash_mb: Real;
  }

  part def UserInterfaceSubsystem {
    attribute displaySize_in: Real;
    attribute buttons_count: Integer;
    attribute led_feedback_count: Integer;
  }

  part def EnclosureSubsystem {
    attribute mass_g: Real;
    attribute ip_rating: String;
    attribute impact_resistance_j: Real;
    attribute stow_dimensions_cm3: Real;
  }

  part def BallHandlingSubsystem {
    attribute single_feed_guarantee: Boolean;
    attribute jam_detection: Boolean;
    attribute feed_interval_s: Real;
    attribute feed_consistency_tolerance_cm: Real;
  }

  part def BallDeliverySubsystem {
    attribute tossSpeed_mps: Real;
    attribute tossAngle_deg: Real;
    attribute tossHeight_m: Real;
    attribute repeatability_sd_cm: Real;
    attribute useful_distance_m: Real;
  }

  part def AimingSubsystem {
    attribute azimuth_range_deg: Real;
    attribute elevation_range_deg: Real;
    attribute aiming_resolution_deg: Real;
    attribute stable_reference_present: Boolean;
  }

  part def SafetyUISubsystem {
    attribute emergency_stop_present: Boolean;
    attribute guarding_present: Boolean;
    attribute fault_state_indicator_present: Boolean;
  }

  part def System {
    part sensing: SensingSubsystem {
      attribute co2_max_ppm: Real;
      attribute pm25_range_max_ugm3: Real;
    }
    part compute: ComputeSubsystem {
      attribute control_loop_hz: Real;
      attribute cpu_mhz: Real;
    }
    part power: PowerSubsystem {
      attribute batteryCapacity_mAh: Real;
      attribute avg_power_W: Real;
      attribute runtime_hours: Real;
      attribute rechargeable: Boolean;
    }
    part connectivity: ConnectivitySubsystem {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute link_availability_percent: Real;
    }
    part storage: StorageSubsystem {
      attribute ball_reservoir_count: Integer;
      attribute storage_flash_mb: Real;
    }
    part ui: UserInterfaceSubsystem {
      attribute displaySize_in: Real;
      attribute buttons_count: Integer;
      attribute led_feedback_count: Integer;
    }
    part enclosure: EnclosureSubsystem {
      attribute mass_g: Real;
      attribute ip_rating: String;
      attribute stow_dimensions_cm3: Real;
      attribute impact_resistance_j: Real;
    }
    part ballHandling: BallHandlingSubsystem {
      attribute single_feed_guarantee: Boolean;
      attribute jam_detection: Boolean;
      attribute feed_interval_s: Real;
    }
    part delivery: BallDeliverySubsystem {
      attribute tossSpeed_mps: Real;
      attribute tossAngle_deg: Real;
      attribute tossHeight_m: Real;
      attribute repeatability_sd_cm: Real;
      attribute useful_distance_m: Real;
    }
    part aiming: AimingSubsystem {
      attribute azimuth_range_deg: Real;
      attribute elevation_range_deg: Real;
      attribute aiming_resolution_deg: Real;
      attribute stable_reference_present: Boolean;
    }
    part safetyUI: SafetyUISubsystem {
      attribute emergency_stop_present: Boolean;
      attribute guarding_present: Boolean;
      attribute fault_state_indicator_present: Boolean;
    }
  }

  constraint def C_runtime {
    in runtime_hours: Real;
    (runtime_hours >= 4.0)
  }

  constraint def C_co2_sensing_range {
    in co2_max_ppm: Real;
    (co2_max_ppm >= 5000.0)
  }

  constraint def C_connectivity_available {
    in wifi_supported: Boolean;
    (wifi_supported == true)
  }

  constraint def C_repeatability_budget {
    in repeatability_sd_cm: Real;
    (repeatability_sd_cm <= 10.0)
  }

  constraint def C_mass_portability {
    in mass_g: Real;
    (mass_g <= 7000.0)
  }
}
