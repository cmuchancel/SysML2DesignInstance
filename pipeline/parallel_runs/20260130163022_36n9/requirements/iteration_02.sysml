package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 { text = "Handheld form factor suitable for single-hand operation." }
  constraint def C_001 {
    in weight_g: Real;
    in max_dimension_mm: Real;
    (weight_g <= 500.0) and (max_dimension_mm <= 220.0)
  }

  requirement def RQ_002 { text = "PM2.5 sensing capability (ambient) with defined minimum and maximum measurable concentration, resolution, and accuracy." }
  constraint def C_002 {
    in pm_min_ugm3: Real;
    in pm_max_ugm3: Real;
    in pm_resolution_ugm3: Real;
    in pm_accuracy_percent: Real;
    (pm_min_ugm3 <= 0.0) and (pm_max_ugm3 >= 500.0) and (pm_resolution_ugm3 <= 1.0) and (pm_accuracy_percent <= 15.0)
  }

  requirement def RQ_003 { text = "CO2 sensing capability with specified measurement range, resolution, and accuracy for indoor air quality." }
  constraint def C_003 {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_resolution_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_min_ppm <= 0.0) and (co2_max_ppm >= 5000.0) and (co2_resolution_ppm <= 1.0) and (co2_accuracy_ppm <= 50.0)
  }

  requirement def RQ_004 { text = "Temperature sensing capability with specified range, resolution, and accuracy." }
  constraint def C_004 {
    in temp_min_C: Real;
    in temp_max_C: Real;
    in temp_resolution_C: Real;
    in temp_accuracy_C: Real;
    (temp_min_C <= -20.0) and (temp_max_C >= 60.0) and (temp_resolution_C <= 0.1) and (temp_accuracy_C <= 0.5)
  }

  requirement def RQ_005 { text = "Humidity sensing capability with specified range, resolution, and accuracy." }
  constraint def C_005 {
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_resolution_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_min_pct <= 0.0) and (rh_max_pct >= 100.0) and (rh_resolution_pct <= 0.1) and (rh_accuracy_pct <= 3.0)
  }

  requirement def RQ_006 { text = "Operational runtime of at least eight hours on a single battery charge under typical use." }
  constraint def C_006 {
    in runtime_h: Real;
    (runtime_h >= 8.0)
  }

  requirement def RQ_007 { text = "Rechargeable battery with safe charging support, maximum charge time, and minimum cycle life." }
  constraint def C_007 {
    in charge_time_h: Real;
    in cycle_life_cycles: Integer;
    (charge_time_h <= 4.0) and (cycle_life_cycles >= 300)
  }

  requirement def RQ_008 { text = "Wi‑Fi connectivity for data sync supporting 2.4 GHz networks with minimum throughput." }
  constraint def C_008 {
    in wifi_24ghz_supported: Boolean;
    in wifi_throughput_mbps: Real;
    (wifi_24ghz_supported == true) and (wifi_throughput_mbps >= 1.0