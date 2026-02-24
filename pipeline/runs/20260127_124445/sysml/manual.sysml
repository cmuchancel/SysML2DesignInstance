package LEDFlicker {
  public import ScalarValues::*;

  // Constraints use plain Real values for compatibility with syside parser.
  constraint def SupplyRange_C {
    in v: Real;
    (v >= 4.75) and (v <= 5.25)
  }

  constraint def FlickerBand_C {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }

  constraint def LedCurrent_C {
    in i: Real;
    i <= 0.015
  }

  // Parts
  part def Supply {
    attribute url: String = "https://www.mouser.com/";
  }

  part def LED {
    attribute url: String = "https://www.mouser.com/c/leds/indicator-leds/";
    attribute vf: Real = 2.0; // forward voltage in volts
  }

  part def Resistor {
    attribute url: String = "https://www.mouser.com/c/passive-components/resistors/";
    attribute resistance: Real; // ohms
  }

  part def Oscillator {
    attribute url: String = "https://www.mouser.com/c/electromechanical/signal-relays/oscillators/";
    attribute nominalFrequency: Real = 10.0; // hertz
  }

  // System
  part def LEDFlickerSystem {
    attribute supplyVoltage: Real = 5.0;       // volts
    attribute targetFrequency: Real = 10.0;    // hertz
    attribute achievedFrequency: Real = 10.0;  // hertz
    attribute ledPresent: Boolean = true;
    attribute currentLimiterPresent: Boolean = true;
    attribute oscillatorPresent: Boolean = true;
    attribute ledCurrent: Real = 0.01;         // amps

    part supply: Supply[1];
    part led: LED[1];
    part limiter: Resistor[1];
    part oscillator: Oscillator[1];

    assert constraint supply_ok: SupplyRange_C {
      in v = supplyVoltage;
    }

    assert constraint freq_ok: FlickerBand_C {
      in f = achievedFrequency;
    }

    assert constraint current_ok: LedCurrent_C {
      in i = ledCurrent;
    }
  }

  // Example instance
  part systemExample : LEDFlickerSystem {
    supplyVoltage := 5.0;
    achievedFrequency := 10.0;
    ledCurrent := 0.01;
    part limiter {
      resistance := 330.0;
    }
  }
} end LEDFlicker;
