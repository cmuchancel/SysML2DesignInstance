package BlinkCircuit {
    // Assumptions: LED Vf ≈ 2.0 V, target LED current 10 mA; 5 V supply; use NE555 in astable.
    block BlinkCircuit {
        property supplyVoltage: Real = 5.0;
        property frequency_nominal: Real = 10.0;
        property frequency_tolerance: Real = 0.05; // ±5%
        property frequency_min: Real = 9.5;
        property frequency_max: Real = 10.5;

        // 555 astable components (f = 1.44/((Ra + 2*Rb)*C))
        property Ra_ohm: Real = 22000.0;      // 22 kΩ
        property Rb_ohm: Real = 62000.0;      // 62 kΩ (standard)
        property C_f: Real = 1.0e-6;          // 1 µF
        property expected_frequency: Real = 9.86; // calculated ~9.86 Hz (within tolerance)

        // LED and current limiting
        property led_forward_voltage: Real = 2.0; // V (assumed)
        property led_current: Real = 0.010;       // A (10 mA)
        property R_led_ohm: Real = 330.0;         // (5 V - 2 V)/10 mA = 300 Ω -> choose 330 Ω standard

        // Sourceable parts / vendors (common, widely available)
        property timer_part: String = "NE555 (e.g., TI NE555P, ON Semiconductor LM555)";
        property led_part: String = "Generic LED 3–5 mm (e.g., Kingbright, Lumex)";
        property resistor_vendors: String = "Vishay, Yageo, Stackpole (standard values)";
        property capacitor_vendors: String = "Panasonic, Murata, Kemet (1 µF, electrolytic/tantalum/polymer as preferred)";
    }
}