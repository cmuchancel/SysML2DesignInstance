package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with maximum mass and maximum largest-dimension suitable for single-hand use.";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 500.0) and (max_dim_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing capability covering ambient concentrations up to 1000 ug/m3 with resolution and accuracy suitable for air quality monitoring.";
  }
  constraint def C_002 {
    in pm25_range_ugm3: Real;
    in pm25_resolution_ugm3: Real;
    in pm25_accuracy_percent: Real;
    (pm25_range_ugm3 >= 1000.0) and (pm25_resolution_ugm3 <= 1.0) and (pm25_accuracy_percent <= 15.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing capability covering indoor ranges up to 5000 ppm with specified resolution and accuracy.";
  }
  constraint def C_003 {
    in co2_range_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    (co2_range_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing across at least -10 to 50 C with defined accuracy and resolution.";
  }
  constraint def C_004 {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_accuracy_c: Real;
    in temp_resolution_c: Real;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_accuracy_c <= 0.5) and (temp_resolution_c <= 0.1)
  }
  requirement def RQ_005 {
    text = "Relative humidity sensing across 0 to 100 percent with specified accuracy and resolution.";
  }
  constraint def C_005 {
    in rh_min_percent: Real;
    in rh_max_percent: Real;
    in rh_accuracy_percent: Real;
    in rh_resolution_percent: Real;
    (rh_min_percent <= 0.0) and (rh_max_percent >= 100.0) and (rh_accuracy_percent <= 3.0) and (rh_resolution_percent <= 0.1)
  }
  requirement def RQ_006 {
    text = "Runtime of at least 8 hours on a rechargeable battery while wireless sync (Wi-Fi or Bluetooth) is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_active: Boolean;
    (wireless_active == true) implies (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Ability to sync data via Wi-Fi when Wi-Fi is enabled at practical transfer rates for periodic uploads.";
  }
  constraint def C_007 {
    in wifi_enabled: Boolean;
    in wifi_rate_mbps: Real;
    (wifi_enabled == true) implies (wifi_rate_mbps >= 1.0)
  }
  requirement def RQ_008 {
    text = "Ability to sync data via Bluetooth Low Energy (BLE) when Bluetooth is enabled with minimum protocol support and transfer rate.";
  }
  constraint def C_008 {
    in bluetooth_enabled: Boolean;
    in bt_version: Real;
    in bt_rate_kbps: Real;
    (bluetooth_enabled == true) implies ((bt_version >= 4.0) and (bt_rate_kbps >= 50.0))
  }
}