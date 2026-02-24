package RequirementsOnly {
  public import ScalarValues::*;
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
    pm25_supported = true and (pm25_range_ugm3_min <= 0.0 and pm25_range_ugm3_max >= 500.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration to identify elevated indoor levels affecting user comfort.";
  }
  constraint def C_003 {
    in co2_supported: Boolean;
    in co2_range_ppm_min: Real;
    in co2_range_ppm_max: Real;
    co2_supported = true and (co2_range_ppm_min <= 400.0 and co2_range_ppm_max >= 5000.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient air temperature for environmental context during practice.";
  }
  constraint def C_004 {
    in temp_supported: Boolean;
    in temp_range_C_min: Real;
    in temp_range_C_max: Real;
    temp_supported = true and (temp_range_C_min <= -10.0 and temp_range_C_max >= 50.0)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity for environmental context during practice.";
  }
  constraint def C_005 {
    in rh_supported: Boolean;
    in rh_range_percent_min: Real;
    in rh_range_percent_max: Real;
    rh_supported = true and (rh_range_percent_min <= 0.0 and rh_range_percent_max >= 100.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for at least 6.0 hours with wireless radios active under typical practice load.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    (wireless_on = true) and (runtime_hours >= 6.0)
  }
  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support Wi-Fi synchronization capability to external devices or services for practice session data exchange or control.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    wifi_supported = true or bluetooth_supported = true
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support Bluetooth Low Energy synchronization capability to external devices for local control or data exchange.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in wifi_supported: Boolean;
    bluetooth_supported = true or wifi_supported = true
  }
}