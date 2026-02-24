package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device mass shall be suitable for one-handed carry and operation.";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dimension_mm: Real;
    (mass_g <= 300.0) and (max_dimension_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter (PM2.5) for environmental monitoring.";
  }
  constraint def C_002 {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_resolution_ug_m3: Real;
    (pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_resolution_ug_m3 <= 1.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration for indoor air quality assessment.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature within a typical indoor range.";
  }
  constraint def C_004 {
    in temp_range_min_c: Real;
    in temp_range_max_c: Real;
    in temp_accuracy_c: Real;
    (temp_range_min_c <= -10.0) and (temp_range_max_c >= 50.0) and (temp_accuracy_c <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity for environmental monitoring.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for at least 8 hours when wireless sync is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    ((wireless_on = true) implies (runtime_hours >= 8.0))
  }
  requirement def RQ_007 {
    text = "Wireless sync: device shall provide data synchronization via Wi-Fi or Bluetooth.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported = true) or (bluetooth_supported = true)
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: if Bluetooth is implemented, data transfer success rate shall be at least 95 percent.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in bluetooth_success_pct: Real;
    ((bluetooth_supported = true) implies (bluetooth_success_pct >= 95.0))
  }
}