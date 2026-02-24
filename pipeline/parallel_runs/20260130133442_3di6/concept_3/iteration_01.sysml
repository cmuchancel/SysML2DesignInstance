package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 { text = "Design a handheld environmental monitor that measures PM2.5, CO2, temperature, and humidity, runs 8 hours on a rechargeable battery, and syncs data via Wi-Fi or Bluetooth."; }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;
  part def PocketSync_Sensor_Dongle {
    attribute summary: String = "Ultra-portable pocket sensor that offloads heavy UI and cloud sync to the user's smartphone. Small enclosure contains a low-power optical PM2.5 sensor, a compact low-power NDIR CO2 sensor (or CO2 module with ABC algorithm), and a combined T/H sensor. Primary sync over Bluetooth Low Energy to the phone app; optional direct Wi‑Fi upload through built-in Wi‑Fi hotspot when phone not present. Minimal local interface (multi-color status LED + one button). Runtime tailored to 8 hours with a 3000 mAh battery by aggressive power optimization (intermittent sampling, sensor sleep modes) and by delegating long-term storage/visualization to the phone.";
  }
}
