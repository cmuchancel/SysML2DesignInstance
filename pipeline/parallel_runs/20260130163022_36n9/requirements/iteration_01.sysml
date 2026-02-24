package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 { text = "Handheld form factor with user-portable size and weight suitable for single-hand operation." }
  constraint def C_001 {
    in weight_g: Real;
    in max_dimension_mm: Real;
    (weight_g <= 500.0) and (max_dimension_mm <= 220.0)
  }

  requirement def RQ_002 { text = "PM2.5 sensing capability with specified range, resolution, and accuracy for ambient particulate measurement." }
  constraint def C_002 {
    in range_ugm3: Real;
    in resolution_ugm3: Real;
    in accuracy_percent: Real;
    (range_ugm3 >= 0.0) and (range_ugm3 >= 500.0) and (resolution_ugm3 <= 1.0) and (accuracy_percent <= 15.0)
  }

  requirement def RQ_003 { text = "CO2 sensing capability with specified measurement range, resolution, and accuracy for indoor air quality." }
  constraint def C_003 {
    in range_ppm: Real;
    in resolution_ppm: Real;
    in accuracy_ppm: Real;
    (range_ppm >= 0.0) and (range_ppm >= 5000.0) and (resolution_ppm <= 1.0) and (accuracy_ppm <= 50.0)
  }

  requirement def RQ_004 { text = "Temperature sensing capability with specified range, resolution, and accuracy." }
  constraint def C_004 {
    in range_C: Real;
    in resolution_C: Real;
    in accuracy_C: Real;
    (range_C <= -20.0) and (range_C >= 60.0) and (resolution_C <= 0.1) and (accuracy_C <= 0.5)
  }

  requirement def RQ_005 { text = "Humidity sensing capability with specified range, resolution, and accuracy." }
  constraint def C_005 {
    in range_rh: Real;
    in resolution_rh: Real;
    in accuracy_rh: Real;
    (range_rh >= 0.0) and (range_rh >= 100.0) and (resolution_rh <= 0.1) and (accuracy_rh <= 3.0)
  }

  requirement def RQ_006 { text = "Operational runtime of at least eight hours on a single battery charge under typical use." }
  constraint def C_006 {
    in runtime_h: Real;
    (runtime_h >= 8.0)
  }

  requirement def RQ_007 { text = "Rechargeable battery with safe charging support and specified charge time and cycle life." }
  constraint def C_007 {
    in charge_time_h: Real;
    in cycle_life_cycles: Integer;
    (charge_time_h <= 4.0) and (cycle_life_cycles >= 300)
  }

  requirement def RQ_008 { text = "Wi‑Fi connectivity for data sync supporting common 2.4 GHz networks and minimum throughput." }
  constraint def C_008 {
    in wifi_24ghz_support: Boolean;
    in wifi_throughput_mbps: Real;
    (wifi_24ghz_support = true) and (wifi_throughput_mbps >= 1.0)
  }

  requirement def RQ_009 { text = "Bluetooth connectivity (Low Energy) for data sync with minimum effective range." }
  constraint def C_009 {
    in ble_support: Boolean;
    in ble_range_m: Real;
    (ble_support = true) and (ble_range_m >= 10.0)
  }

  requirement def RQ_010 { text = "Local data logging capability with sufficient onboard storage to retain measurements between syncs." }
  constraint def C_010 {
    in storage_kb: Real;
    in sample_rate_s: Real;
    in retention_days: Real;
    (storage_kb >= 1024.0) and (sample_rate_s <= 60.0) and (retention_days >= 7.0)
  }

  requirement def RQ_011 { text = "