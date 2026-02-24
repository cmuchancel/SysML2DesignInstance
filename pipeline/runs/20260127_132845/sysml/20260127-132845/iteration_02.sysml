package LEDFlicker {
  import standard::*;

  class Resistor {
    attribute resistance: Real[1];
    attribute manufacturers: String[*];
  }

  class Capacitor {
    attribute capacitance: Real[1];
    attribute manufacturers: String[*];
  }

  class TimerIC {
    attribute partNumber: String[1];
    attribute manufacturers: String[*];
  }

  class LED {
    attribute vf: Real[1];
    attribute manufacturers: String[*];
  }

  constant TimerIC_PN: String[1] = "NE555";
  constant TimerIC_MFRs: String[*] = {"Texas Instruments", "STMicroelectronics", "ON Semiconductor"};
  constant Resistor_MFRs: String[*] = {"Yageo", "Vishay"};
  constant Capacitor_MFRs: String[*] = {"Murata", "Kemet"};
  constant LED_MFRs: String[*] = {"Kingbright", "OSRAM", "Lite-On"};

  system LEDFlickerCircuit {
    attribute supplyVoltage: Real[1] = 5.0;
    attribute freqNominal: Real[1] = 10.0;
    attribute freqTolPct: Real[1] = 5.0;
    attribute freqMin: Real[1] = 9.5;
    attribute freqMax: Real[1] = 10.5;

    part U1: TimerIC;
    part RtimA: Resistor;
    part RtimB: Resistor;
    part Ctim: Capacitor;
    part LED1: LED;
    part Rlim: Resistor;

    attribute computedFreq: Real[1] = 1.44 / ((RtimA.resistance + 2.0 * RtimB.resistance) * Ctim.capacitance);
    attribute withinSpec: Boolean[1] = (computedFreq >= freqMin) and (computedFreq <= freqMax);
    attribute ledCurrentA: Real[1] = (supplyVoltage - LED1.vf) / Rlim.resistance;
  }
}