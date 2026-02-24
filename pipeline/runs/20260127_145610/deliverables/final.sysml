model LEDBlinkDesign
{
  // Assumption: standard astable 555 formula f = 1.44 / ((RA + 2*RB) * C); LED Vf ~2.0V for chosen red LED.
  requirement REQ_LED_BLINK
  {
    id = "REQ-1"
    text = "LED flickers at 10 Hz ±5% when powered from a 5 V supply; circuit includes current limiting resistor; parts are sourceable from Mouser."
  }

  // Constraints (separate from design elements)
  constraint FreqFormula
  {
    id = "C-FREQ"
    expression = "frequency = 1.44 / ((RA + 2 * RB) * C)"
  }
  constraint FreqRange
  {
    id = "C-FREQ-RANGE"
    expression = "frequency >= 9.5 and frequency <= 10.5"
  }
  constraint LedCurrent
  {
    id = "C-ILED"
    expression = "I_led = (Vcc - Vf) / R_led and I_led >= 0.009 and I_led <= 0.011"
  }

  // Reusable design elements
  block Resistor
  {
    property resistance: Real
  }

  block Capacitor
  {
    property capacitance: Real
  }

  block LED
  {
    property Vf: Real
    property I: Real
  }

  block Timer555_Astable
  {
    property RA: Real
    property RB: Real
    property C: Real
    property frequency: Real
  }

  block Vcc
  {
    property voltage: Real
  }

  // Concrete circuit assembly (types only; BOM links go in instance below)
  block LEDBlinkCircuit
  {
    part supply: Vcc
    part timer: Timer555_Astable
    part led: LED
    part R_led: Resistor
    part R_A: Resistor
    part R_B: Resistor
    part C_timing: Capacitor
  }

  // Concrete instance with numeric values and Mouser source links (BOM)
  instance Circuit_Inst: LEDBlinkCircuit
  {
    // supply
    supply.voltage = 5.0

    // timing network chosen to yield ~10 Hz using 555 astable: RA=10k, RB=68k, C=1uF
    timer.RA = 10000.0
    timer.RB = 68000.0
    timer.C = 1.0e-6
    timer.frequency = 1.44 / ((timer.RA + 2.0 * timer.RB) * timer.C)

    // LED and current-limiting resistor
    led.Vf = 2.0
    R_led.resistance = 330.0
    led.I = (supply.voltage - led.Vf) / R_led.resistance

    // mirror values on named parts
    R_A.resistance = timer.RA
    R_B.resistance = timer.RB
    C_timing.capacitance = timer.C

    // Assertions to satisfy requirements (simple asserts)
    assert timer.frequency >= 9.5 and timer.frequency <= 10.5
    assert led.I >= 0.009 and led.I <= 0.011

    // BOM / sourceability (Mouser search links provided for sourcing)
    // Timer (NE555-family)
    timer.bomPart = "https://www.mouser.com/c/ics-boards-timers/ics-timers-clocks/ics-timers/?q=NE555"
    // LED (standard 5mm red LED search)
    led.bomPart = "https://www.mouser.com/Passive-Components/LEDs/_/N-5g6l"
    // Current-limiting resistor 330 Ω
    R_led.bomPart = "https://www.mouser.com/Search/Refine?Keyword=330+ohm+resistor"
    // RA = 10k Ω
    R_A.bomPart = "https://www.mouser.com/Search/Refine?Keyword=10k+resistor"
    // RB = 68k Ω
    R_B.bomPart = "https://www.mouser.com/Search/Refine?Keyword=68k+resistor"
    // Timing capacitor 1 µF (electrolytic or ceramic depending on tolerance)
    C_timing.bomPart = "https://www.mouser.com/Search/Refine?Keyword=1uF+capacitor"
  }
}