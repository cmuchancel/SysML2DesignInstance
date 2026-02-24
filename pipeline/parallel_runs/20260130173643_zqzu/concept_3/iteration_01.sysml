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
  }

  part def PM25Sensor extends Sensor {
    attribute range_min_ug_m3: Real;
    attribute range_max_ug_m3: Real;
    attribute resolution_ug_m3: Real;
    port dataOut: Port;
    port airIn: Port;
    attribute sample_flow_LPM: Real;
  }

  part def CO2Sensor extends Sensor {
    attribute range_min_ppm: Real;
    attribute range_max_ppm: Real;
    attribute accuracy_ppm: Real;
    port dataOut: Port;
    port airIn: Port;
    attribute warmup_s: Real;
  }

  part def THSensor extends Sensor {
    attribute temp_range_min_C: Real;
    attribute temp_range_max_C: Real;
    attribute temp_accuracy_C: Real;
    attribute rh_range_min_pct: Real;
    attribute rh_range_max_pct: Real;
    attribute rh_accuracy_pct: Real;
    port dataOut: Port;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    port gpio: Port;
    port i2c: Port;
    port spi: Port;
    port uart: Port;
    port usbPower: Port;
    port netData: Port;
    attribute avg_power_active_W: Real;
    attribute avg_power_idle_W: Real;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute nominal_voltage_V: Real;
    attribute charger_present: Boolean;
    port pwrOut: Port;
    port pwrIn: Port;
    attribute avg_draw_W: Real;
  }

  part def Connectivity {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute max_throughput_kbps: Real;
    port dataIn: Port;
    port dataOut: Port;
    attribute avg_power_W: Real;
  }

  part def Storage {
    attribute flash_MB: Real;
    attribute circular_buffer_minutes: Real;
    port dataPort: Port;
  }

  part def UI {
    attribute displaySize_in: Real;
    attribute display_power_W: Real;
    attribute leds_count: Integer;
    port uiData: Port;
    port pwr: Port;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dimension_mm: Real;
    attribute ingress_protection: String;
    port airIn: Port;
    port airOut: Port;
  }

  part def HandheldMonitor {
    part pmSensor: PM25Sensor {
      range_min_ug_m3 = 0.0;
      range_max_ug_m3 = 1000.0;
      resolution_ug_m3 = 0.5;
      sample_flow_LPM = 1.0;
      mass_g = 35.0;
    }
    part co2Sensor: CO2Sensor {
      range_min_ppm = 400.0;
      range_max_ppm = 10000.0;
      accuracy_ppm = 40.0;
      warmup_s = 30.0;
      mass_g = 45.0;
    }
    part thSensor: THSensor {
      temp_range_min_C = -10.0;
      temp_range_max_C = 60.0;
      temp_accuracy_C = 0.3;
      rh_range_min_pct = 0.0;
      rh_range_max_pct = 95.0;
      rh_accuracy_pct = 2.5;
      mass_g = 10.0;
    }
    part mcu: MCU {
      flash_MB = 8.0;
      ram_MB = 2.0;
      avg_power_active_W = 0.12;
      avg_power_idle_W = 0.02;
    }
    part power: PowerSubsystem {
      batteryCapacity_mAh = 4000.0;
      nominal_voltage_V = 3.7;
      charger_present = true;
      avg_draw_W = 0.5;
    }
    part radio: Connectivity {
      wifi_supported = true;
      bluetooth_supported = true;
      max_throughput_kbps = 10000.0;
      avg_power_W = 0.2;
    }
    part storage: Storage {
      flash_MB = 64.0;
      circular_buffer_minutes = 7 * 24 * 60;
    }
    part ui: UI {
      displaySize_in = 2.4;
      display_power_W = 0.15;
      leds_count = 3;
    }
    part enclosure: Enclosure {
      mass_g = 120.0;
      max_dimension_mm = 160.0;
      ingress_protection = "IP20";
    }

    port systemPowerIn: Port;
    port systemData: Port;
    port ambientAirIn: Port;
    port ambientAirOut: Port;

    // Item/energy/data flow points
    flow def AirFlow {
      in flow_LPM: Real;
    }

    flow def DataFlow {
      in kbps: Real;
    }

    flow def PowerFlow {
      in watts: Real;
    }

    // Connections: air path from enclosure to sensors
    connection def AirPath_PM {
      src: enclosure.airIn;
      dst: pmSensor.airIn;
    }

    connection def AirPath_CO2 {
      src: enclosure.airIn;
      dst: co2Sensor.airIn;
    }

    connection def SensorToMCU_PM {
      src: pmSensor.dataOut;
      dst: mcu.i2c;
    }

    connection def SensorToMCU_CO2 {
      src: co2Sensor.dataOut;
      dst: mcu.uart;
    }

    connection def SensorToMCU_TH {
      src: thSensor.dataOut;
      dst: mcu.i2c;
    }

    connection def MCUtoRadio {
      src: mcu.netData;
      dst: radio.dataIn;
    }

    connection def MCUtoUI {
      src: mcu.uart;
      dst: ui.uiData;
    }

    connection def MCUtoStorage {
      src: mcu.spi;
      dst: storage.dataPort;
    }

    connection def PowerToMCU {
      src: power.pwrOut;
      dst: mcu.usbPower;
    }

    connection def PowerToRadio {
      src: power.pwrOut;
      dst: radio.dataOut;
    }

    connection def PowerToUI {
      src: power.pwrOut;
      dst: ui.pwr;
    }

    // Flow bindings (example numeric placeholders)
    binding def AirSampleFlow {
      src: enclosure.airIn;
      dst: pmSensor.airIn;
      AirFlow.flow_LPM = pmSensor.sample_flow_LPM;
    }

    binding def DataBus {
      src: mcu.netData;
      dst: radio.dataIn;
      DataFlow.kbps = radio.max_throughput_kbps;
    }

    binding def PowerBus {
      src: power.pwrOut;
      dst: mcu.usbPower;
      PowerFlow.watts = power.avg_draw_W;
    }
  }

  // Constraint defs expressing mid-level budgets

  constraint def C_power_budget {
    in battery_mAh: Real;
    in nominal_V: Real;
    in system_avg_W: Real;
    in required_runtime_h: Real;
    in wireless_on: Boolean;
    // estimate runtime hours = (battery_mAh * nominal_V / 1000) / system_avg_W
    ((battery_mAh * nominal_V / 1000.0) / system_avg_W) >= required_runtime_h
  }

  constraint def C_size_mass_budget {
    in total_mass_g: Real;
    in max_mass_g: Real;
    in max_dimension_mm: Real;
    in allowed_dimension_mm: Real;
    (total_mass_g <= max_mass_g) and (max_dimension_mm <= allowed_dimension_mm)
  }

  constraint def C_pm25_sensor_budget {
    in pm25_min: Real;
    in pm25_max: Real;
    in pm25_res: Real;
    (pm25_min <= 0.0) and (pm25_max >= 500.0) and (pm25_res <= 1.0)
  }

  constraint def C_co2_sensor_budget {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  constraint def C_data_throughput {
    in radio_throughput_kbps: Real;
    in required_kbps: Real;
    radio_throughput_kbps >= required_kbps
  }

  // Link constraints to parts via 'in' parameters
  // Power budget applied to PowerSubsystem and overall system
  constraint def Bind_power_budget {
    in battery_mAh: Real;
    in nominal_V: Real;
    in system_avg_W: Real;
    in required_runtime_h: Real;
    in wireless_on: Boolean;
    battery_mAh = HandheldMonitor.power.batteryCapacity_mAh;
    nominal_V = HandheldMonitor.power.nominal_voltage_V;
    system_avg_W = HandheldMonitor.power.avg_draw_W + HandheldMonitor.mcu.avg_power_active_W + HandheldMonitor.radio.avg_power_W + HandheldMonitor.ui.display_power_W;
    required_runtime_h = 8.0;
    wireless_on = true;
    ((battery_mAh * nominal_V / 1000.0) / system_avg_W) >= required_runtime_h
  }

  // Size and mass budget binding
  constraint def Bind_size_mass {
    in total_mass_g: Real;
    in max_mass_g: Real;
    in max_dimension_mm: Real;
    in allowed_dimension_mm: Real;
    total_mass_g = HandheldMonitor.enclosure.mass_g + HandheldMonitor.pmSensor.mass_g + HandheldMonitor.co2Sensor.mass_g + HandheldMonitor.thSensor.mass_g + HandheldMonitor.mcu.flash_MB * 0.0;
    max_mass_g = 300.0;
    max_dimension_mm = HandheldMonitor.enclosure.max_dimension_mm;
    allowed_dimension_mm = 180.0;
    (total_mass_g <= max_mass_g) and (max_dimension_mm <= allowed_dimension_mm)
  }

  // Sensor performance bindings
  constraint def Bind_pm25 {
    in pm25_min: Real;
    in pm25_max: Real;
    in pm25_res: Real;
    pm25_min = HandheldMonitor.pmSensor.range_min_ug_m3;
    pm25_max = HandheldMonitor.pmSensor.range_max_ug_m3;
    pm25_res = HandheldMonitor.pmSensor.resolution_ug_m3;
    (pm25_min <= 0.0) and (pm25_max >= 500.0) and (pm25_res <= 1.0)
  }

  constraint def Bind_co2 {
    in co2_min_ppm: Real;
    in co2_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    co2_min_ppm = HandheldMonitor.co2Sensor.range_min_ppm;
    co2_max_ppm = HandheldMonitor.co2Sensor.range_max_ppm;
    co2_accuracy_ppm = HandheldMonitor.co2Sensor.accuracy_ppm;
    (co2_min_ppm <= 400.0) and (co2_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  constraint def Bind_data {
    in radio_throughput_kbps: Real;
    in required_kbps: Real;
    radio_throughput_kbps = HandheldMonitor.radio.max_throughput_kbps;
    required_kbps = 100.0;
    radio_throughput_kbps >= required_kbps
  }

  // Example connection bindings between sensor parts and MCU, and MCU to connectivity/UI already defined above.
}
