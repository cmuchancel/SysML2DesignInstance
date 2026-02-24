package LEDFlickerModel {
  // Assumption: astable timer (e.g., 555/CMOS) drives LED through a series resistor sized for <=15mA at max supply 5.25V.
  block Supply {
    attribute mouser: String[1] = "https://www.mouser.com/";
  }
  block LED {
    attribute mouser: String[1] = "https://www.mouser.com/c/leds/indicator-leds/";
    attribute Vf_V: Real[1] = 2.0;
  }
  block Resistor {
    attribute mouser: String[1] = "https://www.mouser.com/passive-components/resistors/";
    attribute resistance_Ohms: Real[1] = 220.0; // chosen standard value: (5.25-2.0)/220 <= 15mA
  }
  block Oscillator {
    attribute mouser: String[1] = "https://www.mouser.com/electromechanical-switches/timers-timing/";
    attribute nominalFrequency_Hz: Real[1] = 10.0;
  }

  block LEDFlickerSystem {
    attribute supplyVoltage_V: Real[1] = 5.0;
    attribute supplyVoltage_min_V: Real[1] = 4.75;
    attribute supplyVoltage_max_V: Real[1] = 5.25;

    attribute targetFrequency_Hz: Real[1] = 10.0;
    attribute achievedFrequency_Hz: Real[1] = 10.0;
    attribute achievedFrequency_min_Hz: Real[1] = 9.5;
    attribute achievedFrequency_max_Hz: Real[1] = 10.5;

    attribute ledPresent: Boolean[1] = true;
    attribute currentLimiterPresent: Boolean[1] = true;
    attribute oscillatorPresent: Boolean[1] = true;

    part supply: Supply[1];
    part led: LED[1];
    part currentLimiter: Resistor[1];
    part oscillator: Oscillator[1];
  }
}