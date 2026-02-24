package LEDFlickerDesign {
    // Assumptions: LED Vf ≈ 2.0 V, target LED current ≈ 10 mA; NE555-based astable used for ~10 Hz.
    import { Real, String } from sysml::types;

    block Circuit {
        property supplyVoltage: Real = 5.0;
        property frequencyHz: Real = 10.0;
        property frequencyHzMin: Real = 9.5;
        property frequencyHzMax: Real = 10.5;

        property ledVf: Real = 2.0;
        property ledIf: Real = 0.01;
        property seriesResistorOhm: Real = 330.0;

        property timerMouserPN: String = "595-NE555P";
        property resistorMouserPN: String = "710-330-R-ND";
        property ledMouserPN: String = "604-APTD1608";
    }
}