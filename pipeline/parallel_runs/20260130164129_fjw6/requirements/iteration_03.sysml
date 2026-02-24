package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device mass <= 300.0 grams and maximum external dimensions <= 160.0 mm x 80.0 mm x 40.0 mm";
  }
  constraint def C_001 {
    in mass_g: Real;
    in dim_x_mm: Real;
    in dim_y_mm: Real;
    in dim_z_mm: Real;
    (mass_g <= 300.0) and (dim_x_mm <= 160.0) and (dim_y_mm <= 80.0) and (dim_z_mm <= 40.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: measurement range 0.0 to 1000.0 micrograms per cubic meter, accuracy <= 10.0 micrograms per cubic meter, update period <= 60.0 seconds";
  }
  constraint def C_002 {
    in pm_range_min_ugm3: Real;
    in pm_range_max_ugm3: Real;
    in pm_accuracy_ugm3: Real;
    in pm_update_s: Real;
    (pm_range_min_ugm3 <= 0.0) and (pm_range_max_ugm3 >= 1000.0) and (pm_accuracy_ugm3 <= 10.0) and (pm_update_s <= 60.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: measurement range 400.0 to 5000.0 ppm, accuracy <= 50.0 ppm, resolution <= 1.0 ppm";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: measurement range -10.0 to 50.0 degrees Celsius, accuracy <= 0.5 degrees Celsius";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_accuracy_C: Real;
    (temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_accuracy_C <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: measurement range 0.0 to 95.0 percent RH, accuracy <= 3.0 percent RH";
  }
  constraint def C_005 {
    in hum_range_min_pct: Real;
    in hum_range_max_pct: Real;
    in hum_accuracy_pct: Real;
    (hum_range_min_pct <= 0.0) and (hum_range_max_pct >= 95.0) and (hum_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime: continuous operation >= 8.0 hours on a single full charge under typical sampling and wireless usage";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in sampling_interval_s: Real;
    in wifi_active: Boolean;
    in ble_active: Boolean;
    ((sampling_interval_s <= 60.0) and ((wifi_active == true) or (ble_active == true))) implies (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Battery: rechargeable battery required; full recharge time <= 4.0 hours and battery must be rechargeable";
  }
  constraint def C_007 {
    in recharge_time_h: Real;
    in is_rechargeable: Boolean;
    (recharge_time_h <= 4.0) and (is_rechargeable == true)
  }
  requirement def RQ_008 {
    text = "Wireless connectivity: device must support Wi-Fi 2.4 GHz and/or Bluetooth Low Energy (BLE) for syncing logged data; at least one must be supported";
  }
  constraint def C_008 {
    in supports_wifi_24ghz: Boolean;
    in supports_ble: Boolean;
    (supports_wifi_24ghz == true) or (supports_ble == true)
  }
  requirement def RQ_009 {
    text = "Data logging: local storage sufficient to retain at least 24.0 hours of samples at sampling interval <= 60.0 seconds and timestamps included";
  }
  constraint def C_009 {
    in storage_hours: Real;
    in sampling_interval_s: Real;
    in timestamps_included: Boolean;
    ((sampling_interval_s <= 60.0) implies (storage_hours >= 24.0)) and (timestamps_included == true)
  }
  requirement def RQ_010 {
    text = "User interface and indicators: onboard display diagonal <= 3.5 inches and at least one multi-color LED indicator for status";
  }
  constraint def C_010 {
    in display_diagonal_in: Real;
    in has_multicolor_led: Boolean;
    (display_diagonal_in <= 3.5) and (has_multicolor_led == true)
  }
}