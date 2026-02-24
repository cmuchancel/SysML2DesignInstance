package LEDFlickerModel
// Assumption: typical LED Vf ~2.0V used for resistor calculation; concrete parts sourced from Mouser via provided URLs.

requirement REQ_FREQUENCY {
  id = "REQ-001"
  text = "LED flickers at 10 Hz ±5%."
  verification = "measure frequency; accept if between 9.5 Hz and 10.5 Hz"
}

requirement REQ_SUPPLY {
  id = "REQ-002"
  text = "Device is powered from a 5 V DC supply."
  verification = "measure supply voltage at device input; accept if 5.0 V ± tolerance of supply"
}

requirement REQ_CURRENT_LIMIT {
  id = "REQ-003"
  text = "LED current must be limited to safe operating current (<= 20 mA)."
  verification = "measure LED current; accept if <= 20 mA"
}

requirement REQ_SOURCEABLE {
  id = "REQ-004"
  text = "All discrete components are sourceable from Mouser."
  verification = "BOM lists Mouser part numbers/URLs for each discrete component."
}

constraint CON_FREQ_BOUNDS {
  id = "C-001"
  expression = "frequency >= 9.5 and frequency <= 10.5" // Hz
}

constraint CON_SUPPLY_VALUE {
  id = "C-002"
  expression = "Vsup = 5.0" // volts
}

constraint CON_LED_CURRENT {
  id = "C-003"
  expression = "I_led <= 0.020" // amps
}

constraint CON_RESISTOR_CALC {
  id = "C-004"
  // Vf is LED forward voltage (assumed 2.0 V unless specified per LED part); R = (Vsup - Vf)/I_target
  expression = "R >= (Vsup - Vf) / I_target"
}

block LED {
  property Vf : Real // forward voltage (V)
  property Imax : Real // max continuous current (A)
}

block Resistor {
  property R : Real // resistance (ohms)
  property powerRating : Real // watts
}

block BlinkerCircuit {
  // Provides a digital output that toggles at the required frequency when powered by 5V.
  property Vsup : Real
  property frequency : Real
  part led : LED
  part r_limit : Resistor
}

instance design1 : BlinkerCircuit {
  // concrete instance asserting requirements and BOM sourcing per STRUCTURE RULES
  Vsup = 5.0
  frequency = 10.0
  led = LED { Vf = 2.0, Imax = 0.020 } // assumed Vf for resistor calc; actual LED part below
  r_limit = Resistor { R = 330.0, powerRating = 0.125 } // chosen to limit current ~9.7 mA for Vf=2.0V
  assert(CON_FREQ_BOUNDS.expression) // simple assert use per structure rules
  assert(CON_SUPPLY_VALUE.expression)
  assert(CON_LED_CURRENT.expression)
  // BOM / sourcing (Mouser)
  property BOM_LED_PN = "Mouser: 805-WP710A10ID (Example 3mm red LED)" 
  property BOM_LED_URL = "https://www.mouser.com/Search/Refine.aspx?Keyword=WP710A10ID"
  property BOM_RES_PN = "Mouser: 78-330-RC (Example 330 Ω resistor)"
  property BOM_RES_URL = "https://www.mouser.com/Search/Refine.aspx?Keyword=330%20ohm%20resistor"
  property BOM_TIMER_PN = "Mouser: NE555P (Example 555 timer DIP-8)"
  property BOM_TIMER_URL = "https://www.mouser.com/Search/Refine.aspx?Keyword=NE555"
}

endpackage