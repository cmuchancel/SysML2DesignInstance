package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 { text = "Design a handheld environmental monitor that measures PM2.5, CO2, temperature, and humidity, runs 8 hours on a rechargeable battery, and syncs data via Wi-Fi or Bluetooth."; }
  constraint def C_runtime { in runtime_hr: Real; runtime_hr >= 8.0; }
}