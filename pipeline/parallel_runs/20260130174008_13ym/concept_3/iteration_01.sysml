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

  part def PM_Sensor {
    attribute pm_range_min_ug_m3: Real;
    attribute pm_range_max_ug_m3: Real;
    attribute pm_accuracy_ug: Real;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def CO2_Sensor {
    attribute co2_range_min_ppm: Real;
    attribute co2_range_max_ppm: Real;
    attribute co2_accuracy_ppm: Real;
    port dataOut: Port;
    port pwrIn: Port;
    port airIn: Port;
  }

  part def TempHum_Sensor {
    attribute temp_min_C: Real;
    attribute temp_max_C: Real;
    attribute temp_accuracy_C: Real;
    attribute hum_min_pct: Real;
    attribute hum_max_pct: Real;
    attribute hum_accuracy_pct: Real;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    attribute cpu_MHz: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute batteryVoltage_V: Real;
    attribute avg_power_draw_W: Real;
    port pwrOut: Port;
    port chargeIn: Port;
  }

  part def PowerManagement {
    attribute efficiency_pct: Real;
    port pwrIn: Port;
    port pwrOut: Port;
  }

  part def Connectivity {
    attribute wifiEnabled: Boolean;
    attribute bleEnabled: Boolean;
    attribute tx_power_dBm: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def Storage {
    attribute storage_MB: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwrIn: Port;
  }

  part def UI {
    attribute displaySize_in: Real;
    attribute touchCapable: Boolean;
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

  // Main handheld environmental monitor system
  part def HandheldMonitor {
    part pmSensor: PM_Sensor {
      attribute pm_range_min_ug_m3: Real = 0.0;
      attribute pm_range_max_ug_m3: Real = 1000.0;
      attribute pm_accuracy_ug: Real = 10.0;
    }
    part co2Sensor: CO2_Sensor {
      attribute co2_range_min_ppm: Real = 400.0;
      attribute co2_range_max_ppm: Real = 5000.0;
      attribute co2_accuracy_ppm: Real = 50.0;
    }
    part thSensor: TempHum_Sensor {
      attribute temp_min_C: Real = -10.0;
      attribute temp_max_C: Real = 50.0;
      attribute temp_accuracy_C: Real = 0.5;
      attribute hum_min_pct: Real = 0.0;
      attribute hum_max_pct: Real = 100.0;
      attribute hum_accuracy_pct: Real = 3.0;
    }
    part mcu: MCU {
      attribute flash_MB: Real = 4.0;
      attribute ram_MB: Real = 1.0;
      attribute cpu_MHz: Real = 120.0;
    }
    part battery: PowerSubsystem {
      attribute batteryCapacity_mAh: Real = 3000.0;
      attribute batteryVoltage_V: Real = 3.7;
      attribute avg_power_draw_W: Real = 0.45;
    }
    part pmic: PowerManagement {
      attribute efficiency_pct: Real = 90.0;
    }
    part radio: Connectivity {
      attribute wifiEnabled: Boolean = true;
      attribute bleEnabled: Boolean = true;
      attribute tx_power_dBm: Real = 10.0;
    }
    part storage: Storage {
      attribute storage_MB: Real = 128.0;
    }
    part ui: UI {
      attribute displaySize_in: Real = 2.4;
      attribute touchCapable: Boolean = false;
    }
    part enclosure: Enclosure {
      attribute mass_g: Real = 250.0;
      attribute max_dim_mm: Real = 120.0;
      attribute airflow_LPM: Real = 1.5;
    }

    // Ports for system-level interfacing
    port systemPowerIn: Port;
    port systemChargeIn: Port;
    port ambientAirIn: Port;
    port dataOut: Port;

  }

  // Connections between sensors and MCU
  connection def PM_to_MCU {
    src: HandheldMonitor.pmSensor.dataOut;
    dst: HandheldMonitor.mcu.dataIn;
  }

  connection def CO2_to_MCU {
    src: HandheldMonitor.co2Sensor.dataOut;
    dst: HandheldMonitor.mcu.dataIn;
  }

  connection def TH_to_MCU {
    src: HandheldMonitor.thSensor.dataOut;
    dst: HandheldMonitor.mcu.dataIn;
  }

  // Connections from MCU to connectivity and UI and storage
  connection def MCU_to_Radio {
    src: HandheldMonitor.mcu.dataOut;
    dst: HandheldMonitor.radio.dataIn;
  }

  connection def MCU_to_UI {
    src: HandheldMonitor.mcu.dataOut;
    dst: HandheldMonitor.ui.dataIn;
  }

  connection def MCU_to_Storage {
    src: HandheldMonitor.mcu.dataOut;
    dst: HandheldMonitor.storage.dataIn;
  }

  // Power distribution connections
  connection def Battery_to_PMIC {
    src: HandheldMonitor.battery.pwrOut;
    dst: HandheldMonitor.pmic.pwrIn;
  }

  connection def PMIC_to_MCU {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.mcu.pwrIn;
  }

  connection def PMIC_to_Sensors {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.pmSensor.pwrIn;
  }

  connection def PMIC_to_CO2 {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.co2Sensor.pwrIn;
  }

  connection def PMIC_to_TH {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.thSensor.pwrIn;
  }

  connection def PMIC_to_Radio {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.radio.pwrIn;
  }

  connection def PMIC_to_UI {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.ui.pwrIn;
  }

  connection def PMIC_to_Storage {
    src: HandheldMonitor.pmic.pwrOut;
    dst: HandheldMonitor.storage.pwrIn;
  }

  // Airflow path from ambient through enclosure to CO2 and PM sensors
  flow def AirPath {
    in flow_LPM: Real;
    out sampled_air_LPM: Real;
  }

  connection def Ambient_to_Enclosure {
    src: HandheldMonitor.ambientAirIn;
    dst: HandheldMonitor.enclosure.airIn;
  }

  connection def Enclosure_to_CO2 {
    src: HandheldMonitor.enclosure.airOut;
    dst: HandheldMonitor.co2Sensor.airIn;
  }

  // Data out path to external sync
  connection def SystemDataOut {
    src: HandheldMonitor.radio.dataOut;
    dst: HandheldMonitor.dataOut;
  }

  // Constraint: runtime >= 8 hours with wireless on and sampling active
  constraint def C_battery_runtime {
    in capacity_mAh: Real;
    in batteryV_V: Real;
    in avg_power_W: Real;
    in runtime_hours: Real;
    in wireless_on: Boolean;
    ((capacity_mAh * batteryV_V / 1000.0) / avg_power_W) >= runtime_hours and (wireless_on == true) and (runtime_hours >= 8.0)
  }

  // Constraint: handheld mass and dimensions meet requirement
  constraint def C_form_factor {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 500.0) and (max_dim_mm <= 180.0)
  }

  // Constraint: PM sensor performance
  constraint def C_pm_budget {
    in pm_min: Real;
    in pm_max: Real;
    in pm_acc_ug: Real;
    (pm_min == 0.0) and (pm_max >= 1000.0) and (pm_acc_ug <= 10.0)
  }

  // Constraint: CO2 sensor performance
  constraint def C_co2_budget {
    in co2_min: Real;
    in co2_max: Real;
    in co2_acc: Real;
    (co2_min <= 400.0) and (co2_max >= 5000.0) and (co2_acc <= 50.0)
  }

  // Constraint: Wireless availability (at least one)
  constraint def C_wireless_avail {
    in wifi_enabled: Boolean;
    in bt_enabled: Boolean;
    (wifi_enabled == true) or (bt_enabled == true)
  }

  // Constraint usage mapping (in parameters link to parts)
  // Battery runtime mapping
  constraint def C_battery_mapping {
    in capacity_mAh: Real;
    in batteryV_V: Real;
    in avg_power_W: Real;
    in runtime_hours: Real;
    in wireless_on: Boolean;
    ((capacity_mAh * batteryV_V / 1000.0) / avg_power_W) >= runtime_hours and (wireless_on == true) and (runtime_hours >= 8.0)
  }

  // Map values from parts into the constraints via 'in' parameters (declarative linkage)
  // Note: these 'in' lines indicate which part attributes fulfill constraint inputs
  // Battery mapping inputs
  constraint def Map_BatteryInputs {
    in capacity_mAh: Real;
    in batteryV_V: Real;
    in avg_power_W: Real;
    in runtime_hours: Real;
    in wireless_on: Boolean;
    (capacity_mAh == HandheldMonitor.battery.batteryCapacity_mAh) and (batteryV_V == HandheldMonitor.battery.batteryVoltage_V) and (avg_power_W == HandheldMonitor.battery.avg_power_draw_W) and (runtime_hours == 8.0) and (wireless_on == (HandheldMonitor.radio.wifiEnabled or HandheldMonitor.radio.bleEnabled))
  }

  // Form factor mapping
  constraint def Map_FormFactorInputs {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g == HandheldMonitor.enclosure.mass_g) and (max_dim_mm == HandheldMonitor.enclosure.max_dim_mm)
  }

  // PM sensor mapping
  constraint def Map_PMInputs {
    in pm_min: Real;
    in pm_max: Real;
    in pm_acc_ug: Real;
    (pm_min == HandheldMonitor.pmSensor.pm_range_min_ug_m3) and (pm_max == HandheldMonitor.pmSensor.pm_range_max_ug_m3) and (pm_acc_ug == HandheldMonitor.pmSensor.pm_accuracy_ug)
  }

  // CO2 sensor mapping
  constraint def Map_CO2Inputs {
    in co2_min: Real;
    in co2_max: Real;
    in co2_acc: Real;
    (co2_min == HandheldMonitor.co2Sensor.co2_range_min_ppm) and (co2_max == HandheldMonitor.co2Sensor.co2_range_max_ppm) and (co2_acc == HandheldMonitor.co2Sensor.co2_accuracy_ppm)
  }

  // Wireless mapping
  constraint def Map_WirelessInputs {
    in wifi_enabled: Boolean;
    in bt_enabled: Boolean;
    (wifi_enabled == HandheldMonitor.radio.wifiEnabled) and (bt_enabled == HandheldMonitor.radio.bleEnabled)
  }

}
