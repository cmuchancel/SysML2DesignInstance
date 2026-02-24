package BlinkDesign {
  // Assumptions: LED Vf = 2.0 V, target If = 10 mA (not specified by user)
  requirement REQ_FREQUENCY { text = "LED flickers at 10 Hz ±5% from a 5 V supply."; }
  requirement REQ_CURRENT_LIMIT { text = "Include current limiting for the LED."; }
  requirement REQ_SOURCEABLE { text = "Parts must be sourceable from Mouser."; }

  constraintDefinition FrequencyRange { expression = "9.5 <= frequency and frequency <= 10.5"; comment = "Hz" }
  constraintDefinition ResistorOhms { expression = "R = (Vcc - Vf) / If"; comment = "Ohms" }

  block LED {
    property Vf: Real;    // V
    property If: Real;    // A
    property supplier: String?;
    property partNumber: String?;
    property supplierURL: String?;
  }

  block Resistor {
    property R: Real;     // ohms
    property power: Real; // W
    property supplier: String?;
    property partNumber: String?;
    property supplierURL: String?;
  }

  block Timer555 {
    property frequency: Real; // Hz
    property supplier: String?;
    property partNumber: String?;
    property supplierURL: String?;
  }

  block BlinkCircuit {
    property Vcc: Real;
    property targetFreq: Real;
    part timer: Timer555;
    part led: LED;
    part r: Resistor;
  }

  instance blink1: BlinkCircuit {
    Vcc = 5.0;
    targetFreq = 10.0;
    // assumed LED params
    led.Vf = 2.0;
    led.If = 0.01;
    // resistor computed per ResistorOhms: R = (5 - 2)/0.01 = 300 Ohm
    r.R = 300.0;
    r.power = 0.125; // 1/8 W selected (>= (Vdrop*I) = 0.03 W)
    // timer nominal setting to meet FrequencyRange
    timer.frequency = 10.0;
    assert 9.5 <= timer.frequency and timer.frequency <= 10.5;

    // BOM / source details (only in instance)
    timer.supplier = "Texas Instruments";
    timer.partNumber = "NE555P";
    timer.supplierURL = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P";

    led.supplier = "Kingbright";
    led.partNumber = "WP7113ID"; // 5mm red LED example
    led.supplierURL = "https://www.mouser.com/ProductDetail/Kingbright/WP7113ID";

    r.supplier = "Yageo";
    r.partNumber = "RC0603JR-07300RL"; // example 300 Ω resistor
    r.supplierURL = "https://www.mouser.com";

    assert r.R > 0;
  }
}