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
  part def Professional_Continuous_Sampling_Monitor__Wi_Fi_Primary_ {
    part sensorPM: Part;
    part sensorCO2: Part;
    part sensorTH: Part;
    part mcu: Part;
    part battery: Part { attribute capacity_mAh: Real; }
    part wifiBle: Part;
    part ui: Part;
    part enclosure: Part;
  }
  constraint def C_runtime {
    in capacity_mAh: Real;
    in avg_power_W: Real;
    ((capacity_mAh * 3.7 / 1000) / avg_power_W) >= 8.0
  }
}
