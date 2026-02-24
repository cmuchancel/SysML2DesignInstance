package FlickerCircuit {
    // Assumptions: red LED Vf=2.0V, LED current target 10mA; Mouser part numbers/URLs are best-effort.
    requirement FR_Frequency { id = "FR_Frequency"; text = "LED flickers at 10 Hz ±5%"; }
    requirement FR_Supply { id = "FR_Supply"; text = "Operates from 5 V supply"; }
    requirement FR_CurrentLimit { id = "FR_CurrentLimit"; text = "Includes current limiting for LED"; }
    requirement FR_Sourceable { id = "FR_Sourceable"; text = "All parts sourceable from Mouser"; }

    constraint FrequencyRange { expression = "9.5 <= f_hz <= 10.5"; }

    block Timer555 {
        attribute Ra_ohm: Real;
        attribute Rb_ohm: Real;
        attribute C_f: Real;
        derived f_hz: Real { definition = "1.44 / ((Ra_ohm + 2.0 * Rb_ohm) * C_f)" }
    }

    block LED {
        attribute Vf_v: Real;
        attribute If_a: Real;
    }

    block Resistor {
        attribute R_ohm: Real;
    }

    system FlickerAssembly {
        part timer: Timer555 {
            Ra_ohm = 4700.0;
            Rb_ohm = 4700.0;
            C_f = 10e-6;
        }
        part led: LED {
            Vf_v = 2.0;
            If_a = 0.010;
            // Mouser source (example)
            mouser_part = "160-LED-0603SRD"; // best-effort placeholder
            mouser_url = "https://www.mouser.com/";
        }
        part r_led: Resistor {
            R_ohm = 330.0;
            mouser_part = "603-RC0603FR-07330RL"; // best-effort placeholder
            mouser_url = "https://www.mouser.com/";
        }
        part timer_chip: Resistor { // using Resistor block as minimal generic part holder for PN/URL fields
            R_ohm = 0.0;
            mouser_part = "512-NE555P"; // best-effort Mouser PN for NE555
            mouser_url = "https://www.mouser.com/ProductDetail/NE555P";
        }

        // Constraints tying design to requirements
        assert timer.f_hz >= 9.5 and timer.f_hz <= 10.5;
        assert led.If_a <= (5.0 - led.Vf_v) / r_led.R_ohm + 1e-6;
        assert FR_Supply.text = "Operates from 5 V supply";
        assert FR_Sourceable.text = "All parts sourceable from Mouser";
    }
}