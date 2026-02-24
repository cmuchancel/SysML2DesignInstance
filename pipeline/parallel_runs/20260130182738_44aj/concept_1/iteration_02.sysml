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

  part def Component {
  }

  part def Flywheel {
    attribute wheelDiameter_mm: Real;
    attribute rpm_min: Real;
    attribute rpm_max: Real;
    attribute motor_power_W: Real;
    attribute max_toss_speed_m_s: Real;
  }

  part def SingulationGate {
    attribute actuated: Boolean;
    attribute jam_detection: Boolean;
    attribute feed_rate_bpm: Real;
  }

  part def Chute {
    attribute angle_min_deg: Real;
    attribute angle_max_deg: Real;
    attribute adjustability_steps: Integer;
  }

  part def BatteryPack {
    attribute batteryCapacity_mAh: Real;
    attribute nominal_voltage_V: Real;
    attribute battery_runtime_hours: Real;
    attribute rechargeable: Boolean;
    attribute mass_kg: Real;
  }

  part def MotorController {
    attribute channels: Integer;
    attribute max_current_A: Real;
    attribute control_loop_ms: Real;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute realtime_task_hz: Real;
  }

  part def Connectivity {
    attribute ble_enabled: Boolean;
    attribute wifi_enabled: Boolean;
    attribute ble_range_m: Real;
    attribute wifi_range_m: Real;
  }

  part def Storage {
    attribute flash_MB: Real;
    attribute log_capacity_sessions: Integer;
  }

  part def UI {
    attribute physical_buttons: Integer;
    attribute displaySize_in: Real;
    attribute leds_status_count: Integer;
    attribute emergency_stop_present: Boolean;
  }

  part def Enclosure {
    attribute ingress_ip_rating: Real;
    attribute max_dimension_mm: Real;
    attribute mass_kg: Real;
    attribute handle_present: Boolean;
  }

  part def LauncherSystem {
    part fly1: Flywheel {
      attribute wheelDiameter_mm: Real;
      attribute rpm_min: Real;
      attribute rpm_max: Real;
      attribute motor_power_W: Real;
      attribute max_toss_speed_m_s: Real;
    }
    part fly2: Flywheel {
      attribute wheelDiameter_mm: Real;
      attribute rpm_min: Real;
      attribute rpm_max: Real;
      attribute motor_power_W: Real;
      attribute max_toss_speed_m_s: Real;
    }
    part gate: SingulationGate {
      attribute actuated: Boolean;
      attribute jam_detection: Boolean;
      attribute feed_rate_bpm: Real;
    }
    part chute: Chute {
      attribute angle_min_deg: Real;
      attribute angle_max_deg: Real;
      attribute adjustability_steps: Integer;
    }
    part battery: BatteryPack {
      attribute batteryCapacity_mAh: Real;
      attribute nominal_voltage_V: Real;
      attribute battery_runtime_hours: Real;
      attribute rechargeable: Boolean;
      attribute mass_kg: Real;
    }
    part motorCtl: MotorController {
      attribute channels: Integer;
      attribute max_current_A: Real;
      attribute control_loop_ms: Real;
    }
    part cpu: MCU {
      attribute flash_MB: Real;
      attribute ram_MB: Real;
      attribute realtime_task_hz: Real;
    }
    part comms: Connectivity {
      attribute ble_enabled: Boolean;
      attribute wifi_enabled: Boolean;
      attribute ble_range_m: Real;
      attribute wifi_range_m: Real;
    }
    part storage: Storage {
      attribute flash_MB: Real;
      attribute log_capacity_sessions: Integer;
    }
    part ui: UI {
      attribute physical_buttons: Integer;
      attribute displaySize_in: Real;
      attribute leds_status_count: Integer;
      attribute emergency_stop_present: Boolean;
    }
    part enclosure: Enclosure {
      attribute ingress_ip_rating: Real;
      attribute max_dimension_mm: Real;
      attribute mass_kg: Real;
      attribute handle_present: Boolean;
    }
    attribute nominal_cycle_rate_tpm: Real;
    attribute target_portability_mass_kg: Real;
  }

  constraint def C_runtime {
    in battery_runtime_hours: Real;
    battery_runtime_hours >= 8.0
  }

  constraint def C_sensing_co2 {
    in co2_range_max_ppm: Real;
    co2_range_max_ppm >= 5000.0
  }

  constraint def C_connectivity_ble {
    in ble_enabled: Boolean;
    ble_enabled == true
  }

  constraint def C_portability_mass {
    in enclosure_mass_kg: Real;
    enclosure_mass_kg <= 5.0
  }

  constraint def C_cycle_rate {
    in nominal_cycle_rate_tpm: Real;
    nominal_cycle_rate_tpm >= 12.0
  }
}
