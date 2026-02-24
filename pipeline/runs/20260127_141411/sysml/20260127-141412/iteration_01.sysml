package LEDFlicker {
  // Assumptions: use NE555 astable; LED Vf ≈ 2.0 V; target LED current 10 mA.

  requirement FlickerFreq {
    id: "REQ-001";
    text: "LED flickers at 10 Hz ±5% (9.5–10.5 Hz).";
    verification: "Measure frequency; accept if within 9.5–10.5 Hz.";
  }

  requirement Supply {
    id: "REQ-002";
    text: "Operates from a 5 V supply.";
  }

  requirement CurrentLimit {
    id: "REQ-003";
    text: "Includes current limiting so LED forward current ≤20 mA (design target 10 mA).";
  }

  requirement Sourceable {
    id: "REQ-004";
    text: "All parts sourceable from Mouser.";
  }

  constraint FrequencyFormula {
    expression: "f = 1.44 / ((R1 + 2 * R2) * C)"; // 555 astable formula
  }

  block LED {
    property Vf: Real; // V
    property If_target: Real; // A
  }

  block Resistor {
    property R: Real; // ohms
  }

  block Capacitor {
    property C: Real; // farads
  }

  block NE555 {
    property Vcc: Real; // V
  }

  block Flasher {
    part timer: NE555;
    part led: LED;
    part r_series: Resistor; // LED current limiter
    part r1: Resistor; // 555 R1
    part r2: Resistor; // 555 R2
    part c: Capacitor; // 555 timing cap
    property Vsup: Real; // V
    property f: Real = 1.44 / ((r1.R + 2.0 * r2.R) * c.C);
    constraint FreqConstraint { expression: "f >= 9.5 and f <= 10.5"; }
    constraint CurrentConstraint { expression: "r_series.R >= (Vsup - led.Vf) / led.If_target"; }
  }

  instance design: Flasher {
    // electrical values chosen to meet 10 Hz ±5% and ~10 mA LED current
    Vsup = 5.0;
    timer.Vcc = 5.0;
    led.Vf = 2.0;
    led.If_target = 0.01;
    r1.R = 10000.0;     // 10 kΩ
    r2.R = 68000.0;     // 68 kΩ
    c.C = 1.0e-6;       // 1 µF
    r_series.R = 330.0; // 330 Ω (standard value; limits current to ~9.1 mA)

    // BOM / source references (Mouser product links)
    note timer_bom = "Timer: 595-NE555P (TI) https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P";
    note led_bom = "LED: 604-APTD1608LVBC/D (Kingbright 0603 blue) https://www.mouser.com/ProductDetail/Kingbright/APTD1608LVBC-D";
    note r_series_bom = "LED resistor: 603-RC0603FR-07330RL (Yageo 330Ω 1%) https://www.mouser.com/ProductDetail/YAGEO/RC0603FR-07330RL";
    note r1_bom = "R1: 603-RC0603FR-0710KL (Yageo 10kΩ 1%) https://www.mouser.com/ProductDetail/YAGEO/RC0603FR-0710KL";
    note r2_bom = "R2: 603-RC0603FR-0768KL (Yageo 68kΩ 1%) https://www.mouser.com/ProductDetail/YAGEO/RC0603FR-0768KL";
    note c_bom = "Timing cap: 187-CL10A105KA8NNNC (Samsung 1µF 25V X5R 0603) https://www.mouser.com/ProductDetail/Samsung-Electro-Mechanics/CL10A105KA8NNNC";

    // simple asserts to link instance to requirements/constraints
    assert FlickerFreq;
    assert Supply;
    assert CurrentLimit;
    assert Sourceable;
    assert f >= 9.5 and f <= 10.5;
    assert r_series.R >= (Vsup - led.Vf) / led.If_target;
  }
}
