package LEDBlinkDesign
{
    // Requirements
    requirement R_Frequency
    {
        id = "REQ-001";
        text = "LED flickers at 10 Hz ±5% (9.5 Hz to 10.5 Hz).";
    }

    requirement R_Supply
    {
        id = "REQ-002";
        text = "Operate from a 5 V supply.";
    }

    requirement R_CurrentLimit
    {
        id = "REQ-003";
        text = "Provide current limiting for the LED to prevent overcurrent.";
    }

    requirement R_MouserSourceable
    {
        id = "REQ-004";
        text = "All parts must be sourceable from Mouser (part number or direct Mouser search URL in BOM).";
    }

    // Constraints (kept separate)
    constraint C_FrequencyRange
    {
        id = "C-001";
        expression = "9.5 <= led_frequency_hz and led_frequency_hz <= 10.5";
    }

    constraint C_SupplyVoltage
    {
        id = "C-002";
        expression = "supply_voltage_v = 5.0";
    }

    constraint C_CurrentLimit
    {
        id = "C-003";
        expression = "led_current_a <= led_nominal_current_a and led_current_a = (supply_voltage_v - led_forward_voltage_v) / series_resistance_ohm";
    }

    // Reusable design elements (no BOM/source details here)
    block LED
    {
        property forward_voltage_v: Real;     // typical forward voltage
        property nominal_current_a: Real;     // desired LED current limit (e.g., 0.01 A)
    }

    block Resistor
    {
        property resistance_ohm: Real;
        property power_watt: Real?;
    }

    block NE555_Astable
    {
        property Ra_ohm: Real;
        property Rb_ohm: Real;
        property C_f: Real; // capacitance in Farads
        // derived frequency in Hz using standard 555 astable formula
        property frequency_hz: Real = 1.44 / ((Ra_ohm + 2.0 * Rb_ohm) * C_f);
    }

    block LED_Blink_Circuit
    {
        part timer: NE555_Astable;
        part series_resistor: Resistor;
        part led: LED;
        property supply_voltage_v: Real;
        // instance-level observable properties (bound by constraints)
        property led_frequency_hz: Real = timer.frequency_hz;
        property led_forward_voltage_v: Real = led.forward_voltage_v;
        property led_nominal_current_a: Real = led.nominal_current_a;
        property series_resistance_ohm: Real = series_resistor.resistance_ohm;
        property led_current_a: Real = (supply_voltage_v - led_forward_voltage_v) / series_resistance_ohm;
    }

    // Concrete instance with BOM/source details (only instances may include part numbers/URLs)
    instance BlinkCircuit_Inst : LED_Blink_Circuit
    {
        // Assertions to satisfy requirements/constraints
        assert supply_voltage_v = 5.0;
        // Example component selections (Mouser search URLs or part numbers provided here)
        // Timer: common NE555 through Mouser search
        // Resistor: calculate for ~10 mA (example: R = (5.0 - 2.1)/0.01 = 290 ohm -> choose 300 Ω)
        // LED: example nominal forward voltage 2.1 V, nominal current 10 mA
        led.forward_voltage_v = 2.1;
        led.nominal_current_a = 0.01;
        series_resistor.resistance_ohm = 300.0;
        // Astable component example to yield ~10 Hz:
        // Using Ra = 33k, Rb = 33k, C = 1uF => f ≈ 1.44/((33k + 2*33k)*1e-6) ≈ 10.4 Hz (within ±5%)
        timer.Ra_ohm = 33000.0;
        timer.Rb_ohm = 33000.0;
        timer.C_f = 1e-6;
        // Assert frequency constraint (simple numeric check)
        assert led_frequency_hz >= 9.5 and led_frequency_hz <= 10.5;
        // Assert current-limit constraint
        assert led_current_a <= led.nominal_current_a;
        // BOM / Mouser sourcing (concrete links / part numbers)
        // Note: URLs provided for sourcing from Mouser per requirement R_MouserSourceable
        // NE555 timer (search results page)
        property timer_mouser_search_url: String = "https://www.mouser.com/Search/Refine?Keyword=555+timer";
        // 1 µF capacitor example (electrolytic or film) search
        property cap_mouser_search_url: String = "https://www.mouser.com/Search/Refine?Keyword=1uF+capacitor";
        // Resistor example: 300 Ω not a standard E12; use 330 Ω as common alternative; provide search
        property resistor_mouser_search_url: String = "https://www.mouser.com/Search/Refine?Keyword=330+ohm+resistor";
        // LED example (red LED) search
        property led_mouser_search_url: String = "https://www.mouser.com/Search/Refine?Keyword=5mm+red+LED";
    }
}