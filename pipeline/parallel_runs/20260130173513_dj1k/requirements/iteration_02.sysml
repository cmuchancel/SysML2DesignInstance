package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Device shall conform to a handheld form factor with limits on mass and maximum exterior dimension.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in max_dim_mm: Real;
    (mass_kg <= 0.5) and (max_dim_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "Device shall measure ambient PM2.5 with specified accuracy and range suitable for indoor and outdoor air quality monitoring.";
  }
  constraint def C_002 {
    in pm25_abs_error_ugm3: Real;
    in pm25_max_range_ugm3: Real;
    (pm25_abs_error_ugm3 <= 10.0) and (pm25_max_range_ugm3 >= 500.0)
  }
  requirement def RQ_003 {
    text = "Device shall measure ambient CO2 concentration with specified accuracy and range suitable for occupancy and ventilation assessment.";
  }
  constraint def C_003 {
    in co2_abs_error_ppm: Real;
    in co2_max_range_ppm: Real;
    (co2_abs_error_ppm <= 50.0) and (co2_max_range_ppm >= 5000.0)
  }
  requirement def RQ_004 {
    text = "Device shall measure ambient temperature with specified accuracy and operational range for indoor environments.";
  }
  constraint def C_004 {
    in temp_abs_error_c: Real;
    in temp_operational_span_c: Real;
    (temp_abs_error_c <= 0.5) and (temp_operational_span_c >= 70.0)
  }
  requirement def RQ_005 {
    text = "Device shall measure relative humidity with specified accuracy and full-percent operational range.";
  }
  constraint def C_005 {
    in rh_abs_error_pct: Real;
    in rh_max_range_pct: Real;
    (rh_abs_error_pct <= 3.0) and (rh_max_range_pct >= 100.0)
  }
  requirement def RQ_006 {
    text = "Device shall operate at least eight hours on a single rechargeable battery charge while wireless sync is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    (wireless_on == true) implies (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Device shall support Wi-Fi-based data synchronization or Bluetooth-based data synchronization to satisfy the wireless sync requirement.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported == true) or (bluetooth_supported == true)
  }
  requirement def RQ_008 {
    text = "Device shall include wireless capability implemented via Wi-Fi or Bluetooth such that at least one of these is available for sync.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in wifi_supported: Boolean;
    (bluetooth_supported == true) or (wifi_supported == true)
  }
}