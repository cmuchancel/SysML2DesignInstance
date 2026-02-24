package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be suitable for single-person handheld transport and operation.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    (mass_kg <= 2.0)
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 to support air-quality-aware operation.";
  }
  constraint def C_002 {
    in pm25_accuracy_ug: Real;
    (pm25_accuracy_ug <= 5.0)
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration to inform indoor air conditions.";
  }
  constraint def C_003 {
    in co2_max_range_ppm: Real;
    (co2_max_range_ppm >= 2000.0)
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature to support environmental awareness.";
  }
  constraint def C_004 {
    in temp_accuracy_C: Real;
    (temp_accuracy_C <= 0.5)
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure relative humidity to support environmental awareness.";
  }
  constraint def C_005 {
    in rh_accuracy_pct: Real;
    (rh_accuracy_pct <= 3.0)
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate on an internal rechargeable battery for typical session use.";
  }
  constraint def C_006 {
    in runtime_hours: Real; in wireless_on: Boolean;
    (runtime_hours >= 8.0) and (wireless_on == true)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization over Wi-Fi to exchange data with external systems.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    (wifi_supported == true)
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization over Bluetooth to exchange data with external systems.";
  }
  constraint def C_008 {
    in bt_supported: Boolean;
    (bt_supported == true)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Component {
    attribute mass_kg: Real;
    attribute power_W: Real;
  }

  part def System {
    attribute system_mass_kg: Real;
    attribute target_price_USD: Real;
    part enclosure: Component {
      attribute material: String;
      attribute ingress_protection_IP: String;
      attribute handles_present: Boolean;
      attribute folded_volume_L: Real;
      attribute mass_kg: Real;
    }
    part powerPack: Component {
      attribute batteryCapacity_mAh: Real;
      attribute nominalVoltage_V: Real;
      attribute avg_draw_mA: Real;
      attribute recharge_time_hr: Real;
      attribute supports_fast_charge: Boolean;
    }
    part compute: Component {
      attribute mcu_type: String;
      attribute flash_MB: Real;
      attribute ram_MB: Real;
      attribute supports_profiles: Boolean;
    }
    part connectivity: Component {
      attribute wifi_supported: Boolean;
      attribute bt_supported: Boolean;
      attribute mesh_radio_supported: Boolean;
      attribute comm_range_m: Real;
    }
    part storage: Component {
      attribute profile_storage_MB: Real;
      attribute log_buffer_minutes: Real;
    }
    part ui: Component {
      attribute displaySize_in: Real;
      attribute physical_buttons: Integer;
      attribute emergency_stop_present: Boolean;
      attribute status_leds: Integer;
    }
    part sensors: Component {
      attribute imu_present: Boolean;
      attribute imu_sampling_Hz: Real;
      attribute ambient_temp_C: Real;
      attribute ambient_rh_pct: Real;
    }
    part ballStorage: Component {
      attribute capacity_balls: Integer;
      attribute single_feed_gate: Boolean;
      attribute anti_double_feed_mechanism: Boolean;
      attribute accessible_for_maintenance: Boolean;
    }
    part feedMechanism: Component {
      attribute feed_cycle_time_s: Real;
      attribute jam_detection: Boolean;
      attribute feed_success_rate_pct: Real;
    }
    part launcher: Component {
      attribute wheel_diameter_mm: Real;
      attribute wheel_count: Integer;
      attribute wheel_max_rpm: Real;
      attribute wheel_spinup_time_s: Real;
      attribute speed_max_mps: Real;
      attribute speed_min_mps: Real;
      attribute typical_launch_power_W: Real;
      attribute thermal_protection: Boolean;
      attribute expected_service_life_cycles: Real;
    }
    part aiming: Component {
      attribute yaw_range_deg: Real;
      attribute pitch_range_deg: Real;
      attribute gimbal_response_ms: Real;
      attribute aiming_repeatability_deg: Real;
      attribute aiming_lock_present: Boolean;
    }
    part safety: Component {
      attribute guarding_present: Boolean;
      attribute impact_resistance_J: Real;
      attribute emergency_stop_response_ms: Real;
      attribute fault_detection_present: Boolean;
    }
  }

  constraint def C_runtime {
    in batteryCapacity_mAh: Real;
    in avg_draw_mA: Real;
    (batteryCapacity_mAh / avg_draw_mA) >= 2.0
  }

  constraint def C_launch_speed {
    in speed_max_mps: Real;
    (speed_max_mps >= 8.0)
  }

  constraint def C_aiming_coverage {
    in yaw_range_deg: Real;
    (yaw_range_deg >= 30.0)
  }

  constraint def C_connectivity_wifi {
    in wifi_supported: Boolean;
    (wifi_supported == true)
  }

  constraint def C_portability_mass {
    in enclosure_mass_kg: Real;
    (enclosure_mass_kg <= 10.0)
  }

  constraint def C_feed_cycle_rate {
    in feed_cycle_time_s: Real;
    (feed_cycle_time_s <= 6.0)
  }
}
