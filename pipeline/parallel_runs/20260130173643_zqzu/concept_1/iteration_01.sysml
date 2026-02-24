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

  part def HandheldMonitor {
    attribute mass_g: Real;
    attribute max_dimension_mm: Real;

    part pm_sensor: PM_Sensor {
      attribute pm25_range_min_ug_m3: Real;
      attribute pm25_range_max_ug_m3: Real;
      attribute pm25_resolution_ug_m3: Real;
      attribute intake_airflow_LPM: Real;
      port airIn: Port;
      port dataOut: Port;
      port powerIn: Port;
    }

    part co2_sensor: CO2_Sensor {
      attribute co2_range_min_ppm: Real;
      attribute co2_range_max_ppm: Real;
      attribute co2_accuracy_ppm: Real;
      attribute sample_airflow_LPM: Real;
      port airIn: Port;
      port dataOut: Port;
      port powerIn: Port;
    }

    part env_sensor: TempHum_Sensor {
      attribute temp_range_min_c: Real;
      attribute temp_range_max_c: Real;
      attribute temp_accuracy_c: Real;
      attribute rh_range_min_pct: Real;
      attribute rh_range_max_pct: Real;
      attribute rh_accuracy_pct: Real;
      port airIn: Port;
      port dataOut: Port;
      port powerIn: Port;
    }

    part mcu: MCU {
      attribute flash_MB: Real;
      attribute ram_MB: Real;
      attribute cpu_MHz: Real;
      port dataIn: Port;
      port dataOut: Port;
      port powerIn: Port;
    }

    part battery: Battery {
      attribute batteryCapacity_mAh: Real;
      attribute nominalVoltage_V: Real;
      attribute avg_load_W: Real;
      port powerOut: Port;
      port chargeIn: Port;
    }

    part power_mgmt: PowerManagement {
      attribute efficiency_pct: Real;
      port powerIn: Port;
      port powerOut: Port;
    }

    part radio: Radio {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute wifi_tx_mbps: Real;
      attribute bluetooth_tx_kbps: Real;
      port dataIn: Port;
      port powerIn: Port;
    }

    part storage: Storage {
      attribute storage_MB: Real;
      attribute sd_present: Boolean;
      port dataIn: Port;
      port powerIn: Port;
    }

    part ui: UI {
      attribute displaySize_in: Real;
      attribute touch: Boolean;
      port dataIn: Port;
      port powerIn: Port;
    }

    part enclosure: Enclosure {
      attribute material: String;
      attribute max_dimension_mm: Real;
      attribute mass_g: Real;
      port airIn: Port;
      port airOut: Port;
    }

    // External ambient ports
    port ambientAir: Port;
    port usbCharge: Port;
    port userInterface: Port;

    // Flows
    flow def AirFlow {
      in rate_LPM: Real;
    }

    flow def DataFlow {
      in throughput_kbps: Real;
    }

    flow def PowerFlow {
      in power_W: Real;
    }

    // Connections: air path from ambient to enclosure to sensors
    connection def AirPath_PM {
      src: ambientAir;
      dst: enclosure.airIn;
    }

    connection def EnclosureToPMSensor {
      src: enclosure.airOut;
      dst: pm_sensor.airIn;
    }

    connection def EnclosureToCO2 {
      src: enclosure.airOut;
      dst: co2_sensor.airIn;
    }

    connection def EnclosureToEnv {
      src: enclosure.airOut;
      dst: env_sensor.airIn;
    }

    // Data connections between sensors and MCU
    connection def PM_to_MCU {
      src: pm_sensor.dataOut;
      dst: mcu.dataIn;
    }

    connection def CO2_to_MCU {
      src: co2_sensor.dataOut;
      dst: mcu.dataIn;
    }

    connection def ENV_to_MCU {
      src: env_sensor.dataOut;
      dst: mcu.dataIn;
    }

    // MCU to peripherals
    connection def MCU_to_Radio {
      src: mcu.dataOut;
      dst: radio.dataIn;
    }

    connection def MCU_to_Storage {
      src: mcu.dataOut;
      dst: storage.dataIn;
    }

    connection def MCU_to_UI {
      src: mcu.dataOut;
      dst: ui.dataIn;
    }

    // Power distribution
    connection def Battery_to_PM {
      src: battery.powerOut;
      dst: pm_sensor.powerIn;
    }

    connection def Battery_to_CO2 {
      src: battery.powerOut;
      dst: co2_sensor.powerIn;
    }

    connection def Battery_to_ENV {
      src: battery.powerOut;
      dst: env_sensor.powerIn;
    }

    connection def Battery_to_MCU {
      src: battery.powerOut;
      dst: mcu.powerIn;
    }

    connection def Battery_to_Radio {
      src: battery.powerOut;
      dst: radio.powerIn;
    }

    connection def Battery_to_Storage {
      src: battery.powerOut;
      dst: storage.powerIn;
    }

    connection def Battery_to_UI {
      src: battery.powerOut;
      dst: ui.powerIn;
    }

    // Charge path
    connection def USB_to_Battery {
      src: usbCharge;
      dst: battery.chargeIn;
    }

    // Example binding: ensure MCU data bandwidth allocation to radio and storage
    binding def BandwidthAllocation {
      source: mcu.dataOut;
      target1: radio.dataIn;
      target2: storage.dataIn;
    }

  }

  // Part definitions
  part def PM_Sensor {
    attribute pm25_range_min_ug_m3: Real;
    attribute pm25_range_max_ug_m3: Real;
    attribute pm25_resolution_ug_m3: Real;
    attribute intake_airflow_LPM: Real;
    port airIn: Port;
    port dataOut: Port;
    port powerIn: Port;
  }

  part def CO2_Sensor {
    attribute co2_range_min_ppm: Real;
    attribute co2_range_max_ppm: Real;
    attribute co2_accuracy_ppm: Real;
    attribute sample_airflow_LPM: Real;
    port airIn: Port;
    port dataOut: Port;
    port powerIn: Port;
  }

  part def TempHum_Sensor {
    attribute temp_range_min_c: Real;
    attribute temp_range_max_c: Real;
    attribute temp_accuracy_c: Real;
    attribute rh_range_min_pct: Real;
    attribute rh_range_max_pct: Real;
    attribute rh_accuracy_pct: Real;
    port airIn: Port;
    port dataOut: Port;
    port powerIn: Port;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute cpu_MHz: Real;
    port dataIn: Port;
    port dataOut: Port;
    port powerIn: Port;
  }

  part def Battery {
    attribute batteryCapacity_mAh: Real;
    attribute nominalVoltage_V: Real;
    attribute avg_load_W: Real;
    port powerOut: Port;
    port chargeIn: Port;
  }

  part def PowerManagement {
    attribute efficiency_pct: Real;
    port powerIn: Port;
    port powerOut: Port;
  }

  part def Radio {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute wifi_tx_mbps: Real;
    attribute bluetooth_tx_kbps: Real;
    port dataIn: Port;
    port powerIn: Port;
  }

  part def Storage {
    attribute storage_MB: Real;
    attribute sd_present: Boolean;
    port dataIn: Port;
    port powerIn: Port;
  }

  part def UI {
    attribute displaySize_in: Real;
    attribute touch: Boolean;
    port dataIn: Port;
    port powerIn: Port;
  }

  part def Enclosure {
    attribute material: String;
    attribute max_dimension_mm: Real;
    attribute mass_g: Real;
    port airIn: Port;
    port airOut: Port;
  }

  // Constraint definitions (mid-level budgets)

  constraint def C_battery_runtime {
    in capacity_mAh: Real;
    in nominalVoltage_V: Real;
    in avg_system_power_W: Real;
    in target_runtime_hours: Real;
    // estimated runtime = (capacity_mAh * nominalVoltage_V / 1000) / avg_system_power_W
    ((capacity_mAh * nominalVoltage_V / 1000.0) / avg_system_power_W) >= target_runtime_hours
  }

  constraint def C_power_budget_sensors {
    in pm_power_W: Real;
    in co2_power_W: Real;
    in env_power_W: Real;
    in mcu_power_W: Real;
    in radio_power_W: Real;
    in ui_power_W: Real;
    in margin_W: Real;
    (pm_power_W + co2_power_W + env_power_W + mcu_power_W + radio_power_W + ui_power_W + margin_W) <= 5.0
  }

  constraint def C_data_throughput {
    in sensor_aggregate_kbps: Real;
    in radio_wifi_mbps: Real;
    in radio_bt_kbps: Real;
    in required_sync_kbps: Real;
    // ensure at least one path meets required sync throughput
    ((radio_wifi_mbps * 1000.0) >= required_sync_kbps) or (radio_bt_kbps >= required_sync_kbps)
  }

  constraint def C_form_factor {
    in mass_g: Real;
    in max_dimension_mm: Real;
    (mass_g <= 300.0) and (max_dimension_mm <= 180.0)
  }

  constraint def C_pm_spec {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_resolution_ug_m3: Real;
    (pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_resolution_ug_m3 <= 1.0)
  }

  constraint def C_co2_spec {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    (co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0)
  }

  constraint def C_temp_hum_spec {
    in temp_range_min_c: Real;
    in temp_range_max_c: Real;
    in temp_accuracy_c: Real;
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    (temp_range_min_c <= -10.0) and (temp_range_max_c >= 50.0) and (temp_accuracy_c <= 0.5) and (rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0)
  }

  constraint def C_bluetooth_success {
    in bluetooth_supported: Boolean;
    in bluetooth_success_pct: Real;
    (bluetooth_supported) implies (bluetooth_success_pct >= 95.0)
  }

  // Instances linking mid-level constraints to parts (example 'in' bindings)

  // Battery runtime allocation
  instance BATT_runtime_check: C_battery_runtime {
    in capacity_mAh = HandheldMonitor.battery.batteryCapacity_mAh;
    in nominalVoltage_V = HandheldMonitor.battery.nominalVoltage_V;
    in avg_system_power_W = HandheldMonitor.battery.avg_load_W;
    in target_runtime_hours = 8.0;
  }

  // Power budget check across components
  instance PowerBudget: C_power_budget_sensors {
    in pm_power_W = 0.5;
    in co2_power_W = 0.8;
    in env_power_W = 0.05;
    in mcu_power_W = 0.6;
    in radio_power_W = 1.5;
    in ui_power_W = 0.4;
    in margin_W = 0.15;
  }

  // Data throughput check
  instance DataBudget: C_data_throughput {
    in sensor_aggregate_kbps = 200.0;
    in radio_wifi_mbps = HandheldMonitor.radio.wifi_tx_mbps;
    in radio_bt_kbps = HandheldMonitor.radio.bluetooth_tx_kbps;
    in required_sync_kbps = 500.0;
  }

  // Form factor linked to enclosure
  instance FormFactorCheck: C_form_factor {
    in mass_g = HandheldMonitor.enclosure.mass_g;
    in max_dimension_mm = HandheldMonitor.enclosure.max_dimension_mm;
  }

  // Sensor spec checks
  instance PM_Spec_Check: C_pm_spec {
    in pm25_range_min_ug_m3 = HandheldMonitor.pm_sensor.pm25_range_min_ug_m3;
    in pm25_range_max_ug_m3 = HandheldMonitor.pm_sensor.pm25_range_max_ug_m3;
    in pm25_resolution_ug_m3 = HandheldMonitor.pm_sensor.pm25_resolution_ug_m3;
  }

  instance CO2_Spec_Check: C_co2_spec {
    in co2_range_min_ppm = HandheldMonitor.co2_sensor.co2_range_min_ppm;
    in co2_range_max_ppm = HandheldMonitor.co2_sensor.co2_range_max_ppm;
    in co2_accuracy_ppm = HandheldMonitor.co2_sensor.co2_accuracy_ppm;
  }

  instance TempHum_Spec_Check: C_temp_hum_spec {
    in temp_range_min_c = HandheldMonitor.env_sensor.temp_range_min_c;
    in temp_range_max_c = HandheldMonitor.env_sensor.temp_range_max_c;
    in temp_accuracy_c = HandheldMonitor.env_sensor.temp_accuracy_c;
    in rh_range_min_pct = HandheldMonitor.env_sensor.rh_range_min_pct;
    in rh_range_max_pct = HandheldMonitor.env_sensor.rh_range_max_pct;
    in rh_accuracy_pct = HandheldMonitor.env_sensor.rh_accuracy_pct;
  }

  instance BT_Success_Check: C_bluetooth_success {
    in bluetooth_supported = HandheldMonitor.radio.bluetooth_supported;
    in bluetooth_success_pct = 98.0;
  }

  // Example flow instances
  instance AmbientToPMFlow: AirFlow {
    in rate_LPM = HandheldMonitor.pm_sensor.intake_airflow_LPM;
  }

  instance SensorDataFlowToMCU: DataFlow {
    in throughput_kbps = 200.0;
  }

  instance BatteryPowerFlow: PowerFlow {
    in power_W = HandheldMonitor.battery.avg_load_W;
  }

}
