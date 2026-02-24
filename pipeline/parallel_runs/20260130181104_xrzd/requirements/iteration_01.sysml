package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be suitable for single-person handheld transport and operation.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    (mass_kg <= 2.0)
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 to support air-quality-aware operation.";
  }
  constraint def C_002 {
    in pm25_accuracy_ug: Real;
    (pm25_accuracy_ug <= 5.0)
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration to inform indoor air conditions.";
  }
  constraint def C_003 {
    in co2_max_range_ppm: Real;
    (co2_max_range_ppm >= 2000.0)
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature to support environmental awareness.";
  }
  constraint def C_004 {
    in temp_accuracy_C: Real;
    (temp_accuracy_C <= 0.5)
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure relative humidity to support environmental awareness.";
  }
  constraint def C_005 {
    in rh_accuracy_pct: Real;
    (rh_accuracy_pct <= 3.0)
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate on an internal rechargeable battery for typical session use.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    (runtime_hours >= 8.0) and (wireless_on = true)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization over Wi-Fi to exchange data with external systems.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    (wifi_supported = true)
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization over Bluetooth to exchange data with external systems.";
  }
  constraint def C_008 {
    in bt_supported: Boolean;
    (bt_supported = true)
  }
}