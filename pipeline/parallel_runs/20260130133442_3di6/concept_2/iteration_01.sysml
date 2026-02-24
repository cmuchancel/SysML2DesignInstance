package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 { text = "Design a handheld environmental monitor that measures PM2.5, CO2, temperature, and humidity, runs 8 hours on a rechargeable battery, and syncs data via Wi-Fi or Bluetooth."; }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;
  part def Rugged_Field_Pro_Monitor {
    attribute summary: String = "Durable, mission-oriented handheld for professionals and field technicians. Modular sensor cartridges allow use of high-accuracy NDIR CO2 cartridges and a high-flow optical PM2.5 module with replaceable pump. Built with a larger swappable battery pack (10,000 mAh) to support continuous active sampling for 8+ hours even under high sampling rates. Primary connectivity via Wi‑Fi for direct upload to enterprise servers; BLE used for local handset control. Includes hardened IP65 enclosure, glove-friendly interface (physical buttons + sunlight-readable monochrome LCD), GPS timestamping and optional rugged cradle for vehicle use.";
  }
}
