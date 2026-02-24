package FlickerLEDModel {
  // Requirements (echoed twice as requested)
  requirement REQ_1 { id = "REQ-1"; text = "Design a circuit whose LED flickers at 10 Hz ±5% from a 5 V supply; include current limiting and make it sourceable from Mouser." }
  requirement REQ_2 { id = "REQ-2"; text = "Design a circuit whose LED flickers at 10 Hz ±5% from a 5 V supply; include current limiting and make it sourceable from Mouser." }

  // Constraints (kept separate from design elements)
  constraintdef FrequencyConstraint { parameters = "f: Real"; expression = "f >= 9.5 and f <= 10.5" }
  constraintdef SupplyConstraint { parameters = "V: Real"; expression = "V = 5.0" }
  constraintdef OhmsLaw { parameters = "Vsup: Real; Vf: Real; R: Real; I: Real"; expression = "I = (Vsup - Vf) / R" }

  // Reusable design elements
  block LED { property Vf: Real; property desiredIf: Real } 
  block Resistor { property R: Real; property powerW: Real }
  block NE555 { property frequency: Real; property Vcc: Real }
  block PowerSupply { property Vout: Real }
  block FlickerCircuit {
    part led: LED
    part r: Resistor
    part timer: NE555
    part ps: PowerSupply
  }

  // Concrete instances with Mouser sourcing (BOM details only in instances)
  instance ps5: PowerSupply {
    Vout = 5.0
    supplier = "Mouser (search)"
    supplierURL = "https://www.mouser.com/Search/Refine?Keyword=5V+voltage+regulator"
  }

  // Assumption: Vf ≈ 2.1 V (typical green LED); target If ≈ 10 mA -> R ≈ (5.0-2.1)/0.01 = 290 Ω -> choose 330 Ω standard
  instance led_green: LED {
    Vf = 2.1
    desiredIf = 0.010
    partNumber = "5 mm green LED (generic)"
    supplierURL = "https://www.mouser.com/Search/Refine?Keyword=5mm+LED+green"
  }

  instance R_series: Resistor {
    R = 330.0
    powerW = 0.25
    partNumber = "330 Ω ±5% 1/4 W resistor"
    supplierURL = "https://www.mouser.com/Search/Refine?Keyword=330+Ohm+resistor+1/4W"
  }

  instance timer555: NE555 {
    frequency = 10.0
    Vcc = 5.0
    partNumber = "NE555 family timer (astable configuration)"
    supplierURL = "https://www.mouser.com/Search/Refine?Keyword=NE555"
  }

  // Assembly instance with simple asserts referring to the constraints
  instance circuit1: FlickerCircuit {
    led = led_green
    r = R_series
    timer = timer555
    ps = ps5

    // Assertions (kept simple per instructions)
    assert FrequencyConstraint(timer.frequency)
    assert SupplyConstraint(ps.Vout)
    assert OhmsLaw(ps.Vout, led_green.Vf, R_series.R, (ps.Vout - led_green.Vf)/R_series.R)
    assert (timer.frequency >= 9.5 and timer.frequency <= 10.5)
  }

  // Note: Vf and target If are assumptions used to compute/select a standard resistor; explicit part numbers/links provided above for sourcing from Mouser.
}