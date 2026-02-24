package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 { text = "Handheld form factor suitable for single-hand use." }
  requirement def RQ_002 { text = "PM2.5 sensing capability." }
  requirement def RQ_003 { text = "CO2 sensing capability." }
  requirement def RQ_004 { text = "Temperature sensing capability." }
  requirement def RQ_005 { text = "Humidity sensing capability." }
  requirement def RQ_006 { text = "Operational runtime of at least 8 hours on a single charge." }
  requirement def RQ_007 { text = "Rechargeable battery with charging support." }
  requirement def RQ_008 { text = "Wi‑Fi wireless data synchronization capability." }
  requirement def RQ_009 { text = "Bluetooth wireless data synchronization capability." }
  requirement def RQ_010 { text = "Local data logging of measured values." }
  requirement def RQ_011 { text = "User interface and indicators for status and measurements." }

  constraint def C_001 {
    in mass_kg: Real;
    (mass_kg > 0.0) and (mass_kg <= 0.5)
  }
  constraint def C_002 {
    in pm_max_ug_m3: Real;
    in pm_resolution_ug_m3: Real;
    (pm_max_ug_m3 >= 1000.0) and (pm_resolution_ug_m3 <= 10.0)
  }
  constraint def C_003 {
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_max_ppm >= 2000.0) and (co2_accuracy_ppm <= 50.0)
  }
  constraint def C_004 {
    in temp_min_C: Real;
    in temp_max_C: Real;
    in temp_accuracy_C: Real;
    (temp_min_C <= -10.0) and (temp_max_C >= 50.0) and (temp_accuracy_C <= 1.0)
  }
  constraint def C_005 {
    in hum_min_pct: Real;
    in hum_max_pct: Real;
    in hum_accuracy_pct: Real;
    (hum_min_pct <= 0.0) and (hum_max_pct >= 90.0) and (hum_accuracy_pct <= 3.0)
  }
  constraint def C_006 {
    in runtime_hours: Real;
    (runtime_hours >= 8.0)
  }
  constraint def C_007 {
    in rechargeable: Boolean;
    in charge_time_hours: Real;
    (rechargeable) and (charge_time_hours <= 4.0)
  }
  constraint def C_008 {
    in wifi_supported: Boolean;
    in wifi_throughput_kbps: Real;
    (wifi_supported) and (wifi_throughput_kbps >= 1000.0)
  }
  constraint def C_009 {
    in bluetooth_supported: Boolean;
    in bt_throughput_kbps: Real;
    (bluetooth_supported) and (bt_throughput_kbps >= 100.0)
  }
  constraint def C_010 {
    in storage_records: Integer;
    in