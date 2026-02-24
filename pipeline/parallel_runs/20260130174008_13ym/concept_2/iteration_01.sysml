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
    (pm_min == 0.0) and (pm_max >= 1000.0) and (pm_acc_ug <= 10.0)
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
    (wireless_on == true) and (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Provide Wi-Fi sync capability or Bluetooth sync so that at least one wireless sync method is available";
  }
  constraint def C_007 {
    in wifi_enabled: Boolean;
    in bt_enabled: Boolean;
    (wifi_enabled == true) or (bt_enabled == true)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Sensor {
    attribute mass_g: Real;
    attribute power_W: Real;
  }

  part def PMSensor {
    attribute range_ug_m3_min: Real;
    attribute range_ug_m3_max: Real;
    attribute accuracy_ug: Real;
    attribute sampling_lpm: Real;
    attribute mass_g: Real;
    attribute power_W: Real;
    port dataOut: Port;
    port airIn: Port;
  }

  part def CO2Sensor {
    attribute range_ppm_min: Real;
    attribute range_ppm_max: Real;
    attribute accuracy_ppm: Real;
    attribute sampling_lpm: Real;
    attribute mass_g: Real;
    attribute power_W: Real;
    port dataOut: Port;
    port airIn: Port;
  }

  part def TempHumSensor {
    attribute temp_min_C: Real;
    attribute temp_max_C: Real;
    attribute temp_acc_C: Real;
    attribute hum_min_pct: Real;
    attribute hum_max_pct: Real;
    attribute hum_acc_pct: Real;
    attribute mass_g: Real;
    attribute power_W: Real;
    port dataOut: Port;
    port airIn: Port;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute cpu_MHz: Real;
    attribute power_W: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
    port pwrOut: Port;
  }

  part def Battery {
    attribute capacity_mAh: Real;
    attribute nominal_V: Real;
    attribute mass_g: Real;
    attribute avg_power_W: Real;
    port pwrOut: Port;
    port chargeIn: Port;
  }

  part def Radio {
    attribute wifi_enabled: Boolean;
    attribute bt_enabled: Boolean;
    attribute tx_power_W: Real;
    attribute data_rate_kbps: Real;
    attribute mass_g: Real;
    attribute power_W: Real;
    port dataIn: Port;
    port pwrIn: Port;
  }

  part def Storage {
    attribute flash_MB: Real;
    attribute mass_g: Real;
    attribute power_W: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def UI {
    attribute display_in: Real;
    attribute touch_enabled: Boolean;
    attribute mass_g: Real;
    attribute power_W: Real;
    port dataIn: Port;
    port pwrIn: Port;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
    attribute airflow_LPM: Real;
    port airIn: Port;
    port airOut: Port;
  }

  // Main system
  part def HandheldMonitor {
    attribute total_mass_g: Real;
    attribute max_external_dim_mm: Real;

    part pmSensor: PMSensor {
      attribute range_ug_m3_min: Real = 0.0;
      attribute range_ug_m3_max: Real = 1000.0;
      attribute accuracy_ug: Real = 10.0;
      attribute sampling_lpm: Real = 1.0;
      attribute mass_g: Real;
      attribute power_W: Real;
      port dataOut: Port;
      port airIn: Port;
    }

    part co2Sensor: CO2Sensor {
      attribute range_ppm_min: Real = 400.0;
      attribute range_ppm_max: Real = 5000.0;
      attribute accuracy_ppm: Real = 50.0;
      attribute sampling_lpm: Real = 0.5;
      attribute mass_g: Real;
      attribute power_W: Real;
      port dataOut: Port;
      port airIn: Port;
    }

    part thSensor: TempHumSensor {
      attribute temp_min_C: Real = -10.0;
      attribute temp_max_C: Real = 50.0;
      attribute temp_acc_C: Real = 0.5;
      attribute hum_min_pct: Real = 0.0;
      attribute hum_max_pct: Real = 100.0;
      attribute hum_acc_pct: Real = 3.0;
      attribute mass_g: Real;
      attribute power_W: Real;
      port dataOut: Port;
      port airIn: Port;
    }

    part mcu: MCU {
      attribute flash_MB: Real = 4.0;
      attribute ram_MB: Real = 1.0;
      attribute cpu_MHz: Real = 120.0;
      attribute power_W: Real;
      port dataIn: Port;
      port dataOut: Port;
      port pwrIn: Port;
      port pwrOut: Port;
    }

    part battery: Battery {
      attribute capacity_mAh: Real;
      attribute nominal_V: Real = 3.7;
      attribute mass_g: Real;
      attribute avg_power_W: Real;
      port pwrOut: Port;
      port chargeIn: Port;
    }

    part radio: Radio {
      attribute wifi_enabled: Boolean;
      attribute bt_enabled: Boolean;
      attribute tx_power_W: Real;
      attribute data_rate_kbps: Real;
      attribute mass_g: Real;
      attribute power_W: Real;
      port dataIn: Port;
      port pwrIn: Port;
    }

    part storage: Storage {
      attribute flash_MB: Real = 16.0;
      attribute mass_g: Real;
      attribute power_W: Real;
      port dataIn: Port;
      port dataOut: Port;
      port pwrIn: Port;
    }

    part ui: UI {
      attribute display_in: Real = 2.8;
      attribute touch_enabled: Boolean = true;
      attribute mass_g: Real;
      attribute power_W: Real;
      port dataIn: Port;
      port pwrIn: Port;
    }

    part enclosure: Enclosure {
      attribute mass_g: Real;
      attribute max_dim_mm: Real;
      attribute airflow_LPM: Real;
      port airIn: Port;
      port airOut: Port;
    }

    // System-level ports
    port externalPowerIn: Port;
    port wifiAntenna: Port;
    port btAntenna: Port;
    port userDisplay: Port;
    port airExternalIn: Port;
    port airExternalOut: Port;
    port dataSyncOut: Port;

    // Constraints applied to parts (mid-level budgets)
    constraint def C_batteryLife {
      in capacity_mAh: Real;
      in nominal_V: Real;
      in system_avg_power_W: Real;
      in required_hours: Real;
      ((capacity_mAh * nominal_V / 1000.0) / system_avg_power_W) >= required_hours
    }

    constraint def C_powerBudget {
      in mcu_power_W: Real;
      in sensors_power_W: Real;
      in radio_power_W: Real;
      in ui_power_W: Real;
      in storage_power_W: Real;
      in battery_power_W: Real;
      (mcu_power_W + sensors_power_W + radio_power_W + ui_power_W + storage_power_W) <= battery_power_W
    }

    constraint def C_massSize {
      in total_mass_g: Real;
      in max_external_dim_mm: Real;
      (total_mass_g <= 500.0) and (max_external_dim_mm <= 180.0)
    }

    constraint def C_pmSpec {
      in pm_min: Real;
      in pm_max: Real;
      in pm_acc_ug: Real;
      (pm_min == 0.0) and (pm_max >= 1000.0) and (pm_acc_ug <= 10.0)
    }

    constraint def C_co2Spec {
      in co2_min: Real;
      in co2_max: Real;
      in co2_acc: Real;
      (co2_min <= 400.0) and (co2_max >= 5000.0) and (co2_acc <= 50.0)
    }

    constraint def C_wirelessAvailability {
      in wifi_enabled: Boolean;
      in bt_enabled: Boolean;
      (wifi_enabled == true) or (bt_enabled == true)
    }

    // Connections between sensors and MCU
    connection def Conn_pm_to_mcu {
      src: pmSensor.dataOut;
      dst: mcu.dataIn;
    }

    connection def Conn_co2_to_mcu {
      src: co2Sensor.dataOut;
      dst: mcu.dataIn;
    }

    connection def Conn_th_to_mcu {
      src: thSensor.dataOut;
      dst: mcu.dataIn;
    }

    // MCU to peripherals
    connection def Conn_mcu_to_radio {
      src: mcu.dataOut;
      dst: radio.dataIn;
    }

    connection def Conn_mcu_to_storage {
      src: mcu.dataOut;
      dst: storage.dataIn;
    }

    connection def Conn_mcu_to_ui {
      src: mcu.dataOut;
      dst: ui.dataIn;
    }

    // Power connections
    connection def Conn_batt_to_mcu {
      src: battery.pwrOut;
      dst: mcu.pwrIn;
    }

    connection def Conn_batt_to_radio {
      src: battery.pwrOut;
      dst: radio.pwrIn;
    }

    connection def Conn_batt_to_ui {
      src: battery.pwrOut;
      dst: ui.pwrIn;
    }

    connection def Conn_batt_to_storage {
      src: battery.pwrOut;
      dst: storage.pwrIn;
    }

    // Air flow path from external through enclosure to sensors
    flow def AirSample {
      in flow_LPM: Real;
      out pm_ug_m3: Real;
      out co2_ppm: Real;
      out temp_C: Real;
      out hum_pct: Real;
    }

    connection def Air_in_to_enclosure {
      src: airExternalIn;
      dst: enclosure.airIn;
    }

    connection def Enclosure_to_pm {
      src: enclosure.airOut;
      dst: pmSensor.airIn;
    }

    connection def Enclosure_to_co2 {
      src: enclosure.airOut;
      dst: co2Sensor.airIn;
    }

    connection def Enclosure_to_th {
      src: enclosure.airOut;
      dst: thSensor.airIn;
    }

    // External data sync out
    connection def Radio_to_external {
      src: radio.dataIn;
      dst: dataSyncOut;
    }

    // Antenna connections
    connection def WifiAntenna_to_radio {
      src: wifiAntenna;
      dst: radio.dataIn;
    }

    connection def BTAntenna_to_radio {
      src: btAntenna;
      dst: radio.dataIn;
    }

    // Bind system-level UI port
    connection def UI_to_user {
      src: ui.dataIn;
      dst: userDisplay;
    }

    // Apply constraints to parts via 'in' parameter links
    // Battery life constraint
    // Map battery capacity, nominal V, system average power, and required hours (8.0)
    // 'in' parameter lines must end with semicolon as per instructions
    C_batteryLife.in capacity_mAh: battery.capacity_mAh;
    C_batteryLife.in nominal_V: battery.nominal_V;
    C_batteryLife.in system_avg_power_W: battery.avg_power_W;
    C_batteryLife.in required_hours: 8.0;

    // Power budget mapping
    C_powerBudget.in mcu_power_W: mcu.power_W;
    C_powerBudget.in sensors_power_W: (pmSensor.power_W + co2Sensor.power_W + thSensor.power_W);
    C_powerBudget.in radio_power_W: radio.power_W;
    C_powerBudget.in ui_power_W: ui.power_W;
    C_powerBudget.in storage_power_W: storage.power_W;
    C_powerBudget.in battery_power_W: battery.avg_power_W;

    // Mass and size mapping
    C_massSize.in total_mass_g: total_mass_g;
    C_massSize.in max_external_dim_mm: max_external_dim_mm;

    // PM spec mapping
    C_pmSpec.in pm_min: pmSensor.range_ug_m3_min;
    C_pmSpec.in pm_max: pmSensor.range_ug_m3_max;
    C_pmSpec.in pm_acc_ug: pmSensor.accuracy_ug;

    // CO2 spec mapping
    C_co2Spec.in co2_min: co2Sensor.range_ppm_min;
    C_co2Spec.in co2_max: co2Sensor.range_ppm_max;
    C_co2Spec.in co2_acc: co2Sensor.accuracy_ppm;

    // Wireless availability mapping
    C_wirelessAvailability.in wifi_enabled: radio.wifi_enabled;
    C_wirelessAvailability.in bt_enabled: radio.bt_enabled;

  }
}
