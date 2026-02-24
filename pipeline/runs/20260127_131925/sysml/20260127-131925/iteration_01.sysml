package FlickerCircuit {
  // Assumption: use NE555 astable; f = 1.44/((Ra+2*Rb)*C); chosen values yield ~10 Hz; parts are generic widely available (NE555, 1 µF MLCC, resistors, 5mm LED).
  requirement FREQ {
    id = "REQ-001";
    text = "LED flickers at 10 Hz ±5% (9.5–10.5 Hz) when powered from 5 V";
    verification = "measure LED blink frequency at 5 V supply; adjust Rb trim if required";
  }

  component LED_Flicker {
    property supplyVoltage: Real = 5.0;

    part Timer: Component = NE555 {
      property vendor: String = "TI/OnSemi/Signetics (generic NE555) - available from DigiKey/Mouser";
      property partNumber: String = "NE555 / LM555";
    }

    part Ctiming: Component = Capacitor {
      property value: Real = 1e-6; // 1 µF
      property unit: String = "F";
      property tolerance: Real = 0.2; // assume 20% electrolytic or use 10%/5% MLCC as available
      property vendor: String = "Murata/Vishay/TDK - common";
    }

    part Ra: Component = Resistor { property value: Real = 20000.0; property unit: String = "ohm"; }   // 20 kΩ
    part Rb: Component = Resistor { property value: Real = 62000.0; property unit: String = "ohm"; }   // 62 kΩ (can be implemented as 50k pot + fixed resistor for tuning)
    part Rled: Component = Resistor { property value: Real = 330.0; property unit: String = "ohm"; }   // LED current limit ≈ 9–10 mA for Vf≈2V

    part LED: Component = LED {
      property Vf: Real = 2.0; // typical forward voltage (red); adjust for color
      property If_nominal: Real = 0.01; // 10 mA target
      property vendor: String = "Kingbright/OSRAM/Generic - available from DigiKey/Mouser";
    }

    constraint FrequencyCalc {
      text = "f = 1.44 / ((Ra + 2*Rb) * Ctiming)";
      property f_nominal: Real = 1.44 / ((Ra.value + 2.0 * Rb.value) * Ctiming.value);
      // With chosen values f_nominal ≈ 10 Hz
    }

    satisfy FREQ;
  }
}