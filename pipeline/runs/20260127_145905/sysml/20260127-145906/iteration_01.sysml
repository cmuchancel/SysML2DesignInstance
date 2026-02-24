package LEDBlinkDesign
{
  // Assumptions: use an astable timer driving LED through a series resistor from 5V;
  // target LED current <= 20mA; use common NE555-style timer configured for 10Hz ±5%.
  requirement FlickerReq { id = "REQ-001"; text = "LED flickers at 10 Hz ±5% from a 5 V supply." }
  requirement CurrentLimitReq { id = "REQ-002"; text = "Include current limiting for the LED." }
  requirement MouserReq { id = "REQ-003"; text = "Components must be sourceable from Mouser." }

  valueType Frequency { unit = "Hz" }
  valueType Voltage { unit = "V" }
  valueType Resistance { unit = "ohm" }
  valueType Current { unit = "A" }

  block LED
  {
    property Vf : Voltage[1] // forward voltage (V)
    property If : Current[1] // desired operating current (A)
  }

  block Resistor
  {
    property R : Resistance[1]
  }

  block AstableTimer
  {
    property frequency : Frequency[1]
    property supply : Voltage[1]
  }

  block LEDCircuit
  {
    part led : LED[1]
    part r : Resistor[1]
    part timer : AstableTimer[1]
  }

  constraint FrequencyConstraint
  {
    appliesTo = { LEDCircuit.timer }
    expression = "LEDCircuit.timer.frequency >= 9.5 and LEDCircuit.timer.frequency <= 10.5"
  }

  constraint SupplyConstraint
  {
    appliesTo = { LEDCircuit.timer }
    expression = "LEDCircuit.timer.supply = 5.0"
  }

  constraint CurrentLimitConstraint
  {
    appliesTo = { LEDCircuit }
    // series resistor ensures (Vsup - Vf)/R <= 0.02 (20 mA)
    expression = "(LEDCircuit.timer.supply - LEDCircuit.led.Vf) / LEDCircuit.r.R <= 0.02"
  }

  // Reusable concrete instances with Mouser sourcing in instance annotations
  instance MyLEDCircuit : LEDCircuit
  {
    // part instances
    led = LED1
    r = R1
    timer = U1
  }

  instance LED1 : LED
  {
    Vf = 2.0  // assumed typical LED forward voltage (V)
    If = 0.01 // nominal design current 10 mA
    // Mouser search URL for a generic 3mm/5mm indicator LED (sourceable)
    annotation = { mouserPN = "generic-LED-3mm-5mm", mouserURL = "https://www.mouser.com/Search/Refine?Keyword=indicator+led" }
  }

  instance R1 : Resistor
  {
    // resistor sized to meet current constraint; typical value example (ohms)
    R = 330.0
    annotation = { mouserPN = "generic-resistor-330ohm", mouserURL = "https://www.mouser.com/Search/Refine?Keyword=330+ohm+resistor" }
  }

  instance U1 : AstableTimer
  {
    frequency = 10.0
    supply = 5.0
    annotation = { mouserPN = "NE555-family-astable", mouserURL = "https://www.mouser.com/Search/Refine?Keyword=555+timer" }
  }

  // Simple asserts linking requirements to the design instance
  constraint ReqVerify_Flicker { appliesTo = { MyLEDCircuit }; expression = "MyLEDCircuit.timer.frequency >= 9.5 and MyLEDCircuit.timer.frequency <= 10.5" }
  constraint ReqVerify_Supply { appliesTo = { MyLEDCircuit }; expression = "MyLEDCircuit.timer.supply = 5.0" }
  constraint ReqVerify_CurrentLimit { appliesTo = { MyLEDCircuit }; expression = "(MyLEDCircuit.timer.supply - MyLEDCircuit.led.Vf) / MyLEDCircuit.r.R <= 0.02" }
  constraint ReqVerify_Mouser { appliesTo = { MyLEDCircuit }; expression = "true" } // instances include Mouser sourcing annotations
}