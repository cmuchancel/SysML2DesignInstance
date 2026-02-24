package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device mass <= 300.0 grams and maximum dimension <= 180.0 mm.";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 300.0) and (max_dim_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: measure 0 to 500.0 ug/m3 with accuracy <= 5.0 ug/m3 and response time <= 60.0 s.";
  }
  constraint def C_002 {
    in pm25_range_max_ugpm3: Real;
    in pm25_accuracy_ugpm3: Real;
    in pm25_response_s: Real;
    (pm25_range_max_ugpm3 >= 500.0) and (pm25_accuracy_ugpm3 <= 5.0) and (pm25_response_s <= 60.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: measure up to 5000.0 ppm with accuracy <= 50.0 ppm and response time <= 120.0 s.";
  }
  constraint def C_003 {
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_response_s: Real;
    (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_response_s <= 120.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: measure -10.0 to 50.0 degC with accuracy <= 0.5 degC.";
  }
  constraint def C_004 {
    in temp_min_degC: Real;
    in temp_max_degC: Real;
    in temp_accuracy_degC: Real;
    (temp_min_degC <= -10.0) and (temp_max_degC >= 50.0) and (temp_accuracy_degC <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: measure 0.0 to 95.0 %RH with accuracy <= 3.0 %RH.";
  }
  constraint def C_005 {
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_min_pct <= 0.0) and (rh_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: operate for at least 8.0 hours with wireless (Wi-Fi or Bluetooth) active and be rechargeable.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in rechargeable: Boolean;
    in wireless_active: Boolean;
    (runtime_hours >= 8.0) and (rechargeable = true) and (wireless_active = true)
  }
  requirement def RQ_007 {
    text = "Wireless sync: support data sync via Wi-Fi or Bluetooth (at least one supported).";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported = true) or (bluetooth_supported = true)
  }
  requirement def RQ_008 {
    text = "Wireless sync: support data sync via Wi-Fi or Bluetooth (at least one supported).";
  }
  constraint def C_008 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported = true) or (bluetooth_supported = true)
  }
}