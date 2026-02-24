package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Design a handheld environmental monitor that measures PM2.5, CO2, temperature, and humidity, runs 8 hours on a rechargeable battery, and syncs data via Wi-Fi or Bluetooth.";
  }
  constraint def C_runtime {
    in runtime_hr: Real;
    (runtime_hr >= 8.0)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;
  part def Component { }
  port def AirPort { }
  port def PowerPort { }
  part def Pocket_Low_Power_Monitor {
    part sensorPM: Component { attribute airflow_LPM: Real; attribute pm25_range_ugm3: Real; }
    part sensorCO2: Component { attribute range_ppm: Real; }
    part sensorTH: Component { attribute temp_range_C: String; attribute humidity_range_pct: String; }
    part mcu: Component { attribute flash_MB: Real; attribute ram_MB: Real; }
    part battery: Component { attribute capacity_mAh: Real; attribute avg_power_W: Real; }
    part radio: Component { attribute wifi: Boolean; attribute ble: Boolean; }
    part storage: Component { attribute sd_present: Boolean; }
    part ui: Component { attribute display_in: Real; }
    part enclosure: Component { attribute ip_rating: String; }
    port airIn: AirPort;
    port airOut: AirPort;
    port pwrIn: PowerPort;
    connection air_to_pm { src: airIn; dst: sensorPM; }
    connection pm_to_mcu { src: sensorPM; dst: mcu; }
    connection co2_to_mcu { src: sensorCO2; dst: mcu; }
    connection th_to_mcu { src: sensorTH; dst: mcu; }
    connection mcu_to_radio { src: mcu; dst: radio; }
    connection mcu_to_ui { src: mcu; dst: ui; }
  }
  constraint def C_runtime {
    in capacity_mAh: Real;
    in avg_power_W: Real;
    ((capacity_mAh * 3.7 / 1000) / avg_power_W) >= 8.0
  }
  constraint def C_airflow {
    in q_lpm: Real;
    (q_lpm >= 0.5)
  }
}
