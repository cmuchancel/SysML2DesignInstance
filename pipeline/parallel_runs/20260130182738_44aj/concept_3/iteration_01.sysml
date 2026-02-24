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
    attribute mass_kg: Real;
    attribute max_dimension_mm: Real;
  }

  part def Motor {
    attribute torque_Nm: Real;
    attribute rpm_nominal: Real;
    attribute power_W: Real;
    attribute mass_kg: Real;
  }

  part def SpringArmDelivery {
    attribute arm_length_mm: Real;
    attribute release_angle_deg: Real;
    attribute repeatability_deg: Real;
    attribute delivery_speed_m_s: Real;
    attribute mass_kg: Real;
  }

  part def CamDrive {
    attribute cam_radius_mm: Real;
    attribute gearing_ratio: Real;
    attribute peak_torque_Nm: Real;
    attribute mass_kg: Real;
  }

  part def Clutch {
    attribute release_precision_deg: Real;
    attribute engagement_force_N: Real;
    attribute mass_kg: Real;
  }

  part def Hopper {
    attribute capacity_balls: Integer;
    attribute escapement_cycle_ms: Real;
    attribute double_feed_probability_pct: Real;
    attribute mass_kg: Real;
  }

  part def Feeder {
    attribute feed_consistency_index: Real;
    attribute single_feed_guarantee_pct: Real;
    attribute mass_kg: Real;
  }

  part def Controller {
    attribute cpu_mhz: Real;
    attribute memory_kb: Real;
    attribute realtime_loop_ms: Real;
    attribute mass_kg: Real;
  }

  part def Battery {
    attribute batteryCapacity_mAh: Real;
    attribute voltage_V: Real;
    attribute battery_runtime_hours: Real;
    attribute rechargeable: Boolean;
    attribute mass_kg: Real;
  }

  part def PowerElectronics {
    attribute peak_draw_W: Real;
    attribute avg_draw_W: Real;
    attribute protection_IP_rating: Integer;
    attribute mass_kg: Real;
  }

  part def Radio {
    attribute wifi_enabled: Boolean;
    attribute bluetooth_enabled: Boolean;
    attribute comm_range_m: Real;
    attribute mass_kg: Real;
  }

  part def Storage {
    attribute flash_MB: Real;
    attribute log_capacity_minutes: Real;
    attribute sd_present: Boolean;
    attribute mass_kg: Real;
  }

  part def UI {
    attribute displaySize_in: Real;
    attribute button_count: Integer;
    attribute emergency_stop_present: Boolean;
    attribute mass_kg: Real;
  }

  part def Enclosure {
    attribute ingress_rating_IP: Real;
    attribute material_thickness_mm: Real;
    attribute foldable_handles: Boolean;
    attribute mass_kg: Real;
    attribute max_dimension_mm: Real;
  }

  part def Structure {
    attribute footprint_mm2: Real;
    attribute stowed_volume_mm3: Real;
    attribute portability_handle_count: Integer;
    attribute mass_kg: Real;
  }

  part def Safety {
    attribute guarding_present: Boolean;
    attribute impact_resistance_J: Real;
    attribute fail_safe_time_ms: Real;
    attribute mass_kg: Real;
  }

  part def SoftTossSystem {
    part motor: Motor {
      torque_Nm = 0.9;
      rpm_nominal = 3000.0;
      power_W = 45.0;
      mass_kg = 0.45;
    }
    part cam: CamDrive {
      cam_radius_mm = 35.0;
      gearing_ratio = 5.0;
      peak_torque_Nm = 4.5;
      mass_kg = 0.25;
    }
    part springArm: SpringArmDelivery {
      arm_length_mm = 220.0;
      release_angle_deg = 42.0;
      repeatability_deg = 1.2;
      delivery_speed_m_s = 6.5;
      mass_kg = 0.6;
    }
    part clutch: Clutch {
      release_precision_deg = 0.8;
      engagement_force_N = 18.0;
      mass_kg = 0.12;
    }
    part hopper: Hopper {
      capacity_balls = 12;
      escapement_cycle_ms = 900.0;
      double_feed_probability_pct = 0.5;
      mass_kg = 0.35;
    }
    part feeder: Feeder {
      feed_consistency_index = 0.95;
      single_feed_guarantee_pct = 99.0;
      mass_kg = 0.2;
    }
    part controller: Controller {
      cpu_mhz = 120.0;
      memory_kb = 256.0;
      realtime_loop_ms = 10.0;
      mass_kg = 0.08;
    }
    part battery: Battery {
      batteryCapacity_mAh = 8000.0;
      voltage_V = 14.8;
      battery_runtime_hours = 10.0;
      rechargeable = true;
      mass_kg = 0.9;
    }
    part power: PowerElectronics {
      peak_draw_W = 120.0;
      avg_draw_W = 12.0;
      protection_IP_rating = 54;
      mass_kg = 0.25;
    }
    part radio: Radio {
      wifi_enabled = true;
      bluetooth_enabled = false;
      comm_range_m = 15.0;
      mass_kg = 0.05;
    }
    part storage: Storage {
      flash_MB = 16.0;
      log_capacity_minutes = 600.0;
      sd_present = false;
      mass_kg = 0.02;
    }
    part ui: UI {
      displaySize_in = 2.8;
      button_count = 4;
      emergency_stop_present = true;
      mass_kg = 0.05;
    }
    part enclosure: Enclosure {
      ingress_rating_IP = 54.0;
      material_thickness_mm = 2.0;
      foldable_handles = true;
      mass_kg = 1.8;
      max_dimension_mm = 380.0;
    }
    part structure: Structure {
      footprint_mm2 = 350000.0;
      stowed_volume_mm3 = 12000000.0;
      portability_handle_count = 1;
      mass_kg = 4.0;
    }
    part safety: Safety {
      guarding_present = true;
      impact_resistance_J = 25.0;
      fail_safe_time_ms = 50.0;
      mass_kg = 0.15;
    }
    attribute total_mass_kg: Real;
    attribute user_carryable: Boolean;
    attribute cost_target_usd_min: Real;
    attribute cost_target_usd_max: Real;
    total_mass_kg = motor.mass_kg + cam.mass_kg + springArm.mass_kg + clutch.mass_kg + hopper.mass_kg + feeder.mass_kg + controller.mass_kg + battery.mass_kg + power.mass_kg + radio.mass_kg + storage.mass_kg + ui.mass_kg + enclosure.mass_kg + structure.mass_kg + safety.mass_kg;
    user_carryable = (total_mass_kg <= 5.0);
    cost_target_usd_min = 150.0;
    cost_target_usd_max = 300.0;
  }

  constraint def C_RuntimeBudget {
    in battery_runtime_hours: Real;
    (battery_runtime_hours >= 8.0)
  }

  constraint def C_Portability {
    in mass_kg: Real;
    (mass_kg <= 5.0)
  }

  constraint def C_ConnectivityAvailability {
    in wifi_enabled: Boolean;
    (wifi_enabled == true)
  }

  constraint def C_CO2SensingRange {
    in co2_range_max_ppm: Real;
    (co2_range_max_ppm >= 5000.0)
  }

  constraint def C_PM25Detection {
    in pm25_detection_limit_ug_m3: Real;
    (pm25_detection_limit_ug_m3 <= 1.0)
  }

  constraint def C_SizeLimit {
    in max_dimension_mm: Real;
    (max_dimension_mm <= 400.0)
  }
}
