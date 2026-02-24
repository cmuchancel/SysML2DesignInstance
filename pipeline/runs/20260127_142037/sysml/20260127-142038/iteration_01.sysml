package BlinkCircuit {
  // Requirements
  requirement FlickerFreq {
    id = "REQ-001"
    text = "LED flickers at 10 Hz ±5% from a 5 V supply."
  }
  requirement CurrentLimit {
    id = "REQ-002"
    text = "Circuit includes current limiting to protect the LED."
  }
  requirement MouserSource {
    id = "REQ-003"
    text = "All parts are sourceable from Mouser."
  }

  // Constraints (kept separate from design elements)
  constraint FrequencyConstraint {
    body = "timer.frequency >= 9.5 and timer.frequency <= 10.5"
  }
  constraint SupplyConstraint {
    body = "circuit.Vsup == 5.0"
  }

  // Reusable design elements (no concrete BOM links here)
  block TimerOscillator {
    property frequency: Real[1];
    property ra: Real[0..1];
    property rb: Real[0..1];
    property c: Real[0..1];
    property source: String[0..1]; // optional metadata field for instances
  }

  block LED {
    property Vf: Real[1];
    property Imax: Real[1];
    property source: String[0..1];
  }

  block Resistor {
    property R: Real[1];
    property power: Real[0..1];
    property source: String[0..1];
  }

  block LEDCircuit {
    part timer: TimerOscillator[1];
    part led: LED[1];
    part r: Resistor[1];
    property Vsup: Real[1];
  }

  // Concrete instance with BOM/source details (only here per STRUCTURE RULES)
  instance circuit: LEDCircuit {
    Vsup = 5.0;
    // timer set to 10 Hz per requirement; resistor chosen to limit LED current ≤ Imax
    timer.frequency = 10.0;
    // Example 555 timing components for astable ~10 Hz (typical RA/RB/C values)
    timer.ra = 10000.0;    // ohms
    timer.rb = 100000.0;   // ohms
    timer.c  = 1e-7;       // farads (100 nF)
    timer.source = "Mouser PN 595-NE555P (TI NE555P) https://www.mouser.com"; // assumed source

    // LED typical properties
    led.Vf = 2.0;          // V (red LED typical)
    led.Imax = 0.02;       // A (20 mA)
    led.source = "Mouser PN 700-LED-0603-R (example red LED) https://www.mouser.com";

    // Resistor chosen to satisfy current limiting: R >= (Vsup - Vf)/Imax
    r.R =  (Vsup - led.Vf) / led.Imax; // ohms (calc yields 150 Ω for Vf=2V,I=20mA)
    r.power = 0.25;        // W
    r.source = "Mouser PN 600-RC0603FR-07150RL (150 Ω 1% 1/4W) https://www.mouser.com";

    // Assertions to link instance to constraints/requirements
    assert FrequencyConstraint;
    assert SupplyConstraint;
    // Ensure current limiting present (resistor not zero)
    assert r.R >= (Vsup - led.Vf) / led.Imax;
  }

  // Note: component part numbers/URLs are best-effort examples intended to be sourceable from Mouser.
  // If exact PN differs, replace strings in instance 'source' properties with correct Mouser links.
}