package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device mass shall be suitable for one-handed carry and operation.";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dimension_mm: Real;
    (mass_g <= 300.0) and (max_dimension_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter (PM2.5) for environmental monitoring.";
  }
  constraint def C_002 {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_resolution_ug_m3: Real;
    (pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_resolution_ug_m3 <= 1.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration for indoor air quality assessment.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature within a typical indoor range.";
  }
  constraint def C_004 {
    in temp_range_min_c: Real;
    in temp_range_max_c: Real;
    in temp_accuracy_c: Real;
    (temp_range_min_c <= -10.0) and (temp_range_max_c >= 50.0) and (temp_accuracy_c <= 0.5)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity for environmental monitoring.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    (rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for at least 8 hours when wireless sync is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    (wireless_on) implies (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Wi-Fi or Bluetooth sync: device shall provide data synchronization via Wi-Fi or Bluetooth.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    (wifi_supported) or (bluetooth_supported)
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: if Bluetooth is implemented, data transfer success rate shall be at least 95 percent.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in bluetooth_success_pct: Real;
    (bluetooth_supported) implies (bluetooth_success_pct >= 95.0)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Sensor {
    attribute mass_g: Real;
    attribute pm25_range_min_ug_m3: Real;
    attribute pm25_range_max_ug_m3: Real;
    attribute pm25_resolution_ug_m3: Real;
    attribute co2_range_min_ppm: Real;
    attribute co2_range_max_ppm: Real;
    attribute co2_accuracy_ppm: Real;
    attribute temp_range_min_c: Real;
    attribute temp_range_max_c: Real;
    attribute temp_accuracy_c: Real;
    attribute rh_range_min_pct: Real;
    attribute rh_range_max_pct: Real;
    attribute rh_accuracy_pct: Real;
    port dataOut: Port;
    port airIn: Port;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute cpu_MHz: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
    port pwrOut: Port;
  }

  part def PowerUnit {
    attribute capacity_mAh: Real;
    attribute nominal_V: Real;
    attribute avg_power_W: Real;
    attribute peak_power_W: Real;
    port pwrOut: Port;
    port chargeIn: Port;
  }

  part def Connectivity {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute wifi_throughput_kbps: Real;
    attribute ble_throughput_kbps: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def Storage {
    attribute flash_MB: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def UI {
    attribute display_in: Real;
    attribute touch: Boolean;
    attribute leds_count: Integer;
    port dataIn: Port;
    port pwrIn: Port;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dimension_mm: Real;
    attribute ingress_rating: String;
    port airIn: Port;
    port airOut: Port;
  }

  part def PM_Sensor extends Sensor {
    attribute airflow_LPM: Real;
  }

  part def CO2_Sensor extends Sensor {
    attribute co2Range_ppm: Real;
    attribute sampling_interval_s: Real;
  }

  part def TH_Sensor extends Sensor {
    attribute temp_offset_c: Real;
    attribute rh_offset_pct: Real;
  }

  part def HandheldMonitor {
    part pm: PM_Sensor {
      attribute pm25_range_min_ug_m3: Real = 0.0;
      attribute pm25_range_max_ug_m3: Real = 500.0;
      attribute pm25_resolution_ug_m3: Real = 1.0;
      attribute airflow_LPM: Real;
    }
    part co2: CO2_Sensor {
      attribute co2_range_min_ppm: Real = 400.0;
      attribute co2_range_max_ppm: Real = 5000.0;
      attribute co2_accuracy_ppm: Real;
      attribute co2Range_ppm: Real;
      attribute sampling_interval_s: Real;
    }
    part th: TH_Sensor {
      attribute temp_range_min_c: Real = -10.0;
      attribute temp_range_max_c: Real = 50.0;
      attribute temp_accuracy_c: Real;
      attribute rh_range_min_pct: Real = 0.0;
      attribute rh_range_max_pct: Real = 95.0;
      attribute rh_accuracy_pct: Real;
    }
    part mcu: MCU {
      attribute flash_MB: Real;
      attribute ram_MB: Real;
      attribute cpu_MHz: Real;
      port dataIn: Port;
      port dataOut: Port;
      port pwrIn: Port;
    }
    part power: PowerUnit {
      attribute capacity_mAh: Real;
      attribute nominal_V: Real = 3.7;
      attribute avg_power_W: Real;
      attribute peak_power_W: Real;
      port pwrOut: Port;
      port chargeIn: Port;
    }
    part radio: Connectivity {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute wifi_throughput_kbps: Real;
      attribute ble_throughput_kbps: Real;
      port dataIn: Port;
      port dataOut: Port;
      port pwrIn: Port;
    }
    part storage: Storage {
      attribute flash_MB: Real;
      port dataIn: Port;
      port dataOut: Port;
      port pwrIn: Port;
    }
    part ui: UI {
      attribute display_in: Real;
      attribute touch: Boolean;
      attribute leds_count: Integer;
      port dataIn: Port;
      port pwrIn: Port;
    }
    part enclosure: Enclosure {
      attribute mass_g: Real;
      attribute max_dimension_mm: Real;
      attribute ingress_rating: String;
      port airIn: Port;
      port airOut: Port;
    }

    port systemPowerIn: Port;
    port systemData: Port;
    port ambientAirIn: Port;
    port ambientAirOut: Port;

    // Physical/data flow paths
    flow def AirSample {
      in flow_LPM: Real;
    }
    flow def DataPacket {
      in size_bytes: Integer;
      in priority: Integer;
    }
    flow def PowerBus {
      in voltage_V: Real;
      in current_A: Real;
    }

    // Connections: sensors to MCU
    connection def PM_to_MCU {
      src: pm.dataOut;
      dst: mcu.dataIn;
    }
    connection def CO2_to_MCU {
      src: co2.dataOut;
      dst: mcu.dataIn;
    }
    connection def TH_to_MCU {
      src: th.dataOut;
      dst: mcu.dataIn;
    }

    // Connections: MCU to storage, radio, UI
    connection def MCU_to_Storage {
      src: mcu.dataOut;
      dst: storage.dataIn;
    }
    connection def MCU_to_Radio {
      src: mcu.dataOut;
      dst: radio.dataIn;
    }
    connection def MCU_to_UI {
      src: mcu.dataOut;
      dst: ui.dataIn;
    }

    // Power connections
    connection def Power_to_MCU {
      src: power.pwrOut;
      dst: mcu.pwrIn;
    }
    connection def Power_to_Radio {
      src: power.pwrOut;
      dst: radio.pwrIn;
    }
    connection def Power_to_Storage {
      src: power.pwrOut;
      dst: storage.pwrIn;
    }
    connection def Power_to_UI {
      src: power.pwrOut;
      dst: ui.pwrIn;
    }

    // Air paths: ambient -> enclosure -> sensors
    connection def Ambient_to_Enclosure {
      src: ambientAirIn;
      dst: enclosure.airIn;
    }
    connection def Enclosure_to_PM {
      src: enclosure.airOut;
      dst: pm.airIn;
    }
    connection def Enclosure_to_CO2 {
      src: enclosure.airOut;
      dst: co2.airIn;
    }
    connection def Enclosure_to_TH {
      src: enclosure.airOut;
      dst: th.airIn;
    }

    // Top-level exposed ports binding
    connection def SystemPowerIn_to_Power {
      src: systemPowerIn;
      dst: power.chargeIn;
    }
    connection def SystemData_to_Radio {
      src: systemData;
      dst: radio.dataIn;
    }
  }

  // Mid-level constraints and budgets
  constraint def C_runtime {
    in battery_capacity_mAh: Real;
    in battery_nominal_V: Real;
    in system_avg_power_W: Real;
    in required_runtime_h: Real;
    ((battery_capacity_mAh * battery_nominal_V / 1000.0) / system_avg_power_W) >= required_runtime_h
  }

  constraint def C_power_budget_peak {
    in peak_power_W: Real;
    in supply_limit_W: Real;
    peak_power_W <= supply_limit_W
  }

  constraint def C_data_throughput {
    in required_kbps: Real;
    in wifi_throughput_kbps: Real;
    in ble_throughput_kbps: Real;
    (wifi_throughput_kbps >= required_kbps) or (ble_throughput_kbps >= required_kbps)
  }

  constraint def C_physical_size {
    in enclosure_mass_g: Real;
    in enclosure_max_dimension_mm: Real;
    (enclosure_mass_g <= 300.0) and (enclosure_max_dimension_mm <= 180.0)
  }

  constraint def C_pm_sensor_range {
    in pm25_min: Real;
    in pm25_max: Real;
    in pm25_res: Real;
    (pm25_min <= 0.0) and (pm25_max >= 500.0) and (pm25_res <= 1.0)
  }

  constraint def C_co2_sensor_range {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  constraint def C_th_sensor_range {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_acc_c: Real;
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_acc_pct: Real;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_acc_c <= 0.5) and (rh_min_pct <= 0.0) and (rh_max_pct >= 95.0) and (rh_acc_pct <= 3.0)
  }

  // Bindings of constraint inputs to part attributes (informative in-parameters)
  // Battery runtime binding
  // in parameters refer to parts defined above
  // Link C_runtime to power part
  // Note: 'in' mapping uses parameter names that correspond to part attributes for traceability
  // Binding values will be provided during allocation; names are declared to reference parts.
  // Bindings represented by commentary-like in-parameters per instruction.
  constraint def Bind_C_runtime_to_Power {
    in battery_capacity_mAh: Real;
    in battery_nominal_V: Real;
    in system_avg_power_W: Real;
    in required_runtime_h: Real;
    battery_capacity_mAh = HandheldMonitor.power.capacity_mAh;
    battery_nominal_V = HandheldMonitor.power.nominal_V;
    system_avg_power_W = HandheldMonitor.power.avg_power_W;
    required_runtime_h = 8.0;
    ((battery_capacity_mAh * battery_nominal_V / 1000.0) / system_avg_power_W) >= required_runtime_h
  }

  constraint def Bind_C_power_peak {
    in peak_power_W: Real;
    in supply_limit_W: Real;
    peak_power_W = HandheldMonitor.power.peak_power_W;
    supply_limit_W = 10.0;
    peak_power_W <= supply_limit_W
  }

  constraint def Bind_C_data_throughput {
    in required_kbps: Real;
    in wifi_throughput_kbps: Real;
    in ble_throughput_kbps: Real;
    required_kbps = 100.0;
    wifi_throughput_kbps = HandheldMonitor.radio.wifi_throughput_kbps;
    ble_throughput_kbps = HandheldMonitor.radio.ble_throughput_kbps;
    (wifi_throughput_kbps >= required_kbps) or (ble_throughput_kbps >= required_kbps)
  }

  constraint def Bind_C_physical_size {
    in enclosure_mass_g: Real;
    in enclosure_max_dimension_mm: Real;
    enclosure_mass_g = HandheldMonitor.enclosure.mass_g;
    enclosure_max_dimension_mm = HandheldMonitor.enclosure.max_dimension_mm;
    (enclosure_mass_g <= 300.0) and (enclosure_max_dimension_mm <= 180.0)
  }

  constraint def Bind_C_pm_sensor_range {
    in pm25_min: Real;
    in pm25_max: Real;
    in pm25_res: Real;
    pm25_min = HandheldMonitor.pm.pm25_range_min_ug_m3;
    pm25_max = HandheldMonitor.pm.pm25_range_max_ug_m3;
    pm25_res = HandheldMonitor.pm.pm25_resolution_ug_m3;
    (pm25_min <= 0.0) and (pm25_max >= 500.0) and (pm25_res <= 1.0)
  }

  constraint def Bind_C_co2_sensor_range {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    co2_min_ppm = HandheldMonitor.co2.co2_range_min_ppm;
    co2_max_ppm = HandheldMonitor.co2.co2_range_max_ppm;
    co2_accuracy_ppm = HandheldMonitor.co2.co2_accuracy_ppm;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  constraint def Bind_C_th_sensor_range {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_acc_c: Real;
    in rh_min_pct: Real;
    in rh_max_pct: Real;
    in rh_acc_pct: Real;
    temp_min_c = HandheldMonitor.th.temp_range_min_c;
    temp_max_c = HandheldMonitor.th.temp_range_max_c;
    temp_acc_c = HandheldMonitor.th.temp_accuracy_c;
    rh_min_pct = HandheldMonitor.th.rh_range_min_pct;
    rh_max_pct = HandheldMonitor.th.rh_range_max_pct;
    rh_acc_pct = HandheldMonitor.th.rh_accuracy_pct;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_acc_c <= 0.5) and (rh_min_pct <= 0.0) and (rh_max_pct >= 95.0) and (rh_acc_pct <= 3.0)
  }

}
