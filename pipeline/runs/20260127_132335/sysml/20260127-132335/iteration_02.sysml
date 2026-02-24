// Assumption: LED Vf ≈ 2.0 V, target LED current ≈ 10 mA; use NE555-based astable; parts are common/vendor-available.
block BlinkCircuit {
    property supplyVoltage = 5.0;
    property frequency_nominal = 10.0;
    property frequency_tolerance = 0.05; // ±5%
    property frequency_min = 9.5;
    property frequency_max = 10.5;

    // 555 astable example (f ≈ 1.44/((Ra + 2*Rb)*C))
    property Ra_ohm = 22000;   // 22 kΩ
    property Rb_ohm = 62000;   // 62 kΩ
    property C_f = 1e-6;       // 1 µF
    property expected_frequency = 9.86; // calculated for chosen values

    // LED current limiting
    property led_forward_voltage = 2.0; // V (assumed)
    property led_current = 0.010;       // A (10 mA)
    property R_led_ohm = 330;           // chosen standard (~(5-2)/0.01 = 300 Ω -> 330 Ω)

    // Sourceable parts/vendors
    property timer_part = "NE555 (e.g., TI NE555P, ON Semiconductor LM555)";
    property led_part = "Generic LED 3-5 mm (e.g., Kingbright, Lumex)";
    property resistor_vendors = "Vishay, Yageo, Stackpole";
    property capacitor_vendors = "Panasonic, Murata, Kemet";
}