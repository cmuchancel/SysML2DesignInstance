package RequirementsOnly {
  private import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device shall be portable for single-person transport with mass <= 3.0 kg and maximum envelope volume <= 8.0 liters.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in volume_liters: Real;
    (mass_kg <= 3.0) and (volume_liters <= 8.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 concentration in ambient air for basic environmental awareness during use.";
  }
  constraint def C_002 {
    in pm25_supported: Boolean;
    in pm25_range_ugm3_min: Real;
    in pm25_range_ugm3_max: Real;
    pm25_supported and (pm25_range_ugm3_min <= 0.0 and pm25_range_ugm3_max >= 500.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration to identify elevated indoor levels affecting user comfort.";
  }
  constraint def C_003 {
    in co2_supported: Boolean;
    in co2_range_ppm_min: Real;
    in co2_range_ppm_max: Real;
    co2_supported and (co2_range_ppm_min <= 400.0 and co2_range_ppm_max >= 5000.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient air temperature for environmental context during practice.";
  }
  constraint def C_004 {
    in temp_supported: Boolean;
    in temp_range_C_min: Real;
    in temp_range_C_max: Real;
    temp_supported and (temp_range_C_min <= -10.0 and temp_range_C_max >= 50.0)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity for environmental context during practice.";
  }
  constraint def C_005 {
    in rh_supported: Boolean;
    in rh_range_percent_min: Real;
    in rh_range_percent_max: Real;
    rh_supported and (rh_range_percent_min <= 0.0 and rh_range_percent_max >= 100.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for at least 6.0 hours with wireless radios active under typical practice load.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    wireless_on and (runtime_hours >= 6.0)
  }
  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support Wi-Fi synchronization capability to external devices or services for practice session data exchange or control.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    wifi_supported or bluetooth_supported
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support Bluetooth Low Energy synchronization capability to external devices for local control or data exchange.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in wifi_supported: Boolean;
    bluetooth_supported or wifi_supported
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Component {
    attribute mass_kg: Real;
    attribute volume_liters: Real;
  }

  part def System {
    attribute transport_mass_kg: Real;
    attribute envelope_volume_liters: Real;
    part power: PowerSubsystem {
      attribute batteryCapacity_mAh: Real;
      attribute runtime_hours: Real;
      attribute avg_power_W: Real;
      attribute supports_rechargeable: Boolean;
    }
    part compute: ComputeSubsystem {
      attribute mcu_MHz: Real;
      attribute flash_MB: Real;
      attribute ram_MB: Real;
      attribute faultDetected: Boolean;
    }
    part sensing: SensingSubsystem {
      attribute pm25_supported: Boolean;
      attribute pm25_range_ugm3_min: Real;
      attribute pm25_range_ugm3_max: Real;
      attribute co2_supported: Boolean;
      attribute co2_range_ppm_min: Real;
      attribute co2_range_ppm_max: Real;
      attribute temp_supported: Boolean;
      attribute temp_range_C_min: Real;
      attribute temp_range_C_max: Real;
      attribute rh_supported: Boolean;
      attribute rh_range_percent_min: Real;
      attribute rh_range_percent_max: Real;
    }
    part storage: StorageSubsystem {
      attribute log_capacity_entries: Real;
      attribute persistent_storage_MB: Real;
    }
    part connectivity: ConnectivitySubsystem {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute connectivity_options_count: Real;
      attribute ble_range_m: Real;
      attribute wifi_range_m: Real;
    }
    part ui: UIsubsystem {
      attribute display_in: Real;
      attribute controls_present: Boolean;
      attribute emergency_stop_present: Boolean;
      attribute user_feedback_states: Real;
    }
    part enclosure: EnclosureSubsystem {
      attribute ingress_protection_rating_IP: Real;
      attribute impact_resistance_J: Real;
      attribute dust_tolerant: Boolean;
      attribute weather_tolerant: Boolean;
      attribute handle_integrated: Boolean;
    }
    part ballStore: BallHandlingSubsystem {
      attribute capacity_balls: Real;
      attribute singulation_gate_present: Boolean;
      attribute jam_detection: Boolean;
      attribute clearing_accessible: Boolean;
    }
    part feed: FeedSubsystem {
      attribute feed_rate_sps: Real;
      attribute single_feed_reliability_pct: Real;
      attribute double_feed_prevention: Boolean;
    }
    part launcher: LauncherSubsystem {
      attribute wheel1_RPM: Real;
      attribute wheel2_RPM: Real;
      attribute wheel_diameter_mm: Real;
      attribute toss_speed_mps: Real;
      attribute toss_angle_deg: Real;
      attribute repeatability_mm: Real;
      attribute cycle_rate_cps: Real;
    }
    part aiming: AimingSubsystem {
      attribute adjustable_angle_deg_min: Real;
      attribute adjustable_angle_deg_max: Real;
      attribute targeting_region_width_m: Real;
      attribute targeting_region_height_m: Real;
      attribute aiming_stability_deg: Real;
    }
    part timingControl: TimingControlSubsystem {
      attribute user_set_interval_s: Real;
      attribute min_interval_s: Real;
      attribute max_interval_s: Real;
      attribute variation_enabled: Boolean;
      attribute consistency_mode_enabled: Boolean;
    }
    part safety: SafetySubsystem {
      attribute emergency_stop_latency_ms: Real;
      attribute guarding_present: Boolean;
      attribute safe_fault_response_enabled: Boolean;
    }
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute runtime_hours: Real;
    attribute avg_power_W: Real;
    attribute weight_kg: Real;
  }

  part def ComputeSubsystem {
    attribute mcu_MHz: Real;
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute power_draw_W: Real;
  }

  part def SensingSubsystem {
    attribute pm25_supported: Boolean;
    attribute pm25_range_ugm3_min: Real;
    attribute pm25_range_ugm3_max: Real;
    attribute co2_supported: Boolean;
    attribute co2_range_ppm_min: Real;
    attribute co2_range_ppm_max: Real;
    attribute temp_supported: Boolean;
    attribute temp_range_C_min: Real;
    attribute temp_range_C_max: Real;
    attribute rh_supported: Boolean;
    attribute rh_range_percent_min: Real;
    attribute rh_range_percent_max: Real;
  }

  part def StorageSubsystem {
    attribute persistent_storage_MB: Real;
    attribute log_capacity_entries: Real;
  }

  part def ConnectivitySubsystem {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute connectivity_options_count: Real;
    attribute ble_range_m: Real;
    attribute wifi_range_m: Real;
  }

  part def UIsubsystem {
    attribute display_in: Real;
    attribute controls_present: Boolean;
    attribute emergency_stop_present: Boolean;
    attribute tactile_buttons: Boolean;
  }

  part def EnclosureSubsystem {
    attribute ingress_protection_rating_IP: Real;
    attribute impact_resistance_J: Real;
    attribute mass_kg: Real;
    attribute volume_liters: Real;
    attribute handle_integrated: Boolean;
  }

  part def BallHandlingSubsystem {
    attribute capacity_balls: Real;
    attribute singulation_gate_present: Boolean;
    attribute jam_detection: Boolean;
    attribute access_for_maintenance: Boolean;
  }

  part def FeedSubsystem {
    attribute feed_rate_sps: Real;
    attribute single_feed_reliability_pct: Real;
    attribute double_feed_prevention: Boolean;
  }

  part def LauncherSubsystem {
    attribute wheel1_RPM: Real;
    attribute wheel2_RPM: Real;
    attribute wheel_diameter_mm: Real;
    attribute toss_speed_mps: Real;
    attribute toss_angle_deg: Real;
    attribute repeatability_mm: Real;
    attribute cycle_rate_cps: Real;
    attribute motor_power_W: Real;
  }

  part def AimingSubsystem {
    attribute adjustable_angle_deg_min: Real;
    attribute adjustable_angle_deg_max: Real;
    attribute targeting_region_width_m: Real;
    attribute targeting_region_height_m: Real;
    attribute aiming_stability_deg: Real;
  }

  part def TimingControlSubsystem {
    attribute user_set_interval_s: Real;
    attribute min_interval_s: Real;
    attribute max_interval_s: Real;
    attribute variation_enabled: Boolean;
    attribute consistency_mode_enabled: Boolean;
  }

  part def SafetySubsystem {
    attribute emergency_stop_latency_ms: Real;
    attribute guarding_present: Boolean;
    attribute safe_fault_response_enabled: Boolean;
    attribute safe_state_enabled: Boolean;
  }

  constraint def C_runtime {
    in runtime_hours: Real;
    runtime_hours >= 6.0
  }

  constraint def C_co2Range {
    in co2_range_ppm_max: Real;
    co2_range_ppm_max >= 5000.0
  }

  constraint def C_connectivityOptions {
    in connectivity_options_count: Real;
    connectivity_options_count >= 1.0
  }

  constraint def C_portability_mass {
    in transport_mass_kg: Real;
    transport_mass_kg <= 3.0
  }

  constraint def C_portability_volume {
    in envelope_volume_liters: Real;
    envelope_volume_liters <= 8.0
  }

  constraint def C_repeatability {
    in launcher_repeatability_mm: Real;
    launcher_repeatability_mm <= 100.0
  }
}
