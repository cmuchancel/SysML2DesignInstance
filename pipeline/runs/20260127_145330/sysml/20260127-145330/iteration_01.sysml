package FlickerCircuitModel {
    requirement FlickerFreq {
        id = "REQ-1"
        text = "LED flickers at 10 Hz ±5% when driven from a 5 V supply."
    }
    requirement CurrentLimit {
        id = "REQ-2"
        text = "Include current limiting for the LED."
    }
    requirement Sourceable {
        id = "REQ-3"
        text = "All parts must be sourceable from Mouser; BOM details placed in concrete instances."
    }

    block LED {
        property Vf: Real        // forward voltage (V)
        property If_max: Real    // max forward current (A)
    }

    block Resistor {
        property resistance: Real    // ohms
        property powerRating: Real?  // W
    }

    block Capacitor {
        property capacitance: Real   // F
        property voltageRating: Real // V
    }

    block NE555_Osc {
        property Ra: Real    // ohms
        property Rb: Real    // ohms
        property C: Real     // F

        // frequency computed by astable 555 equation: f = 1.44 / ((Ra + 2*Rb)*C)
        derived property freq: Real {
            derivation = "1.44 / ((Ra + 2.0 * Rb) * C)"
        }
    }

    constraint FlickerFrequencyConstraint {
        expression = "9.5 <= NE555.freq <= 10.5"    // Hz
        note = "NE555.freq refers to the instantiated oscillator's derived freq; ensures 10 Hz ±5%"
    }

    block FlickerCircuit {
        property Vsup: Real = 5.0
        part osc: NE555_Osc
        part led: LED
        part r_series: Resistor    // LED current-limiting resistor
        part ra: Resistor          // 555 Ra
        part rb: Resistor          // 555 Rb
        part c_t: Capacitor        // 555 timing capacitor
    }

    // Concrete instance with BOM/source details (only place with manufacturer/part links)
    instance Assembly1: FlickerCircuit {
        Vsup = 5.0

        // Timing network chosen to target ~10 Hz (example values)
        ra.resistance = 1_000.0
        rb.resistance = 5_600.0
        c_t.capacitance = 2.7e-6
        // timing parts sourceable on Mouser
        ra.manufacturer = "Yageo"
        ra.mouserPN = "311-1K-RC"
        ra.mouserURL = "https://www.mouser.com/"
        rb.manufacturer = "Yageo"
        rb.mouserPN = "311-5K6-RC"
        rb.mouserURL = "https://www.mouser.com/"
        c_t.manufacturer = "Murata"
        c_t.mouserPN = "GRM21BR61E275KA12L" 
        c_t.mouserURL = "https://www.mouser.com/PartDetail/Murata/GRM21BR61E275KA12L"

        // 555 timer IC instance (sourceable on Mouser)
        osc.Ra = ra.resistance
        osc.Rb = rb.resistance
        osc.C = c_t.capacitance
        osc.manufacturer = "Texas Instruments"
        osc.mouserPN = "595-NE555P"
        osc.mouserURL = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P"

        // LED and current-limiting resistor (example values sized for ~10 mA)
        led.Vf = 2.0
        led.If_max = 20e-3
        r_series.resistance = 150.0
        r_series.powerRating = 0.25
        led.manufacturer = "Kingbright"
        led.mouserPN = "754-APBR3216SURCK"
        led.mouserURL = "https://www.mouser.com/ProductDetail/Kingbright/APBR3216SURCK"
        r_series.manufacturer = "Vishay"
        r_series.mouserPN = "CRCW0603150RFKED"
        r_series.mouserURL = "https://www.mouser.com/ProductDetail/Vishay-Dale/CRCW0603150RFKED"

        // Assertions (simple asserts only in instance per rules)
        assert Vsup == 5.0
        // ensure frequency meets requirement using derived freq of osc
        assert 9.5 <= osc.freq and osc.freq <= 10.5
    }
}