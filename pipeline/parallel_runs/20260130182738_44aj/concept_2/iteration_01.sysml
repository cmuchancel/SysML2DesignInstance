package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: the device shall be portable for single-person carry and handling.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in max_dimension_mm: Real;
    (mass_kg <= 5.0) and (max_dimension_mm <= 400.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: the device shall measure particulate matter (PM2.5) for environmental monitoring.";
  }
  constraint def C_002 {
    in pm25_range_max_ug_m3: Real;
    in pm25_detection_limit_ug_m3: Real;
    in pm25_accuracy_ug_m3: Real;
    (pm25_range_max_ug_m3 >= 500.0) and (pm25_detection_limit_ug_m3 <= 1.0) and (pm25_accuracy_ug_m3 <= 10.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: the device shall measure ambient CO2 concentration for indoor air quality indications.";
  }
  constraint def C_003 {
    in co2_range_max_ppm: Real;
    in co2_range_min_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: the device shall measure ambient air temperature across typical field conditions.";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_accuracy_C: Real;
    (temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_accuracy_C <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: the device shall measure relative humidity for environmental context.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: the device shall operate on a rechargeable battery for typical practice sessions.";
  }
  constraint def C_006 {
    in battery_runtime_hours: Real;
    in wireless_on: Boolean;
    in rechargeable: Boolean;
    (battery_runtime_hours >= 8.0) and (wireless_on == true) and (rechargeable == true)
  }
  requirement def RQ_007 {
    text = "Wi-Fi sync: the device shall support wireless data synchronization via Wi-Fi.";
  }
  constraint def C_007 {
    in wifi_enabled: Boolean;
    in bluetooth_enabled: Boolean;
    wifi_enabled or bluetooth_enabled
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: the device shall support wireless data synchronization via Bluetooth.";
  }
  constraint def C_008 {
    in wifi_enabled: Boolean;
    in bluetooth_enabled: Boolean;
    wifi_enabled or bluetooth_enabled
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Plunger {
    attribute stroke_mm: Real;
    attribute pad_diameter_mm: Real;
    attribute tossSpeed_m_s: Real;
    attribute tossAngle_deg: Real;
    attribute impact_energy_J: Real;
  }

  part def Compressor {
    attribute compressor_power_W: Real;
    attribute accumulator_volume_L: Real;
    attribute accumulator_pressure_psi: Real;
    attribute duty_cycle_pct: Real;
  }

  part def SolenoidValve {
    attribute response_ms: Real;
    attribute orifice_diameter_mm: Real;
    attribute max_operating_psi: Real;
  }

  part def Magazine {
    attribute capacity_count: Integer;
    attribute index_time_s: Real;
    attribute double_feed_protection: Boolean;
    attribute jam_clear_accessible: Boolean;
  }

  part def ControlUnit {
    attribute mcu_flash_MB: Real;
    attribute control_loop_rate_Hz: Real;
    attribute cadence_s: Real;
    attribute consistency_mode_enabled: Boolean;
    attribute fault_detection_enabled: Boolean;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute rechargeable: Boolean;
    attribute avg_power_W: Real;
    attribute emergency_stop_supported: Boolean;
    attribute mass_kg: Real;
    attribute max_dimension_mm: Real;
  }

  part def Connectivity {
    attribute wifi_enabled: Boolean;
    attribute bluetooth_enabled: Boolean;
    attribute wifi_transfer_Mbps: Real;
    attribute remote_control_latency_ms: Real;
  }

  part def Storage {
    attribute logs_enabled: Boolean;
    attribute flash_MB: Real;
  }

  part def UI {
    attribute display_in: Real;
    attribute simple_controls_present: Boolean;
    attribute tablet_mode_supported: Boolean;
  }

  part def Enclosure {
    attribute ip_rating: String;
    attribute impact_resistance_J: Real;
    attribute mass_kg: Real;
    attribute collapsible_for_transport: Boolean;
    attribute max_dimension_mm: Real;
  }

  part def Safety {
    attribute guarding_present: Boolean;
    attribute safe_fault_response_time_s: Real;
    attribute user_contact_prevention: Boolean;
  }

  part def System {
    part pneumaticPlunger: Plunger {
      attribute stroke_mm: Real;
      attribute pad_diameter_mm: Real;
      attribute tossSpeed_m_s: Real;
      attribute tossAngle_deg: Real;
      attribute impact_energy_J: Real;
    }
    part compressor: Compressor {
      attribute compressor_power_W: Real;
      attribute accumulator_volume_L: Real;
      attribute accumulator_pressure_psi: Real;
      attribute duty_cycle_pct: Real;
    }
    part valve: SolenoidValve {
      attribute response_ms: Real;
      attribute orifice_diameter_mm: Real;
      attribute max_operating_psi: Real;
    }
    part magazine: Magazine {
      attribute capacity_count: Integer;
      attribute index_time_s: Real;
      attribute double_feed_protection: Boolean;
      attribute jam_clear_accessible: Boolean;
    }
    part control: ControlUnit {
      attribute mcu_flash_MB: Real;
      attribute control_loop_rate_Hz: Real;
      attribute cadence_s: Real;
      attribute consistency_mode_enabled: Boolean;
      attribute fault_detection_enabled: Boolean;
    }
    part power: PowerSubsystem {
      attribute batteryCapacity_mAh: Real;
      attribute rechargeable: Boolean;
      attribute avg_power_W: Real;
      attribute emergency_stop_supported: Boolean;
      attribute mass_kg: Real;
      attribute max_dimension_mm: Real;
    }
    part comms: Connectivity {
      attribute wifi_enabled: Boolean;
      attribute bluetooth_enabled: Boolean;
      attribute wifi_transfer_Mbps: Real;
      attribute remote_control_latency_ms: Real;
    }
    part storage: Storage {
      attribute logs_enabled: Boolean;
      attribute flash_MB: Real;
    }
    part ui: UI {
      attribute display_in: Real;
      attribute simple_controls_present: Boolean;
      attribute tablet_mode_supported: Boolean;
    }
    part enclosure: Enclosure {
      attribute ip_rating: String;
      attribute impact_resistance_J: Real;
      attribute mass_kg: Real;
      attribute collapsible_for_transport: Boolean;
      attribute max_dimension_mm: Real;
    }
    part safety: Safety {
      attribute guarding_present: Boolean;
      attribute safe_fault_response_time_s: Real;
      attribute user_contact_prevention: Boolean;
    }
    attribute system_mass_kg: Real;
    attribute system_max_dimension_mm: Real;
  }

  constraint def C_runtime {
    in batteryCapacity_mAh: Real;
    in avg_power_W: Real;
    batteryCapacity_mAh >= 6000.0
  }

  constraint def C_accumulator_pressure {
    in accumulator_pressure_psi: Real;
    accumulator_pressure_psi >= 30.0
  }

  constraint def C_connectivity_availability {
    in wifi_enabled: Boolean;
    wifi_enabled == true
  }

  constraint def C_portability_mass {
    in system_mass_kg: Real;
    system_mass_kg <= 5.0
  }

  constraint def C_portability_size {
    in system_max_dimension_mm: Real;
    system_max_dimension_mm <= 400.0
  }

  constraint def C_toss_throughput {
    in cadence_s: Real;
    cadence_s <= 5.0
  }
}
