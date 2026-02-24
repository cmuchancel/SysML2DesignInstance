package LEDFlickerModel {
  datatype String;
  datatype Real;
  datatype Boolean;

  block Supply {
    attribute mouser: String = "https://www.mouser.com/";
  }

  block LED {
    attribute mouser: String = "https://www.mouser.com/c/leds/indicator-leds/";
    attribute Vf_V: Real = 2.0;
  }

  block Resistor {
    attribute mouser: String = "https://www.mouser.com/passive-components/resistors/";
    attribute resistance_Ohms: Real = 220.0;
  }

  block Oscillator {
    attribute mouser: String = "https://www.mouser.com/electromechanical-switches/timers-timing/";
    attribute nominalFrequency_Hz: Real = 10.0;
  }

  block LEDFlickerSystem {
    attribute supplyVoltage_V: Real = 5.0;
    attribute supplyVoltage_min_V: Real = 4.75;
    attribute supplyVoltage_max_V: Real = 5.25;

    attribute targetFrequency_Hz: Real = 10.0;
    attribute achievedFrequency_Hz: Real = 10.0;
    attribute achievedFrequency_min_Hz: Real = 9.5;
    attribute achievedFrequency_max_Hz: Real = 10.5;

    attribute ledPresent: Boolean = true;
    attribute currentLimiterPresent: Boolean = true;
    attribute oscillatorPresent: Boolean = true;

    part supply: Supply[1];
    part led: LED[1];
    part currentLimiter: Resistor[1];
    part oscillator: Oscillator[1];
  }
} end LEDFlickerModel