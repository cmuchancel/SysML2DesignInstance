package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 { text = "Design a handheld environmental monitor that measures PM2.5, CO2, temperature, and humidity, runs 8 hours on a rechargeable battery, and syncs data via Wi-Fi or Bluetooth."; }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;
  part def Balanced_Handheld_AirSense {
    attribute summary: String = "Compact consumer/prosumer handheld with integrated optical PM2.5 sensor, low‑power NDIR CO2 sensor, digital temperature/humidity combo sensor, active low-noise sampling (micro-fan), and an ESP32-class SoC providing both Wi‑Fi and Bluetooth.  Designed around a single PCB, 3.2' color touchscreen for local readout and menus, local data logging (ring buffer + microSD), and USB-C charging. Power management uses intermittent sampling and sensor duty‑cycling to guarantee an 8‑hour runtime on a single rechargeable 4000 mAh Li‑ion battery.";
  }
}
