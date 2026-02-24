package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be suitable for single-person hand carry and one-handed operation.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in volume_l: Real;
    in one_handed_operable: Boolean;
    ((mass_kg <= 1.5) and (volume_l <= 4.0) and (one_handed_operable = true))
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 for environmental-awareness during use.";
  }
  constraint def C_002 {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_accuracy_ug_m3: Real;
    in pm25_resolution_ug_m3: Real;
    ((pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_accuracy_ug_m3 <= 10.0) and (pm25_resolution_ug_m3 <= 1.0))
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall report ambient CO2 concentration to indicate ventilation conditions during practice.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    ((co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0))
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature to support environmental monitoring during use.";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_accuracy_C: Real;
    in temp_resolution_C: Real;
    ((temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_accuracy_C <= 1.0) and (temp_resolution_C <= 0.1))
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity to support environmental monitoring during use.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    in rh_resolution_pct: Real;
    ((rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0) and (rh_resolution_pct <= 1.0))
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for a full practice interval on internal rechargeable battery while wireless sync may be active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    in battery_rechargeable: Boolean;
    ((wireless_on = true) implies (runtime_hours >= 4.0)) and (battery_rechargeable = true)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization of measured environmental data via Wi-Fi or equivalent networked sync.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bt_supported: Boolean;
    ((wifi_supported = true) or (bt_supported = true))
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization of measured environmental data via Bluetooth or equivalent local sync.";
  }
  constraint def C_008 {
    in bt_supported: Boolean;
    in wifi_supported: Boolean;
    ((bt_supported = true) or (wifi_supported = true))
  }
}