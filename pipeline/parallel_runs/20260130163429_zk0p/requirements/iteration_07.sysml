package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device shall be operable with one hand and sized for pocket or bag carriage.";
  }
  constraint def C_001 {
    in length_mm: ScalarValues::Real;
    in width_mm: ScalarValues::Real;
    in thickness_mm: ScalarValues::Real;
    in mass_g: ScalarValues::Real;
    (length_mm <= 180.0) and (width_mm <= 80.0) and (thickness_mm <= 40.0) and (mass_g <= 400.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure PM2.5 concentration from 0 to at least 1000 ug/m3 with resolution 1 ug/m3 and accuracy within 10 ug/m3.";
  }
  constraint def C_002 {
    in pm_range_min_ug_m3: ScalarValues::Real;
    in pm_range_max_ug_m3: ScalarValues::Real;
    in pm_resolution_ug_m3: ScalarValues::Real;
    in pm_accuracy_ug_m3: ScalarValues::Real;
    (pm_range_min_ug_m3 <= 0.0) and (pm_range_max_ug_m3 >= 1000.0) and (pm_resolution_ug_m3 <= 1.0) and (pm_accuracy_ug_m3 <= 10.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure CO2 concentration covering at least 400 ppm to 5000 ppm with resolution 1 ppm and accuracy within 50 ppm.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: ScalarValues::Real;
    in co2_range_max_ppm: ScalarValues::Real;
    in co2_resolution_ppm: ScalarValues::Real;
    in co2_accuracy_ppm: ScalarValues::Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_resolution_ppm <= 1.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall report ambient temperature from -10 C to 50 C with resolution 0.1 C and accuracy 0.5 C.";
  }
  constraint def C_004 {
    in temp_range_min_C: ScalarValues::Real;
    in temp_range_max_C: ScalarValues::Real;
    in temp_resolution_C: ScalarValues::Real;
    in temp_accuracy_C: ScalarValues::Real;
    (temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_resolution_C <= 0.1) and (temp_accuracy_C <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall report relative humidity from 0% to at least 95% with resolution