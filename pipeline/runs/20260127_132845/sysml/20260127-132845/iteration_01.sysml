package LEDFlicker {

  // Assumption: use NE555 in astable mode; target 10 Hz ±5% from 5 V supply.
  block Resistor {
    property resistance: Real[1];
    property manufacturers: String[*];
  }
  block Capacitor {
    property capacitance: Real[1];
    property manufacturers: String[*];
  }
  block TimerIC {
    property partNumber: String[1];
    property manufacturers: String[*];
  }
  block LED {
    property vf: Real[1]; // forward voltage (V)
    property manufacturers: String[*];
  }

  system LEDFlickerCircuit {
    property supplyVoltage: Real[1] = 5.0;
    property freqNominal: Real[1] = 10.0;
    property freqTolPct: Real[1] = 5.0;
    property freqMin: Real[1] = 9.5;
    property freqMax: Real[1] = 10.5;

    part U1: TimerIC { partNumber = "NE555"; manufacturers = {"Texas Instruments","STMicroelectronics","ON Semiconductor"} }
    part RtimA: Resistor { resistance = 220000.0; manufacturers = {"Yageo","Vishay"} } // R_A
    part RtimB: Resistor { resistance = 620000.0; manufacturers = {"Yageo","Vishay"} } // R_B
    part Ctim: Capacitor { capacitance = 100e-9; manufacturers = {"Murata","Kemet"} } // C
    part LED1: LED { vf = 2.0; manufacturers = {"Kingbright","OSRAM","Lite-On"} }
    part Rlim: Resistor { resistance = 330.0; manufacturers = {"Yageo","Vishay"} } // current-limiting resistor

    // Astable 555 nominal frequency with chosen values: f = 1.44 / ((R_A + 2*R_B)*C)
    property computedFreq: Real[1] = 1.44 / ((RtimA.resistance + 2.0 * RtimB.resistance) * Ctim.capacitance);

    // Verification that chosen components meet the requirement 10 Hz ±5%
    property withinSpec: Boolean[1] = (computedFreq >= freqMin) and (computedFreq <= freqMax);

    // LED current approx: (Vcc - Vf) / Rlim
    property ledCurrentA: Real[1] = (supplyVoltage - LED1.vf) / Rlim.resistance;
  }
}