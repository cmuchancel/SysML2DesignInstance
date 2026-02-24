package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with maximum mass and maximum single-dimension length suitable for hand carry.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in max_dimension_mm: Real;
    (mass_kg <= 0.5) and (max_dimension_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing capability covering common ambient ranges with defined measurement accuracy and minimum detection range.";
  }
  constraint def C_002 {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_accuracy_ug_m3: Real;
    (pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_accuracy_ug_m3 <= 10.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing capability covering indoor ambient to elevated concentrations with defined accuracy.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing over expected ambient range with specified accuracy.";
  }
  constraint def C_004 {
    in temperature_min_c: Real;
    in temperature_max_c: Real;
    in temperature_accuracy_c: Real;
    (temperature_min_c <= -10.0) and (temperature_max_c >= 50.0) and (temperature_accuracy_c <= 0.5)
  }
  requirement def RQ_005 {
    text = "Relative humidity sensing over expected ambient range with specified accuracy.";
  }
  constraint def C_005 {
    in humidity_min_pct: Real;
    in humidity_max_pct: Real;
    in humidity_accuracy_pct: Real;
    (humidity_min_pct <= 0.0) and (humidity_max_pct >= 95.0) and (humidity_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime of at least 8 hours on a rechargeable battery when wireless sync is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    (wireless_on == false) or (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Supports data synchronization via Wi-Fi with minimum usable data rate when Wi-Fi is provided.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in wifi_data_rate_mbps: Real;
    (wifi_supported == true) and (wifi_data_rate_mbps >= 1.0)
  }
  requirement def RQ_008 {
    text = "Supports data synchronization via Bluetooth Low Energy with minimum usable data rate when Bluetooth is provided.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in bluetooth_le: Boolean;
    in bluetooth_data_rate_mbps: Real;
    (bluetooth_supported == true) and (bluetooth_le == true) and (bluetooth_data_rate_mbps >= 0.1)
  }
  requirement def RQ_009 {
    text = "Device shall provide data synchronization via Wi-Fi or Bluetooth (at least one supported).";
  }
  constraint def C_009 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported == true) or (bluetooth_supported == true)
  }
}