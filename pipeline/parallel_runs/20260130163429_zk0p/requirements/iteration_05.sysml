package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device shall be operable with one hand and sized for pocket or bag carriage.";
  }
  constraint def C_001 {
    in length_mm: Real;
    in width_mm: Real;
    in thickness_mm: Real;
    in mass_g: Real;
    (length_mm <= 180.0) and (width_mm <= 80.0) and (thickness_mm <= 40.0) and (mass_g <= 400.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure PM2.5 concentration suitable for air quality assessment with outdoor/indoor ranges.";
  }
  constraint def C_002 {
    in pm_range_max_ug_m3: Real;
    in pm_resolution_ug_m3: Real;
    in pm_accuracy_ug_m3: Real;
    (pm_range_max_ug_m3 >= 1000.0) and (pm_resolution_ug_m3 <= 1.0) and (pm_accuracy_ug_m3 <= 10.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure CO2 concentration for indoor air quality monitoring across typical indoor concentration ranges.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_resolution_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_resolution_ppm <= 1.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall report ambient temperature with indoor-appropriate range and precision.";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_resolution_C: Real;
    in temp_accuracy_C: Real;
    (temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_resolution_C <= 0.1) and (temp_accuracy_C <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall report relative humidity with indoor-appropriate range and precision.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_resolution_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_resolution_pct <= 1.0) and (rh_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime: device shall operate continuously on internal battery for at least 8 hours under typical sensing and wireless use.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in typical_power_W: Real;
    in battery_capacity_Wh: Real;
    (runtime_hours >= 8.0) and (battery_capacity_Wh >= (runtime_hours * typical_power_W))
  }
  requirement def RQ_007 {
    text = "Rechargeable battery and charging: device shall include a rechargeable battery and support charging to 80% within a specified fast-charge duration.";
  }
  constraint def C_007 {
    in battery_type_code: Real;
    in time_to_80pct_hours: Real;
    in cycle_life_cycles: Real;
    (battery_type_code >= 0.0) and (time_to_80pct_hours <= 1.5) and (cycle_life_cycles >= 300.0)
  }
  requirement def RQ_008 {
    text = "Wi-Fi connectivity: device shall be capable of syncing collected data over Wi-Fi (2.4 GHz required, 5 GHz optional) to cloud or local services.";
  }
  constraint def C_008 {
    in wifi_24_supported: Real;
    in wifi_5_supported: Real;
    in wifi_throughput_kbps: Real;
    (wifi_24_supported >= 1.0) and (wifi_throughput_kbps >= 512.