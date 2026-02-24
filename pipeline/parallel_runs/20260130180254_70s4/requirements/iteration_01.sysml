package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be portable for single-person carry and setup.";
  }
  constraint def C_001 {
    in mass_g: Real;
    (mass_g <= 500.0)
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall include a PM2.5 air-quality sensor to report particulate concentration near the device.";
  }
  constraint def C_002 {
    in pm25_min_ugm3: Real;
    in pm25_max_ugm3: Real;
    in pm25_resolution_ugm3: Real;
    in pm25_accuracy_ugm3: Real;
    (pm25_min_ugm3 <= 0.0) and (pm25_max_ugm3 >= 500.0) and (pm25_resolution_ugm3 <= 1.0) and (pm25_accuracy_ugm3 <= 10.0)
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall include a CO2 sensor to report ambient CO2 concentration relevant to indoor practice monitoring.";
  }
  constraint def C_003 {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature in typical practice ranges.";
  }
  constraint def C_004 {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_accuracy_c: Real;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_accuracy_c <= 1.0)
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity in typical practice ranges.";
  }
  constraint def C_005 {
    in hum_min_percent: Real;
    in hum_max_percent: Real;
    in hum_accuracy_percent: Real;
    (hum_min_percent <= 10.0) and (hum_max_percent >= 90.0) and (hum_accuracy_percent <= 5.0)
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate on an internal rechargeable battery while wireless sync is active for a practice-duration interval.";
  }
  constraint def C_006 {
    in rechargeable: Boolean;
    in wireless_on: Boolean;
    in runtime_hours: Real;
    (rechargeable = true) and (wireless_on = true) and (runtime_hours >= 4.0)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization of basic state and settings via Wi-Fi or an equivalent wireless link.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported = true) or (bluetooth_supported = true)
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization of basic state and settings via Bluetooth or an equivalent wireless link.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in wifi_supported: Boolean;
    (bluetooth_supported = true) or (wifi_supported = true)
  }
}