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

  part def PM_Sensor {
    attribute range_max_ugpm3: Real;
    attribute accuracy_ugpm3: Real;
    attribute response_s: Real;
    attribute sampling_lpm: Real;
  }

  part def CO2_Sensor {
    attribute range_max_ppm: Real;
    attribute accuracy_ppm: Real;
    attribute response_s: Real;
  }

  part def Temp_Sensor {
    attribute min_degC: Real;
    attribute max_degC: Real;
    attribute accuracy_degC: Real;
  }

  part def RH_Sensor {
    attribute min_pct: Real;
    attribute max_pct: Real;
    attribute accuracy_pct: Real;
  }

  part def Compute {
    attribute mcu_mhz: Real;
    attribute active_power_W: Real;
    attribute standby_power_W: Real;
    attribute flash_MB: Real;
    attribute ram_MB: Real;
  }

  part def Power {
    attribute batteryCapacity_mAh: Real;
    attribute nominal_voltage_V: Real;
    attribute avg_system_power_W: Real;
    attribute rechargeable: Boolean;
  }

  part def Connectivity {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute wifi_throughput_kbps: Real;
    attribute ble_throughput_kbps: Real;
    attribute radio_power_W: Real;
  }

  part def Storage {
    attribute storage_MB: Real;
    attribute log_rate_s: Real;
  }

  part def UI {
    attribute displaySize_in: Real;
    attribute has_buttons: Boolean;
    attribute ui_power_W: Real;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
    attribute ingress_protection: String;
    attribute ergonomic_volume_cc: Real;
  }

  part def HandheldMonitor {
    part pmSensor: PM_Sensor {
      attribute range_max_ugpm3: Real;
      attribute accuracy_ugpm3: Real;
      attribute response_s: Real;
      attribute sampling_lpm: Real;
    }
    part co2Sensor: CO2_Sensor {
      attribute range_max_ppm: Real;
      attribute accuracy_ppm: Real;
      attribute response_s: Real;
    }
    part tempSensor: Temp_Sensor {
      attribute min_degC: Real;
      attribute max_degC: Real;
      attribute accuracy_degC: Real;
    }
    part rhSensor: RH_Sensor {
      attribute min_pct: Real;
      attribute max_pct: Real;
      attribute accuracy_pct: Real;
    }
    part compute: Compute {
      attribute mcu_mhz: Real;
      attribute active_power_W: Real;
      attribute standby_power_W: Real;
      attribute flash_MB: Real;
      attribute ram_MB: Real;
    }
    part power: Power {
      attribute batteryCapacity_mAh: Real;
      attribute nominal_voltage_V: Real;
      attribute avg_system_power_W: Real;
      attribute rechargeable: Boolean;
    }
    part connectivity: Connectivity {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute wifi_throughput_kbps: Real;
      attribute ble_throughput_kbps: Real;
      attribute radio_power_W: Real;
    }
    part storage: Storage {
      attribute storage_MB: Real;
      attribute log_rate_s: Real;
    }
    part ui: UI {
      attribute displaySize_in: Real;
      attribute has_buttons: Boolean;
      attribute ui_power_W: Real;
    }
    part enclosure: Enclosure {
      attribute mass_g: Real;
      attribute max_dim_mm: Real;
      attribute ingress_protection: String;
      attribute ergonomic_volume_cc: Real;
    }
  }

  constraint def C_runtime {
    in power: Power;
    in compute: Compute;
    in connectivity: Connectivity;
    in ui: UI;
    in runtime_hours_target: Real;
    in wireless_active: Boolean;
    (((power.batteryCapacity_mAh * power.nominal_voltage_V / 1000.0) / (compute.active_power_W + connectivity.radio_power_W + ui.ui_power_W)) >= runtime_hours_target) and (power.rechargeable) and (wireless_active)
  }

  constraint def C_pm_sensing {
    in pm: PM_Sensor;
    in pm25_range_max_ugpm3: Real;
    in pm25_accuracy_ugpm3: Real;
    in pm25_response_s: Real;
    (pm.range_max_ugpm3 >= pm25_range_max_ugpm3) and (pm.accuracy_ugpm3 <= pm25_accuracy_ugpm3) and (pm.response_s <= pm25_response_s)
  }

  constraint def C_co2_sensing {
    in co2: CO2_Sensor;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_response_s: Real;
    (co2.range_max_ppm >= co2_range_max_ppm) and (co2.accuracy_ppm <= co2_accuracy_ppm) and (co2.response_s <= co2_response_s)
  }

  constraint def C_temp_rh_sensing {
    in temp: Temp_Sensor;
    in rh: RH_Sensor;
    in temp_min_degC: Real;
    in temp_max_degC: Real;
    in temp_accuracy_degC: Real;
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_accuracy_pct: Real;
    (temp.min_degC <= temp_min_degC) and (temp.max_degC >= temp_max_degC) and (temp.accuracy_degC <= temp_accuracy_degC) and (rh.min_pct <= rh_min_pct) and (rh.max_pct >= rh_max_pct) and (rh.accuracy_pct <= rh_accuracy_pct)
  }

  constraint def C_connectivity_availability {
    in connectivity: Connectivity;
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (connectivity.wifi_supported or connectivity.bluetooth_supported) and (connectivity.wifi_supported == wifi_supported) and (connectivity.bluetooth_supported == bluetooth_supported)
  }

  constraint def C_formfactor {
    in enclosure: Enclosure;
    in mass_g_limit: Real;
    in max_dim_mm_limit: Real;
    (enclosure.mass_g <= mass_g_limit) and (enclosure.max_dim_mm <= max_dim_mm_limit)
  }

}
