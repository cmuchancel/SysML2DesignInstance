package FlickerLED;
import standard::library::*;
requirement FlickerFrequency {
  property minHz: Real = 9.5;
  property nominalHz: Real = 10.0;
  property maxHz: Real = 10.5;
  text = "LED flicker frequency 10 Hz ±5%";
}
block PowerSupply {
  property voltage: Real = 5.0;
}
block NE555 {
  property frequency: Real = 10.0;
  property vendor: String = "Texas Instruments";
  property partNumber: String = "NE555P";
}
block Resistor {
  property resistance: Real = 330.0;
  property power_W: Real = 0.25;
  property vendor: String = "Vishay";
  property partNumber: String = "CRCW330R";
}
block LED {
  property Vf: Real = 2.0;
  property If_mA: Real = 10.0;
  property vendor: String = "Kingbright";
  property partNumber: String = "WP7113ID";
}
block Circuit {
  part supply: PowerSupply;
  part timer: NE555;
  part r_limit: Resistor;
  part led: LED;
}
end FlickerLED