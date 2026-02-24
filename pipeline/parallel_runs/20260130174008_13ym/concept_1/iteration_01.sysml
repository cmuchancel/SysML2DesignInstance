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
    attribute pmRange_ugm3_min: Real;
    attribute pmRange_ugm3_max: Real;
    attribute pmAccuracy_ug: Real;
    port dataOut: Port;
    port airIn: Port;
    attribute airflow_LPM: Real;
  }

  part def CO2_Sensor {
    attribute co2Range_ppm_min: Real;
    attribute co2Range_ppm_max: Real;
    attribute co2Accuracy_ppm: Real;
    port dataOut: Port;
    port airIn: Port;
  }

  part def TempHumid_Sensor {
    attribute tempRange_degC_min: Real;
    attribute tempRange_degC_max: Real;
    attribute tempAccuracy_degC: Real;
    attribute humRange_pct_min: Real;
    attribute humRange_pct_max: Real;
    attribute humAccuracy_pct: Real;
    port dataOut: Port;
    port airIn: Port;
  }

  part def MCU {
    attribute flash_MB: Real;
    attribute ram_MB: Real;
    port dataIn: Port;
    port dataOut: Port;
    port pwr: Port;
    attribute avg_power_W: Real;
  }

  part def Battery {
    attribute capacity_mAh: Real;
    attribute chemistry_V: Real;
    port pwrOut: Port;
  }

  part def PowerManagement {
    attribute conversion_efficiency: Real;
    port pwrIn: Port;
    port pwrOut: Port;
  }

  part def WiFiRadio {
    attribute wifi_enabled: Boolean;
    attribute throughput_kbps: Real;
    port dataIn: Port;
    port pwr: Port;
  }

  part def BTRadio {
    attribute bt_enabled: Boolean;
    attribute throughput_kbps: Real;
    port dataIn: Port;
    port pwr: Port;
  }

  part def Storage {
    attribute storage_MB: Real;
    port dataIn: Port;
  }

  part def Display {
    attribute displaySize_in: Real;
    attribute displayPower_W: Real;
    port dataIn: Port;
    port pwr: Port;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
    attribute ingress_airflow_LPM: Real;
  }

  part def Fan {
    attribute airflow_LPM: Real;
    attribute power_W: Real;
    port airIn: Port;
    port airOut: Port;
    port pwr: Port;
  }

  part def Connector {
    port data: Port;
    port pwr: Port;
  }

  flow def AirSample {
    in flow_LPM: Real;
    out particulates_ugm3: Real;
  }

  flow def DataStream {
    in kbps: Real;
    out latency_ms: Real;
  }

  connection def Conn_PM_to_MCU {
    src: PM_Sensor.dataOut;
    dst: MCU.dataIn;
  }

  connection def Conn_CO2_to_MCU {
    src: CO2_Sensor.dataOut;
    dst: MCU.dataIn;
  }

  connection def Conn_TH_to_MCU {
    src: TempHumid_Sensor.dataOut;
    dst: MCU.dataIn;
  }

  connection def Conn_MCU_to_WIFI {
    src: MCU.dataOut;
    dst: WiFiRadio.dataIn;
  }

  connection def Conn_MCU_to_BT {
    src: MCU.dataOut;
    dst: BTRadio.dataIn;
  }

  connection def Conn_MCU_to_DISPLAY {
    src: MCU.dataOut;
    dst: Display.dataIn;
  }

  connection def Conn_BATT_to_PM {
    src: Battery.pwrOut;
    dst: PM_Sensor.dataOut;
  }

  connection def Conn_BATT_to_PWRMGT {
    src: Battery.pwrOut;
    dst: PowerManagement.pwrIn;
  }

  connection def Conn_PWRMGT_to_MCU {
    src: PowerManagement.pwrOut;
    dst: MCU.pwr;
  }

  connection def Conn_PWRMGT_to_RADIOS {
    src: PowerManagement.pwrOut;
    dst: WiFiRadio.pwr;
  }

  connection def Conn_PWRMGT_to_BT {
    src: PowerManagement.pwrOut;
    dst: BTRadio.pwr;
  }

  connection def Conn_PWRMGT_to_DISPLAY {
    src: PowerManagement.pwrOut;
    dst: Display.pwr;
  }

  connection def AirPath_Inlet_to_Fan {
    src: Enclosure;
    dst: Fan.airIn;
  }

  connection def AirPath_Fan_to_PM {
    src: Fan.airOut;
    dst: PM_Sensor.airIn;
  }

  part HandheldMonitor {
    part pm: PM_Sensor {
      attribute pmRange_ugm3_min: Real = 0.0;
      attribute pmRange_ugm3_max: Real = 1000.0;
      attribute pmAccuracy_ug: Real = 10.0;
      attribute airflow_LPM: Real = 1.5;
    }
    part co2: CO2_Sensor {
      attribute co2Range_ppm_min: Real = 0.0;
      attribute co2Range_ppm_max: Real = 5000.0;
      attribute co2Accuracy_ppm: Real = 50.0;
    }
    part th: TempHumid_Sensor {
      attribute tempRange_degC_min: Real = -10.0;
      attribute tempRange_degC_max: Real = 50.0;
      attribute tempAccuracy_degC: Real = 0.5;
      attribute humRange_pct_min: Real = 0.0;
      attribute humRange_pct_max: Real = 100.0;
      attribute humAccuracy_pct: Real = 3.0;
    }
    part mcu: MCU {
      attribute flash_MB: Real = 8.0;
      attribute ram_MB: Real = 1.0;
      attribute avg_power_W: Real = 0.35;
    }
    part batt: Battery {
      attribute capacity_mAh: Real = 3000.0;
      attribute chemistry_V: Real = 3.7;
    }
    part pwr: PowerManagement {
      attribute conversion_efficiency: Real = 0.9;
    }
    part wifi: WiFiRadio {
      attribute wifi_enabled: Boolean = true;
      attribute throughput_kbps: Real = 2000.0;
    }
    part bt: BTRadio {
      attribute bt_enabled: Boolean = true;
      attribute throughput_kbps: Real = 500.0;
    }
    part storage_local: Storage {
      attribute storage_MB: Real = 64.0;
    }
    part ui_display: Display {
      attribute displaySize_in: Real = 2.8;
      attribute displayPower_W: Real = 0.2;
    }
    part enclosure: Enclosure {
      attribute mass_g: Real = 320.0;
      attribute max_dim_mm: Real = 150.0;
      attribute ingress_airflow_LPM: Real = 2.0;
    }
    part intake_fan: Fan {
      attribute airflow_LPM: Real = 2.0;
      attribute power_W: Real = 0.3;
    }
    part usb: Connector;

    port externalPowerIn: Port;
    port userDataPort: Port;
  }

  constraint def C_battery_runtime {
    in capacity_mAh: Real;
    in battery_V: Real;
    in system_avg_W: Real;
    ((capacity_mAh * battery_V / 1000.0) / system_avg_W) >= 8.0
  }

  constraint def C_size_mass {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 500.0) and (max_dim_mm <= 180.0)
  }

  constraint def C_pm_spec {
    in pm_min: Real;
    in pm_max: Real;
    in pm_acc_ug: Real;
    (pm_min == 0.0) and (pm_max >= 1000.0) and (pm_acc_ug <= 10.0)
  }

  constraint def C_co2_spec {
    in co2_min: Real;
    in co2_max: Real;
    in co2_acc: Real;
    (co2_min <= 400.0) and (co2_max >= 5000.0) and (co2_acc <= 50.0)
  }

  constraint def C_temp_spec {
    in t_min: Real;
    in t_max: Real;
    in t_acc: Real;
    (t_min <= -10.0) and (t_max >= 50.0) and (t_acc <= 0.5)
  }

  constraint def C_hum_spec {
    in h_min: Real;
    in h_max: Real;
    in h_acc: Real;
    (h_min <= 0.0) and (h_max >= 100.0) and (h_acc <= 3.0)
  }

  constraint def C_wireless_available {
    in wifi_enabled: Boolean;
    in bt_enabled: Boolean;
    (wifi_enabled == true) or (bt_enabled == true)
  }

  constraint def C_throughput {
    in wifi_kbps: Real;
    in bt_kbps: Real;
    (wifi_kbps >= 1000.0) or (bt_kbps >= 250.0)
  }

}
