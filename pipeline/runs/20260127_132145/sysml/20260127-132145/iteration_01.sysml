package FlickerLED {
    /* Assumptions: numeric properties use Real (units conceptual: V, Hz, Ohm, W, mA). Vendor/partNumber as String. */
    block Circuit {
        part supply: PowerSupply
        part timer: NE555
        part r_limit: Resistor
        part led: LED
        constraint frequency_spec = (timer.frequency >= 9.5 and timer.frequency <= 10.5)
    }
    block PowerSupply { property voltage: Real = 5.0 }
    block NE555 { property frequency: Real = 10.0; property vendor: String = "Texas Instruments"; property partNumber: String = "NE555P" }
    block Resistor { property resistance: Real = 330.0; property power_W: Real = 0.25; property vendor: String = "Vishay"; property partNumber: String = "CRCW330R" }
    block LED { property Vf: Real = 2.0; property If_mA: Real = 10.0; property vendor: String = "Kingbright"; property partNumber: String = "WP7113ID" }
}