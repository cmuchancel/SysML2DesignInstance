package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be suitable for single-person hand carry and one-handed operation.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in volume_l: Real;
    in one_handed_operable: Boolean;
    ((mass_kg <= 1.5) and (volume_l <= 4.0) and (one_handed_operable == true))
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 for environmental-awareness during use.";
  }
  constraint def C_002 {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_accuracy_ug_m3: Real;
    in pm25_resolution_ug_m3: Real;
    ((pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_accuracy_ug_m3 <= 10.0) and (pm25_resolution_ug_m3 <= 1.0))
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall report ambient CO2 concentration to indicate ventilation conditions during practice.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    ((co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0))
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature to support environmental monitoring during use.";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_accuracy_C: Real;
    in temp_resolution_C: Real;
    ((temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_accuracy_C <= 1.0) and (temp_resolution_C <= 0.1))
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity to support environmental monitoring during use.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    in rh_resolution_pct: Real;
    ((rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0) and (rh_resolution_pct <= 1.0))
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for a full practice interval on internal rechargeable battery while wireless sync may be active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    in battery_rechargeable: Boolean;
    ((wireless_on == true) implies (runtime_hours >= 4.0)) and (battery_rechargeable == true)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization of measured environmental data via Wi-Fi or equivalent networked sync.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bt_supported: Boolean;
    ((wifi_supported == true) or (bt_supported == true))
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization of measured environmental data via Bluetooth or equivalent local sync.";
  }
  constraint def C_008 {
    in bt_supported: Boolean;
    in wifi_supported: Boolean;
    ((bt_supported == true) or (wifi_supported == true))
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def SoftTossMachine {
    attribute mass_kg: Real;
    attribute volume_l: Real;
    attribute modelName: String;

    part enclosure: Enclosure {
      attribute impact_resistance_J: Real;
      attribute ingress_rating_IP: Real;
      attribute material: String;
    }

    part power: PowerSubsystem {
      attribute batteryCapacity_mAh: Real;
      attribute avg_power_W: Real;
      attribute battery_rechargeable: Boolean;
      attribute emergency_stop_present: Boolean;
    }

    part compute: ComputeSubsystem {
      attribute mcu_MHz: Real;
      attribute flash_MB: Real;
      attribute control_loop_ms: Real;
      attribute runtime_hours: Real;
    }

    part motors: MotorDrive {
      attribute wheel1_max_rpm: Real;
      attribute wheel2_max_rpm: Real;
      attribute wheel1_nom_rpm: Real;
      attribute wheel2_nom_rpm: Real;
      attribute max_power_W: Real;
    }

    part ballHandling: BallHandlingSubsystem {
      attribute hopper_capacity_balls: Integer;
      attribute singulation_success_rate_pct: Real;
      attribute jam_detect_available: Boolean;
    }

    part feed: BallFeedSubsystem {
      attribute feed_rate_tosses_per_min: Real;
      attribute min_interval_s: Real;
      attribute max_interval_s: Real;
    }

    part delivery: BallDeliverySubsystem {
      attribute chute_angle_deg: Real;
      attribute launch_speed_m_s: Real;
      attribute launch_speed_variation_m_s: Real;
      attribute useful_range_m: Real;
    }

    part aiming: AimingSubsystem {
      attribute azimuth_range_deg: Real;
      attribute elevation_range_deg: Real;
      attribute aiming_repeatability_deg: Real;
    }

    part ui: UserInterfaceSubsystem {
      attribute displaySize_in: Real;
      attribute physical_controls_count: Integer;
      attribute has_status_leds: Boolean;
      attribute has_emergency_stop_button: Boolean;
    }

    part connectivity: ConnectivitySubsystem {
      attribute ble_supported: Boolean;
      attribute wifi_supported: Boolean;
      attribute connectivity_count: Integer;
      attribute ble_range_m: Real;
    }

    part storage: StorageSubsystem {
      attribute log_capacity_MB: Real;
      attribute sd_present: Boolean;
    }

    part protection: ElectricalProtectionSubsystem {
      attribute gnd_fault_protection: Boolean;
      attribute surge_protection_present: Boolean;
    }

    attribute expected_cycle_rate_cpm: Real;
  }

  part def Enclosure {
    attribute mass_kg: Real;
    attribute volume_l: Real;
    attribute ingress_rating_IP: Real;
    attribute handles_present: Boolean;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute avg_power_W: Real;
    attribute battery_rechargeable: Boolean;
    attribute max_charge_time_h: Real;
  }

  part def ComputeSubsystem {
    attribute mcu_MHz: Real;
    attribute flash_MB: Real;
    attribute control_loop_ms: Real;
    attribute runtime_hours: Real;
  }

  part def MotorDrive {
    attribute wheel1_max_rpm: Real;
    attribute wheel2_max_rpm: Real;
    attribute wheel1_nom_rpm: Real;
    attribute wheel2_nom_rpm: Real;
    attribute max_power_W: Real;
  }

  part def BallHandlingSubsystem {
    attribute hopper_capacity_balls: Integer;
    attribute singulation_success_rate_pct: Real;
    attribute jam_detect_available: Boolean;
  }

  part def BallFeedSubsystem {
    attribute feed_rate_tosses_per_min: Real;
    attribute min_interval_s: Real;
    attribute max_interval_s: Real;
  }

  part def BallDeliverySubsystem {
    attribute chute_angle_deg: Real;
    attribute launch_speed_m_s: Real;
    attribute launch_speed_variation_m_s: Real;
    attribute useful_range_m: Real;
  }

  part def AimingSubsystem {
    attribute azimuth_range_deg: Real;
    attribute elevation_range_deg: Real;
    attribute aiming_repeatability_deg: Real;
  }

  part def UserInterfaceSubsystem {
    attribute displaySize_in: Real;
    attribute physical_controls_count: Integer;
    attribute has_status_leds: Boolean;
    attribute has_emergency_stop_button: Boolean;
  }

  part def ConnectivitySubsystem {
    attribute ble_supported: Boolean;
    attribute wifi_supported: Boolean;
    attribute connectivity_count: Integer;
    attribute ble_range_m: Real;
  }

  part def StorageSubsystem {
    attribute log_capacity_MB: Real;
    attribute sd_present: Boolean;
  }

  part def ElectricalProtectionSubsystem {
    attribute gnd_fault_protection: Boolean;
    attribute surge_protection_present: Boolean;
  }

  constraint def C_runtime_battery {
    in batteryCapacity_mAh: Real;
    in avg_power_W: Real;
    in runtime_target_hours: Real;
    ((batteryCapacity_mAh * 3.7 / 1000) / avg_power_W) >= runtime_target_hours
  }

  constraint def C_sensing_co2_range {
    in co2Range_ppm: Real;
    in co2_target_min_ppm: Real;
    co2Range_ppm >= co2_target_min_ppm
  }

  constraint def C_connectivity_availability {
    in connectivity_count: Integer;
    in connectivity_required_min: Integer;
    connectivity_count >= connectivity_required_min
  }

  constraint def C_toss_rate {
    in expected_cycle_rate_cpm: Real;
    in min_cycle_rate_cpm: Real;
    expected_cycle_rate_cpm >= min_cycle_rate_cpm
  }

  constraint def C_portability_mass {
    in mass_kg: Real;
    in mass_target_kg: Real;
    mass_kg <= mass_target_kg
  }

  constraint def C_size_volume {
    in volume_l: Real;
    in volume_target_l: Real;
    volume_l <= volume_target_l
  }
}
