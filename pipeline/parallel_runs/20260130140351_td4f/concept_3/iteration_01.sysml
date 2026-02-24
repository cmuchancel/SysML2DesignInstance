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
part def Modular_Professional_Field_Monitor {
    part sensorPM: Component;
    part sensorCO2: Component;
    part sensorTH: Component;
    part mcu: Component;
    part battery: Component { attribute capacity_mAh: Real; }
    part wifiBle: Component;
    part ui: Component;
    part enclosure: Component;
  }
  constraint def C_runtime {
    in capacity_mAh: Real;
    in avg_power_W: Real;
    ((capacity_mAh * 3.7 / 1000) / avg_power_W) >= 8.0
  }
}
