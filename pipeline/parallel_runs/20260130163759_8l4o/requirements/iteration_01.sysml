package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with device volume <= 250.0 cubic centimeters and mass <= 350.0 grams";
  }
  requirement def RQ_002 {
    text = "PM2.5 sensor capable of measuring 0.0 to 1000.0 micrograms per cubic meter with resolution <= 1.0 ug/m3 and accuracy <= 10.0 percent";
  }
  requirement def RQ_003 {
    text = "CO2 sensor capable of measuring 400.0 to 5000.0 ppm with accuracy <= 50.0 ppm";
  }
  requirement def RQ_004 {
    text = "Temperature sensor range from -10.0 to 50.0 degrees Celsius with accuracy <= 0.5 degrees Celsius and resolution <= 0.1 degrees Celsius";
  }
  requirement def RQ_005 {
    text = "Relative humidity sensor range 0.0 to 100.0 percent RH with accuracy <= 3.0 percent RH and resolution <= 0.1 percent RH";
  }
  requirement def RQ_006 {
    text = "Operational runtime on internal rechargeable battery of at least 8.0 hours under typical usage profile";
  }
  requirement def RQ_007 {
    text = "Rechargeable battery and charging system supporting USB-C charging with full charge time <= 4.0 hours";
  }
  requirement def RQ_008 {
    text = "Wi-Fi connectivity supporting 802.11 b/g/n at 2.4 GHz and secure data sync with minimum uplink throughput >= 1.0 Mbps";
  }
  requirement def RQ_009 {
    text = "Bluetooth connectivity supporting BLE 4.2 or later with effective range >=