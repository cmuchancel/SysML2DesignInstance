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
  part def Duty_Cycled_Ultra_Low_Power_Handheld {
    part sensorPM: Component { attribute airflow_LPM: Real; attribute pm25_range_ugm3: Real; }
    part sensorCO2: Component { attribute range_ppm: Real; }
    part sensorTH: Component { attribute temp_range_C: String; attribute humidity_range_pct: String; }
    part mcu: Component { attribute flash_MB: Real; attribute ram_MB: Real; }
    part battery: Component { attribute capacity_mAh: Real; }
    part radio: Component { attribute wifi: Boolean; attribute ble: Boolean; }
    part storage: Component { attribute sd_present: Boolean; }
    part ui: Component { attribute display_in: Real; }
    part enclosure: Component { attribute ip_rating: String; }
    port pwrIn: Port;
    port airIn: Port;
    port airOut: Port;
  }
  flow def AirSample { in q_lpm: Real; }
  flow def DataPath { in throughput_kbps: Real; }
  connection def AirPath { src: Duty_Cycled_Ultra_Low_Power_Handheld.airIn; dst: Duty_Cycled_Ultra_Low_Power_Handheld.sensorPM; }
  connection def PM_to_MCU { src: Duty_Cycled_Ultra_Low_Power_Handheld.sensorPM; dst: Duty_Cycled_Ultra_Low_Power_Handheld.mcu; }
  connection def CO2_to_MCU { src: Duty_Cycled_Ultra_Low_Power_Handheld.sensorCO2; dst: Duty_Cycled_Ultra_Low_Power_Handheld.mcu; }
  connection def TH_to_MCU { src: Duty_Cycled_Ultra_Low_Power_Handheld.sensorTH; dst: Duty_Cycled_Ultra_Low_Power_Handheld.mcu; }
  connection def MCU_to_Radio { src: Duty_Cycled_Ultra_Low_Power_Handheld.mcu; dst: Duty_Cycled_Ultra_Low_Power_Handheld.radio; }
  connection def MCU_to_UI { src: Duty_Cycled_Ultra_Low_Power_Handheld.mcu; dst: Duty_Cycled_Ultra_Low_Power_Handheld.ui; }
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
