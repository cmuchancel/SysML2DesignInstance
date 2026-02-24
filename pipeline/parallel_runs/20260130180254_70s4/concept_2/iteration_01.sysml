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

  part def MechanicalComponent {
    attribute mass_g: Real;
    attribute enclosureIngressIP: Real;
    attribute impactResistance_J: Real;
  }

  part def SensorSubsystem {
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
  }

  part def BallStoreSubsystem {
    attribute capacity_balls: Integer;
    attribute singleFeedGuarantee: Boolean;
    attribute jamDetection: Boolean;
  }

  part def BallFeedSubsystem {
    attribute feedConsistency_ms: Real;
    attribute max_cycle_rate_per_min: Real;
    attribute feed_motor_power_W: Real;
  }

  part def BallDeliverySubsystem {
    attribute toss_speed_mps: Real;
    attribute toss_speed_min_mps: Real;
    attribute toss_speed_max_mps: Real;
    attribute toss_height_m: Real;
    attribute toss_direction_deg: Real;
    attribute repeatability_cm: Real;
  }

  part def AimingSubsystem {
    attribute aim_resolution_deg: Real;
    attribute aim_range_deg: Real;
    attribute calibration_stability_minutes: Real;
  }

  part def ControlSubsystem {
    attribute cpu_mhz: Real;
    attribute firmware_storage_MB: Real;
    attribute realtime_cycle_ms: Real;
    attribute emergency_stop_present: Boolean;
    attribute fault_detection_latency_ms: Real;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute avg_power_W: Real;
    attribute rechargeable: Boolean;
    attribute runtime_hours: Real;
    attribute power_protection_present: Boolean;
  }

  part def ConnectivitySubsystem {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute radio_range_m: Real;
    attribute connectivity_availability_percent: Real;
  }

  part def StorageSubsystem {
    attribute log_capacity_MB: Real;
    attribute retention_hours: Real;
  }

  part def UserInterfaceSubsystem {
    attribute displaySize_in: Real;
    attribute physical_buttons: Integer;
    attribute leds_present: Boolean;
    attribute tactile_emergency_stop: Boolean;
  }

  part def EnclosureSubsystem {
    attribute footprint_mm2: Real;
    attribute stowed_volume_L: Real;
    attribute handle_integrated: Boolean;
    attribute durable_material: Boolean;
  }

  part def PortableSoftTossSystem {
    attribute name: String;
    part sensors: SensorSubsystem {
      pm25_min_ugm3: Real;
      pm25_max_ugm3: Real;
      pm25_resolution_ugm3: Real;
      pm25_accuracy_ugm3: Real;
      co2_min_ppm: Real;
      co2_max_ppm: Real;
      co2_accuracy_ppm: Real;
      temp_min_c: Real;
      temp_max_c: Real;
      temp_accuracy_c: Real;
      hum_min_percent: Real;
      hum_max_percent: Real;
      hum_accuracy_percent: Real;
    }
    part mech: MechanicalComponent {
      mass_g: Real;
      enclosureIngressIP: Real;
      impactResistance_J: Real;
    }
    part store: BallStoreSubsystem {
      capacity_balls: Integer;
      singleFeedGuarantee: Boolean;
      jamDetection: Boolean;
    }
    part feed: BallFeedSubsystem {
      feedConsistency_ms: Real;
      max_cycle_rate_per_min: Real;
      feed_motor_power_W: Real;
    }
    part delivery: BallDeliverySubsystem {
      toss_speed_mps: Real;
      toss_speed_min_mps: Real;
      toss_speed_max_mps: Real;
      toss_height_m: Real;
      toss_direction_deg: Real;
      repeatability_cm: Real;
    }
    part aim: AimingSubsystem {
      aim_resolution_deg: Real;
      aim_range_deg: Real;
      calibration_stability_minutes: Real;
    }
    part control: ControlSubsystem {
      cpu_mhz: Real;
      firmware_storage_MB: Real;
      realtime_cycle_ms: Real;
      emergency_stop_present: Boolean;
      fault_detection_latency_ms: Real;
    }
    part power: PowerSubsystem {
      batteryCapacity_mAh: Real;
      avg_power_W: Real;
      rechargeable: Boolean;
      runtime_hours: Real;
      power_protection_present: Boolean;
    }
    part comms: ConnectivitySubsystem {
      wifi_supported: Boolean;
      bluetooth_supported: Boolean;
      radio_range_m: Real;
      connectivity_availability_percent: Real;
    }
    part storage: StorageSubsystem {
      log_capacity_MB: Real;
      retention_hours: Real;
    }
    part ui: UserInterfaceSubsystem {
      displaySize_in: Real;
      physical_buttons: Integer;
      leds_present: Boolean;
      tactile_emergency_stop: Boolean;
    }
    part enclosure: EnclosureSubsystem {
      footprint_mm2: Real;
      stowed_volume_L: Real;
      handle_integrated: Boolean;
      durable_material: Boolean;
    }
  }

  constraint def C_runtime_budget {
    in batteryCapacity_mAh: Real;
    in avg_power_W: Real;
    in runtime_hours_target: Real;
    ( (batteryCapacity_mAh * 3.7 / 1000.0) / avg_power_W ) >= runtime_hours_target
  }

  constraint def C_sensing_ranges {
    in co2_max_ppm: Real;
    in pm25_max_ugm3: Real;
    (co2_max_ppm >= 5000.0)
  }

  constraint def C_connectivity_availability {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    in connectivity_availability_percent: Real;
    (wifi_supported == true) or (bluetooth_supported == true)
  }

  constraint def C_repeatability {
    in repeatability_cm: Real;
    (repeatability_cm <= 50.0)
  }

  constraint def C_portability_mass {
    in mass_g: Real;
    (mass_g <= 5000.0)
  }

  constraint def C_enclosure_protection {
    in enclosureIngressIP: Real;
    (enclosureIngressIP >= 4.0)
  }
}
