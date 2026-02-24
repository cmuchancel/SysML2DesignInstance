package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with device volume <= 250.0 cubic centimeters and mass <= 350.0 grams";
  }
  requirement def RQ_002 {
    text = "PM2.5 sensor capable of measuring 0.0 to 1000.0 micrograms per cubic meter with resolution <= 1.0 ug/m3 and accuracy <= 10.0 percent";
  }
  requirement def RQ_003 {
    text = "CO2 sensor capable of measuring 400.0 to 5000.0 ppm with accuracy <= 50.0 ppm and resolution <= 1.0 ppm";
  }
  requirement def RQ_004 {
    text = "Temperature sensor range from -10.0 to 50.0 degrees Celsius with accuracy <= 0.5 degrees Celsius and resolution <= 0.1 degrees Celsius";
  }
  requirement def RQ_005 {
    text = "Relative humidity sensor range 0.0 to 100.0 percent RH with accuracy <= 3.0 percent RH and resolution <= 0.1 percent RH";
  }
  requirement def RQ_006 {
    text = "Operational runtime on internal rechargeable battery of at least 8.0 hours under typical usage profile";
  }
  requirement def RQ_007 {
    text = "Rechargeable battery and charging system supporting USB-C charging with full charge time <= 4.0 hours and cycle life >= 300.0 cycles";
  }
  requirement def RQ_008 {
    text = "Wi-Fi connectivity supporting 802.11 b/g/n at 2.4 GHz and secure data sync with minimum uplink throughput >= 1.0 Mbps";
  }
  requirement def RQ_009 {
    text = "Bluetooth connectivity supporting BLE 4.2 or later with effective range >= 10.0 meters and secure pairing";
  }
  requirement def RQ_010 {
    text = "Local data logging capacity to store at least 168.0 hours of sampled data at 1.0 minute intervals and user indicators for measurement and connectivity status";
  }
  constraint def C_001 {
    in volume: Real;
    in mass: Real;
    (volume <= 250.0) and (mass <= 350.0)
  }
  constraint def C_002 {
    in pm_min: Real;
    in pm_max: Real;
    in pm_res: Real;
    in pm_acc_pct: Real;
    (pm_min <= 0.0) and (pm_max >= 1000.0) and (pm_res <= 1.0) and (pm_acc_pct <= 10.0)
  }
  constraint def C_003 {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_acc_ppm: Real;
    in co2_res_ppm: Real;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_acc_ppm <= 50.0) and (co2_res_ppm <= 1.0)
  }
  constraint def C_004 {
    in t_min_c: Real;
    in t_max_c: Real;
    in t_acc_c: Real;
    in t_res_c: Real;
    (t_min_c <= -10.0) and (t_max_c >= 50.0) and (t_acc_c <= 0.5) and (t_res_c <= 0.1)
  }
  constraint def C_005 {
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_acc_pct: Real;
    in rh_res_pct: Real;
    (rh_min_pct <= 0.0) and (rh_max_pct >= 100.0) and (rh_acc_pct <= 3.0) and (rh_res_pct <= 0.1)
  }
  constraint def C_006 {
    in runtime_hours: Real;
    (runtime_hours >= 8.0)
  }
  constraint def C