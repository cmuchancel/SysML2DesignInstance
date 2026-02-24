package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with maximum mass and dimensions suitable for single-hand use.";
  }
  constraint def C_001 {
    in mass_g: Real, max_dimension_mm: Real;
    (mass_g <= 500.0) and (max_dimension_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing capability covering common ambient ranges with defined resolution and accuracy.";
  }
  constraint def C_002 {
    in pm25_range_ugm3: Real, pm25_resolution_ugm3: Real, pm25_accuracy_percent: Real;
    (pm25_range_ugm3 >= 1000.0) and (pm25_resolution_ugm3 <= 1.0) and (pm25_accuracy_percent <= 15.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing capability covering typical indoor ranges with specified accuracy and resolution.";
  }
  constraint def C_003 {
    in co2_range_ppm: Real, co2_accuracy_ppm: Real, co2_resolution_ppm: Real;
    (co2_range_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing across typical environmental temperatures with defined accuracy and resolution.";
  }
  constraint def C_004 {
    in temp_min_c: Real, temp_max_c: Real, temp_accuracy_c: Real, temp_resolution_c: Real;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_accuracy_c <= 0.5) and (temp_resolution_c <= 0.1)
  }
  requirement def RQ_005 {
    text = "Relative humidity sensing across 0 to 100 percent with specified accuracy and resolution.";
  }
  constraint def C_005 {
    in rh_min_percent: Real, rh_max_percent: Real, rh_accuracy_percent: Real, rh_resolution_percent: Real;
    (rh_min_percent <= 0.0) and (rh_max_percent >= 100.0) and (rh_accuracy_percent <= 3.0) and (rh_resolution_percent <= 0.1)
  }
  requirement def RQ_006 {
    text = "Runtime of at least 8 hours on a rechargeable battery while wireless sync is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real, wireless_on: Boolean;
    (wireless_on == true) implies (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Ability to sync data via Wi-Fi at practical transfer rates when Wi-Fi is enabled.";
  }
  constraint def C_007 {
    in wifi_enabled: Boolean, wifi_rate_mbps: Real;
    (wifi_enabled == true) implies (wifi_rate_mbps >= 1.0)
  }
  requirement def RQ_008 {
    text = "Ability to sync data via Bluetooth Low Energy (BLE) when Bluetooth is enabled.";
  }
  constraint def C_008 {
    in bluetooth_enabled: Boolean, bt_version: Real, bt_rate_kbps: Real;
    (bluetooth_enabled == true) implies ((bt_version >= 4.0) and (bt_rate_kbps >= 50.0))
  }
}