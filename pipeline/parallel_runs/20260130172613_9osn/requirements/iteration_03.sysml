package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with maximum external dimensions of 200.0 mm x 80.0 mm x 30.0 mm and mass not exceeding 400.0 grams";
  }
  constraint def C_001 {
    in length_mm: Real;
    in width_mm: Real;
    in thickness_mm: Real;
    in mass_g: Real;
    (length_mm <= 200.0) and (width_mm <= 80.0) and (thickness_mm <= 30.0) and (mass_g <= 400.0) and (length_mm > 0.0) and (width_mm > 0.0) and (thickness_mm > 0.0) and (mass_g > 0.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing capability covering 0.0 to 1000.0 micrograms per cubic meter with resolution 1.0 micrograms per cubic meter and accuracy +/-10.0 percent over 0.0 to 500.0 micrograms per cubic meter";
  }
  constraint def C_002 {
    in pm_min: Real;
    in pm_max: Real;
    in pm_res: Real;
    in pm_acc_pct: Real;
    (pm_min <= 0.0) and (pm_max >= 1000.0) and (pm_res <= 1.0) and (pm_acc_pct <= 10.0) and (pm_max >= pm_min)
  }
  requirement def RQ_003 {
    text = "CO2 sensing capability covering 400.0 to 5000.0 parts per million with resolution 1.0 ppm and accuracy +/-50.0 ppm or +/-3.0 percent, whichever is greater";
  }
  constraint def C_003 {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_res_ppm: Real;
    in co2_acc_ppm: Real;
    in co2_acc_pct: Real;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_res_ppm <= 1.0) and (co2_acc_ppm <= 50.0) and (co2_acc_pct <= 3.0) and (co2_max_ppm >= co2_min_ppm)
  }
  requirement def RQ_004 {
    text = "Temperature sensing covering -20.0 to 60.0 degrees Celsius with resolution 0.1 degrees Celsius and accuracy +/-0.5 degrees Celsius";
  }
  constraint def C_004 {
    in t_min_C: Real;
    in t_max_C: Real;
    in t_res_C: Real;
    in t_acc_C: Real;
    (t_min_C <= -20.0) and (t_max_C >= 60.0) and (t_res_C <= 0.1) and (t_acc_C <= 0.5) and (t_max_C >= t_min_C)
  }
  requirement def RQ_005 {
    text = "Relative humidity sensing covering 0.0 to 100.0 percent RH with resolution 0.1 percent and accuracy +/-3.0 percent RH";
  }
  constraint def C_005 {
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_res_pct: Real;
    in rh_acc_pct: Real;
    (rh_min_pct <= 0.0) and (rh_max_pct >= 100.0) and (rh_res_pct <= 0.1) and (rh_acc_pct <= 3.0) and (rh_max_pct >= rh_min_pct)
  }
  requirement def RQ_006 {
    text = "Operational runtime of at least 8.0 hours of continuous measurement and wireless syncing between full charges under normal operating conditions";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Rechargeable battery with USB-C charging supporting full recharge within 4.0 hours and a minimum cycle life of 300.0 full charge cycles";
  }
  constraint def C_007 {
    in charge_time_hours: Real;
    in cycle_life: Real;
    (charge_time_hours <= 4.0) and (cycle_life >= 300.0)
  }
  requirement def RQ_008 {
    text = "Wireless connectivity supporting Wi-Fi 2.4 GHz (802.11b/g/n) or Bluetooth Low Energy 5.0 for data sync and configuration";
  }
  constraint def C_008 {
    in wifi_support: Boolean;
    in ble_support: Boolean;
    (wifi_support) or (ble_support)
  }
  requirement def RQ_009 {
    text = "Local data logging capable of storing at least 7.0 days of measurements at a 1.0 Hz aggregate sample rate with timestamping and export via wireless interfaces";
  }
  constraint def C_009 {
    in days_storage: Real;
    in sample_rate_hz: Real;
    (days_storage >= 7.0) and (sample_rate_hz >= 1.0)
  }
  requirement def RQ_010 {
    text = "User interface providing real-time numeric display of measured values and status indicators for wireless connectivity and battery charge state";
  }
  constraint def C_010 {
    in has_display: Boolean;
    in has_status_leds: Boolean;
    (has_display) and (has_status_leds)
  }
}