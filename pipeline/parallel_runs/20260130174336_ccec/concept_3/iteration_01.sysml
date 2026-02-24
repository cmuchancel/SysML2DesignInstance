package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device mass <= 300.0 grams and maximum dimension <= 180.0 mm.";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 300.0) and (max_dim_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: measure 0 to 500.0 ug/m3 with accuracy <= 5.0 ug/m3 and response time <= 60.0 s.";
  }
  constraint def C_002 {
    in pm25_range_max_ugpm3: Real;
    in pm25_accuracy_ugpm3: Real;
    in pm25_response_s: Real;
    (pm25_range_max_ugpm3 >= 500.0) and (pm25_accuracy_ugpm3 <= 5.0) and (pm25_response_s <= 60.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: measure up to 5000.0 ppm with accuracy <= 50.0 ppm and response time <= 120.0 s.";
  }
  constraint def C_003 {
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_response_s: Real;
    (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_response_s <= 120.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: measure -10.0 to 50.0 degC with accuracy <= 0.5 degC.";
  }
  constraint def C_004 {
    in temp_min_degC: Real;
    in temp_max_degC: Real;
    in temp_accuracy_degC: Real;
    (temp_min_degC <= -10.0) and (temp_max_degC >= 50.0) and (temp_accuracy_degC <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: measure 0.0 to 95.0 %RH with accuracy <= 3.0 %RH.";
  }
  constraint def C_005 {
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_min_pct <= 0.0) and (rh_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: operate for at least 8.0 hours with wireless (Wi-Fi or Bluetooth) active and be rechargeable.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in rechargeable: Boolean;
    in wireless_active: Boolean;
    (runtime_hours >= 8.0) and (rechargeable) and (wireless_active)
  }
  requirement def RQ_007 {
    text = "Wi-Fi sync: support data sync via Wi-Fi (or Bluetooth may be used instead).";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported or bluetooth_supported)
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: support data sync via Bluetooth (or Wi-Fi may be used instead).";
  }
  constraint def C_008 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported or bluetooth_supported)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Sensor {
    attribute power_W: Real;
    attribute mass_g: Real;
  }

  part def PM25Sensor {
    attribute range_max_ugpm3: Real;
    attribute accuracy_ugpm3: Real;
    attribute response_s: Real;
    attribute power_W: Real;
    attribute mass_g: Real;
  }

  part def CO2Sensor {
    attribute range_max_ppm: Real;
    attribute accuracy_ppm: Real;
    attribute response_s: Real;
    attribute power_W: Real;
    attribute mass_g: Real;
  }

  part def TempSensor {
    attribute min_degC: Real;
    attribute max_degC: Real;
    attribute accuracy_degC: Real;
    attribute power_W: Real;
    attribute mass_g: Real;
  }

  part def HumiditySensor {
    attribute min_pct: Real;
    attribute max_pct: Real;
    attribute accuracy_pct: Real;
    attribute power_W: Real;
    attribute mass_g: Real;
  }

  part def MCU {
    attribute active_power_W: Real;
    attribute idle_power_W: Real;
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute mass_g: Real;
  }

  part def Battery {
    attribute batteryCapacity_mAh: Real;
    attribute nominalVoltage_V: Real;
    attribute rechargeable: Boolean;
    attribute mass_g: Real;
  }

  part def Radio {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute tx_power_W: Real;
    attribute rx_power_W: Real;
    attribute mass_g: Real;
  }

  part def Storage {
    attribute onboard_MB: Real;
    attribute sd_present: Boolean;
    attribute mass_g: Real;
  }

  part def UI {
    attribute display_in: Real;
    attribute touch: Boolean;
    attribute power_W: Real;
    attribute mass_g: Real;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
    attribute volume_cc: Real;
  }

  part def HandheldMonitor {
    part pm25: PM25Sensor {
      attribute range_max_ugpm3: Real = 600.0;
      attribute accuracy_ugpm3: Real = 4.0;
      attribute response_s: Real = 30.0;
      attribute power_W: Real = 0.25;
      attribute mass_g: Real = 40.0;
    }
    part co2: CO2Sensor {
      attribute range_max_ppm: Real = 5000.0;
      attribute accuracy_ppm: Real = 40.0;
      attribute response_s: Real = 60.0;
      attribute power_W: Real = 0.15;
      attribute mass_g: Real = 30.0;
    }
    part temp: TempSensor {
      attribute min_degC: Real = -20.0;
      attribute max_degC: Real = 60.0;
      attribute accuracy_degC: Real = 0.3;
      attribute power_W: Real = 0.01;
      attribute mass_g: Real = 5.0;
    }
    part rh: HumiditySensor {
      attribute min_pct: Real = 0.0;
      attribute max_pct: Real = 95.0;
      attribute accuracy_pct: Real = 2.5;
      attribute power_W: Real = 0.01;
      attribute mass_g: Real = 5.0;
    }
    part mcu: MCU {
      attribute active_power_W: Real = 0.3;
      attribute idle_power_W: Real = 0.03;
      attribute flash_MB: Real = 4.0;
      attribute ram_MB: Real = 256.0;
      attribute mass_g: Real = 10.0;
    }
    part batt: Battery {
      attribute batteryCapacity_mAh: Real = 3500.0;
      attribute nominalVoltage_V: Real = 3.7;
      attribute rechargeable: Boolean = true;
      attribute mass_g: Real = 80.0;
    }
    part radio: Radio {
      attribute wifi_supported: Boolean = true;
      attribute bluetooth_supported: Boolean = true;
      attribute tx_power_W: Real = 0.2;
      attribute rx_power_W: Real = 0.08;
      attribute mass_g: Real = 12.0;
    }
    part storage: Storage {
      attribute onboard_MB: Real = 64.0;
      attribute sd_present: Boolean = false;
      attribute mass_g: Real = 8.0;
    }
    part ui: UI {
      attribute display_in: Real = 2.8;
      attribute touch: Boolean = true;
      attribute power_W: Real = 0.5;
      attribute mass_g: Real = 25.0;
    }
    part enclosure: Enclosure {
      attribute mass_g: Real = 60.0;
      attribute max_dim_mm: Real = 160.0;
      attribute volume_cc: Real = 200.0;
    }

    attribute estimated_total_mass_g: Real = pm25.mass_g + co2.mass_g + temp.mass_g + rh.mass_g + mcu.mass_g + batt.mass_g + radio.mass_g + storage.mass_g + ui.mass_g + enclosure.mass_g;
    attribute wireless_active: Boolean = true;
    attribute runtime_hours_target: Real = 8.0;
  }

  constraint def C_runtime {
    in device: HandheldMonitor;
    in battery: Battery;
    in mcu: MCU;
    in radio: Radio;
    in pm25: PM25Sensor;
    in co2: CO2Sensor;
    in ui: UI;
    in runtime_target_h: Real;
    ((battery.batteryCapacity_mAh * battery.nominalVoltage_V / 1000.0) / (mcu.active_power_W + radio.tx_power_W + pm25.power_W + co2.power_W + ui.power_W)) >= runtime_target_h
  }

  constraint def C_sensing_ranges {
    in pm25: PM25Sensor;
    in co2: CO2Sensor;
    in temp: TempSensor;
    in rh: HumiditySensor;
    (pm25.range_max_ugpm3 >= 500.0) and (pm25.accuracy_ugpm3 <= 5.0) and (pm25.response_s <= 60.0) and (co2.range_max_ppm >= 5000.0) and (co2.accuracy_ppm <= 50.0) and (co2.response_s <= 120.0) and (temp.min_degC <= -10.0) and (temp.max_degC >= 50.0) and (temp.accuracy_degC <= 0.5) and (rh.min_pct <= 0.0) and (rh.max_pct >= 95.0) and (rh.accuracy_pct <= 3.0)
  }

  constraint def C_connectivity_availability {
    in radio: Radio;
    (radio.wifi_supported or radio.bluetooth_supported)
  }

  constraint def C_formfactor {
    in device: HandheldMonitor;
    in enclosure: Enclosure;
    in mass_limit_g: Real;
    in max_dim_limit_mm: Real;
    (device.estimated_total_mass_g <= mass_limit_g) and (enclosure.max_dim_mm <= max_dim_limit_mm)
  }

}
