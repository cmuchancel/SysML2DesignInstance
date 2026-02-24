package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 { text = "Handheld form factor with ergonomic dimensions and weight suitable for single-hand use."; }
  constraint def C_001 {
    in dimMax_mm: Real; in weight_g: Real;
    (dimMax_mm <= 200.0) and (weight_g <= 500.0)
  }

  requirement def RQ_002 { text = "Measure particulate matter PM2.5 with defined range and accuracy suitable for environmental monitoring."; }
  constraint def C_002 {
    in range_max_ugm3: Real; in accuracy_ugm3: Real;
    (range_max_ugm3 >= 1000.0) and (accuracy_ugm3 <= 10.0)
  }

  requirement def RQ_003 { text = "Measure carbon dioxide (CO2) concentration with defined range and accuracy for indoor air quality assessment."; }
  constraint def C_003 {
    in co2_range_ppm: Real; in co2_accuracy_ppm: Real;
    (co2_range_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  requirement def RQ_004 { text = "Measure ambient temperature over a typical indoor/outdoor range with specified accuracy."; }
  constraint def C_004 {
    in temp_min_C: Real; in temp_max_C: Real; in temp_accuracy_C: Real;
    (temp_min_C <= -10.0) and (temp_max_C >= 50.0) and (temp_accuracy_C <= 0.5)
  }

  requirement def RQ_005 { text = "Measure relative humidity across the full practical range with specified accuracy."; }
  constraint def C_005 {
    in rh_min_pct: Real; in rh_max_pct: Real; in rh_accuracy_pct: Real;
    (rh_min_pct <= 0.0) and (rh_max_pct >= 100.0) and (rh_accuracy_pct <= 3.0)
  }

  requirement def RQ_006 { text = "Device runtime of at least 8 hours on a single charge under typical sampling and connectivity usage."; }
  constraint def C_006 {
    in runtime_hr: Real;
    (runtime_hr >= 8.0)
  }

  requirement def RQ_007 { text = "Rechargeable battery and charging capability supporting repeated full-charge cycles and a bounded charge time."; }
  constraint def C_007 {
    in rechargeable: Boolean; in charge_time_hr: Real;
    (rechargeable = true) and (charge_time_hr <= 6.0)
  }

  requirement def RQ_008 { text = "Wi‑Fi connectivity for data sync supporting common 2.4 GHz infrastructure with minimum uplink throughput."; }
  constraint def C_008 {
    in wifi_supported: Boolean; in wifi_band_ghz: Real; in wifi_up_mbps: Real;
    (wifi_supported = true) and (wifi_band_ghz >= 2.4) and (wifi_up_mbps >= 1.0)
  }

  requirement def RQ_009 { text = "Bluetooth connectivity (BLE) for data sync and local device pairing supporting modern BLE versions."; }
  constraint def C_009 {
    in bt_supported: Boolean; in bt_version: Real;
    (bt_supported = true) and (bt_version >= 4.2)
  }

  requirement