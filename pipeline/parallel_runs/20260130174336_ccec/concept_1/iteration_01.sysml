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

  part def HandheldMonitor {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
    part pmSensor: ParticulateSensor {
      attribute pm25_range_max_ugpm3: Real;
      attribute pm25_accuracy_ugpm3: Real;
      attribute pm25_response_s: Real;
      attribute sampling_rate_s: Real;
    }
    part co2Sensor: CO2Sensor {
      attribute co2_range_max_ppm: Real;
      attribute co2_accuracy_ppm: Real;
      attribute co2_response_s: Real;
    }
    part envSensor: EnvSensor {
      attribute temp_min_degC: Real;
      attribute temp_max_degC: Real;
      attribute temp_accuracy_degC: Real;
      attribute rh_min_pct: Real;
      attribute rh_max_pct: Real;
      attribute rh_accuracy_pct: Real;
    }
    part compute: Compute {
      attribute cpu_mips: Real;
      attribute avg_power_W: Real;
      attribute flash_MB: Real;
      attribute sample_processing_ms: Real;
    }
    part power: Power {
      attribute batteryCapacity_mAh: Real;
      attribute battery_voltage_V: Real;
      attribute rechargeable: Boolean;
      attribute max_discharge_W: Real;
    }
    part radio: Radio {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute wifi_tx_mW: Real;
      attribute ble_tx_mW: Real;
      attribute wireless_active: Boolean;
    }
    part storage: Storage {
      attribute storage_MB: Real;
      attribute log_retention_days: Real;
    }
    part ui: UI {
      attribute displaySize_in: Real;
      attribute leds_present: Boolean;
    }
    part enclosure: Enclosure {
      attribute material: String;
      attribute thickness_mm: Real;
      attribute volume_cm3: Real;
    }
  }

  part def ParticulateSensor {
    attribute pm25_range_max_ugpm3: Real;
    attribute pm25_accuracy_ugpm3: Real;
    attribute pm25_response_s: Real;
    attribute sampling_rate_s: Real;
    attribute avg_power_W: Real;
  }

  part def CO2Sensor {
    attribute co2_range_max_ppm: Real;
    attribute co2_accuracy_ppm: Real;
    attribute co2_response_s: Real;
    attribute avg_power_W: Real;
  }

  part def EnvSensor {
    attribute temp_min_degC: Real;
    attribute temp_max_degC: Real;
    attribute temp_accuracy_degC: Real;
    attribute rh_min_pct: Real;
    attribute rh_max_pct: Real;
    attribute rh_accuracy_pct: Real;
    attribute avg_power_W: Real;
  }

  part def Compute {
    attribute cpu_mips: Real;
    attribute avg_power_W: Real;
    attribute flash_MB: Real;
    attribute sample_processing_ms: Real;
  }

  part def Power {
    attribute batteryCapacity_mAh: Real;
    attribute battery_voltage_V: Real;
    attribute rechargeable: Boolean;
    attribute max_discharge_W: Real;
  }

  part def Radio {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute wifi_tx_mW: Real;
    attribute ble_tx_mW: Real;
    attribute wireless_active: Boolean;
  }

  part def Storage {
    attribute storage_MB: Real;
    attribute log_retention_days: Real;
  }

  part def UI {
    attribute displaySize_in: Real;
    attribute leds_present: Boolean;
    attribute avg_power_W: Real;
  }

  part def Enclosure {
    attribute material: String;
    attribute thickness_mm: Real;
    attribute volume_cm3: Real;
  }

  constraint def C_runtime_budget {
    in batteryCapacity_mAh: Real;
    in battery_voltage_V: Real;
    in compute_avg_power_W: Real;
    in pmSensor_power_W: Real;
    in co2Sensor_power_W: Real;
    in envSensor_power_W: Real;
    in radio_wireless_active: Boolean;
    in radio_wifi_tx_mW: Real;
    in radio_ble_tx_mW: Real;
    in ui_power_W: Real;
    ((batteryCapacity_mAh * battery_voltage_V / 1000.0) / (compute_avg_power_W + pmSensor_power_W + co2Sensor_power_W + envSensor_power_W + (radio_wireless_active ? (radio_wifi_tx_mW/1000.0 + radio_ble_tx_mW/1000.0) : 0.0) + ui_power_W)) >= 8.0
  }

  constraint def C_sensing_requirements {
    in pm25_range_max_ugpm3: Real;
    in pm25_accuracy_ugpm3: Real;
    in pm25_response_s: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_response_s: Real;
    in temp_min_degC: Real;
    in temp_max_degC: Real;
    in temp_accuracy_degC: Real;
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_accuracy_pct: Real;
    (pm25_range_max_ugpm3 >= 500.0) and (pm25_accuracy_ugpm3 <= 5.0) and (pm25_response_s <= 60.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_response_s <= 120.0) and (temp_min_degC <= -10.0) and (temp_max_degC >= 50.0) and (temp_accuracy_degC <= 0.5) and (rh_min_pct <= 0.0) and (rh_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }

  constraint def C_connectivity_availability {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported or bluetooth_supported)
  }

  constraint def C_form_factor {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 300.0) and (max_dim_mm <= 180.0)
  }

  constraint def C_processing_throughput {
    in cpu_mips: Real;
    in sample_processing_ms: Real;
    in sample_rate_s: Real;
    (cpu_mips * 1.0 / sample_processing_ms) >= (1.0 / sample_rate_s)
  }

}
