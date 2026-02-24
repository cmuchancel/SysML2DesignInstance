package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with mass <= 500.0 grams and maximum external dimension <= 180.0 millimeters";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 500.0) and (max_dim_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "Measure PM2.5 with measurement range from 0.0 to at least 1000.0 ug/m3 and accuracy <= 10.0 ug/m3";
  }
  constraint def C_002 {
    in pm_min: Real;
    in pm_max: Real;
    in pm_acc_ug: Real;
    (pm_min = 0.0) and (pm_max >= 1000.0) and (pm_acc_ug <= 10.0)
  }
  requirement def RQ_003 {
    text = "Measure CO2 with measurement range covering at least 400.0 to 5000.0 ppm and accuracy <= 50.0 ppm";
  }
  constraint def C_003 {
    in co2_min: Real;
    in co2_max: Real;
    in co2_acc: Real;
    (co2_min <= 400.0) and (co2_max >= 5000.0) and (co2_acc <= 50.0)
  }
  requirement def RQ_004 {
    text = "Measure temperature across -10.0 to 50.0 degC with accuracy <= 0.5 degC";
  }
  constraint def C_004 {
    in t_min: Real;
    in t_max: Real;
    in t_acc: Real;
    (t_min <= -10.0) and (t_max >= 50.0) and (t_acc <= 0.5)
  }
  requirement def RQ_005 {
    text = "Measure relative humidity across 0.0 to 100.0 percent with accuracy <= 3.0 percent";
  }
  constraint def C_005 {
    in h_min: Real;
    in h_max: Real;
    in h_acc: Real;
    (h_min <= 0.0) and (h_max >= 100.0) and (h_acc <= 3.0)
  }
  requirement def RQ_006 {
    text = "Operate for at least 8.0 hours on a single rechargeable charge with wireless radios on and sampling active";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    (wireless_on = true) and (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Provide Wi-Fi sync capability or Bluetooth sync so that at least one wireless sync method is available";
  }
  constraint def C_007 {
    in wifi_enabled: Boolean;
    in bt_enabled: Boolean;
    (wifi_enabled = true) or (bt_enabled = true)
  }
  requirement def RQ_008 {
    text = "Provide Bluetooth sync capability or Wi-Fi sync so that at least one wireless sync method is available";
  }
  constraint def C_008 {
    in wifi_enabled: Boolean;
    in bt_enabled: Boolean;
    (wifi_enabled = true) or (bt_enabled = true)
  }
}