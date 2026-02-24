package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device shall be portable with ergonomic dimensions and mass suitable for single-hand carry and pocketable storage.";
  }
  constraint def C_001 {
    in length_mm: Real;
    in width_mm: Real;
    in thickness_mm: Real;
    in mass_g: Real;
    (length_mm <= 180.0) and (width_mm <= 80.0) and (thickness_mm <= 40.0) and (mass_g <= 400.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter (PM2.5) in ambient air with defined range, resolution, and accuracy.";
  }
  constraint def C_002 {
    in pm_range_min_ug_m3: Real;
    in pm_range_max_ug_m3: Real;
    in pm_resolution_ug_m3: Real;
    in pm_accuracy_ug_m3: Real;
    (pm_range_min_ug_m3 <= 0.0) and (pm_range_max_ug_m3 >= 1000.0) and (pm_resolution_ug_m3 <= 1.0) and (pm_accuracy_ug_m3 <= 10.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure carbon dioxide concentration with defined range, resolution, and accuracy suitable for indoor air quality monitoring.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_resolution_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_resolution_ppm <= 1.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature within a range and accuracy appropriate for indoor environmental monitoring.";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_resolution_C: Real;
    in temp_accuracy_C: Real;
    (temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_resolution_C <= 0.1) and (temp_accuracy_C <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure relative humidity within a range and accuracy suitable for indoor environments.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_resolution_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.