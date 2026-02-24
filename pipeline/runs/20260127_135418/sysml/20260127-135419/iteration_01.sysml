package FlickerCircuit
{
    /* Assumption: implement LED flicker with a 555 timer in astable mode.
       Using RA=10k, RB=10k, C=4.7uF gives f ≈ 1.44/((10k+2*10k)*4.7e-6) ≈ 10.2 Hz (within ±5%).
       Current-limiting resistor ~330 Ω yields ≈10 mA for a 2.0 V LED from 5 V.
       Mouser search links provided so parts are sourceable from Mouser. */
    block BlinkCircuit
    {
        property supply_V: Real = 5.0;
        property target_freq_Hz: Real = 10.0;
        property freq_tolerance_pct: Real = 5.0;

        property timer_type: String = "NE555 astable";
        property ra_Ohm: Integer = 10000;
        property rb_Ohm: Integer = 10000;
        property c_uF: Real = 4.7;

        property led_Vf_V: Real = 2.0;
        property led_If_A: Real = 0.010;
        property r_limit_Ohm: Integer = 330;

        property mouser_timer_search: String = "https://www.mouser.com/Search/Refine?Keyword=NE555";
        property mouser_led_search: String = "https://www.mouser.com/Search/Refine?Keyword=5mm+red+LED";
        property mouser_resistor_search: String = "https://www.mouser.com/Search/Refine?Keyword=through-hole+resistor";
        property mouser_capacitor_search: String = "https://www.mouser.com/Search/Refine?Keyword=4.7uF+capacitor";
    }
}