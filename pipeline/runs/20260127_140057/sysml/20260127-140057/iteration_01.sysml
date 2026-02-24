package FlickerCircuit {
  public import ScalarValues::*;

  // Basic value types
  value type Voltage = Real { unit = "V"; }
  value type Frequency = Real { unit = "Hz"; }
  value type Current = Real { unit = "A"; }

  // Components with Mouser sourcing info
  part def Supply {
    attribute V: Voltage = 5.0;
  }

  part def LED {
    attribute Vf: Voltage = 2.0;
    attribute If_target: Current = 0.01;
    attribute mouser_pn: String = "604-APTD1608LVBC/D";
    attribute url: String = "https://www.mouser.com/ProductDetail/Kingbright/APTD1608LVBC-D?qs=Q0R7m%252BlHqK2%252Bi6l1O4ZAbQ%3D%3D";
  }

  part def Resistor {
    attribute R: Real;
    attribute mouser_pn: String;
    attribute url: String;
  }

  part def Timer555 {
    attribute Ra: Real;
    attribute Rb: Real;
    attribute C: Real;
    attribute frequency: Frequency;
    attribute mouser_pn: String = "595-NE555P";
    attribute url: String = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P?qs=VwcoTNY2j2N6Qpj2rRCfPw%3D%3D";
  }

  // System definition
  part def FlickerSystem {
    attribute targetFreq: Frequency = 10.0;
    attribute freqMin: Frequency = 9.5;
    attribute freqMax: Frequency = 10.5;
    attribute ledCurrentMin: Current = 0.009;
    attribute ledCurrentMax: Current = 0.011;

    part supply: Supply[1];
    part led: LED[1];
    part limitR: Resistor[1];
    part timer: Timer555[1];

    // Derived frequency using NE555 astable formula
    constraint def FreqCalc {
      in f: Frequency;
      in Ra: Real;
      in Rb: Real;
      in C: Real;
      f = 1.44 / ((Ra + 2.0*Rb) * C);
    }

    assert constraint freq_ok: FreqCalc {
      in f = timer.frequency;
      in Ra = timer.Ra;
      in Rb = timer.Rb;
      in C = timer.C;
    }

    assert constraint freq_band {
      timer.frequency >= freqMin and timer.frequency <= freqMax;
    }

    assert constraint led_current_ok {
      ((supply.V - led.Vf) / limitR.R) >= ledCurrentMin and ((supply.V - led.Vf) / limitR.R) <= ledCurrentMax;
    }
  }

  // Concrete instance with Mouser parts
  part designInstance : FlickerSystem {
    supply.V := 5.0;
    timer.Ra := 20000.0;
    timer.Rb := 62000.0;
    timer.C := 1.0e-6;
    timer.frequency := 10.0;

    part limitR {
      R := 330.0;
      mouser_pn := "603-RC0603FR-07330RL";
      url := "https://www.mouser.com/ProductDetail/YAGEO/RC0603FR-07330RL?qs=4%252BhYCGU3ho4OlbdPzSaqQw%3D%3D";
    }
  }
} end FlickerCircuit;
