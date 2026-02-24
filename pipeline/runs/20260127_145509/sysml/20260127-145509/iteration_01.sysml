package FlickerCircuit {
  // Requirements (repeated as requested)
  requirement Req1 {
    id = "REQ-1"
    statement = "Design a circuit whose LED flickers at 10 Hz ±5% from a 5 V supply; include current limiting and make it sourceable from Mouser."
  }
  requirement Req2 {
    id = "REQ-2"
    statement = "Design a circuit whose LED flickers at 10 Hz ±5% from a 5 V supply; include current limiting and make it sourceable from Mouser."
  }

  // Reusable design elements
  block LED {
    property Vf: Real  // forward voltage (V)
    property If: Real  // desired LED current (A)
  }
  block Resistor {
    property R: Real // ohms
  }
  block AstableOscillator {
    property f: Real // frequency (Hz)
    // implementation detail left to instances (e.g., NE555 or MCU)
  }
  block Flasher {
    part led: LED
    part r: Resistor
    part osc: AstableOscillator
    property Vsup: Real
  }

  // Constraints (separate from design elements)
  constraint FrequencySpec {
    expression = "flasher.osc.f >= 9.5 and flasher.osc.f <= 10.5"
  }
  constraint SupplySpec {
    expression = "flasher.Vsup = 5.0"
  }
  constraint CurrentLimitOhms {
    // R = (Vsup - Vf) / If  (simple series resistor for current limiting)
    expression = "flasher.r.R = (flasher.Vsup - flasher.led.Vf) / flasher.led.If"
  }

  // Concrete instance satisfying requirements; BOM/source details only in instances
  instance flasher: Flasher {
    Vsup = 5.0
    // nominal assumptions (see comment below)
    led.Vf = 2.0
    led.If = 0.02
    // computed resistor for ~20 mA: (5.0 - 2.0)/0.02 = 150 ohm
    r.R = 150.0
    osc.f = 10.0
  }

  // Sourceable Mouser items (concrete part instances). These are instance-level BOM entries.
  instance mouser_LED: LED {
    Vf = 2.0
    If = 0.02
    vendor = "Kingbright (example)"
    mouserPartNumber = "WP710A10SRC" // example part; verify availability
    mouserURL = "https://www.mouser.com/Search/Refine?Keyword=WP710A10SRC"
  }
  instance mouser_timer: AstableOscillator {
    f = 10.0
    vendor = "Texas Instruments (example)"
    mouserPartNumber = "NE555P" // common DIP timer IC usable as astable oscillator
    mouserURL = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P"
  }
  instance mouser_resistor: Resistor {
    R = 150.0
    vendor = "Vishay (example)"
    mouserPartNumber = "CRCW0603150R0FKED" // example 150 Ω resistor
    mouserURL = "https://www.mouser.com/Search/Refine?Keyword=150%20ohm%20resistor"
  }

  // Simple assertions tying instance to constraints (keeps constraints separate)
  assert FrequencySpec
  assert SupplySpec
  assert CurrentLimitOhms

  // Note: Assumed LED forward voltage 2.0 V and desired LED current 20 mA for sizing the resistor.
  // Part numbers/URLs are example selections intended to demonstrate Mouser sourceability; verify exact availability and package choices.
}