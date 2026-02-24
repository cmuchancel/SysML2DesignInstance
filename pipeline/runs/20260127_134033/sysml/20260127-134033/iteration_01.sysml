package LEDFlickerDesign {
    /* Assumptions: LED forward voltage Vf = 2.0 V, target LED current If = 10 mA.
       Timing implemented with an NE555 astable configured to ~10 Hz. Mouser
       part numbers are example/sourceable references; verify availability on mouser.com. */
    block Circuit {
        property supplyVoltage: Real = 5.0; // V
        property frequencyHz: Real = 10.0; // Hz
        constraint FrequencyTolerance { bodyExpression = "frequencyHz >= 9.5 and frequencyHz <= 10.5"; }

        property ledVf: Real = 2.0; // V (assumed)
        property ledIf: Real = 0.01; // A (assumed target current)
        property seriesResistorOhm: Real = 330.0; // chosen standard value to limit current ~9.1 mA

        property timerMouserPN: String = "595-NE555P"; // example NE555 on Mouser
        property resistorMouserPN: String = "710-330-R-ND"; // example 330 Ω resistor on Mouser
        property ledMouserPN: String = "604-APTD1608"; // example LED on Mouser

        constraint CurrentLimit { bodyExpression = "seriesResistorOhm >= (supplyVoltage - ledVf)/ledIf - 1e-6"; }
    }
}