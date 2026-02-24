package LED_Flicker_Circuit {
  // Assumptions: LED Vf=2.0V, target If≈10mA; NE555 in astable config. Standard vendor parts chosen.
  block Circuit {
    property supplyVoltage: Real = 5.0 /*V*/;
    property timer: String = "NE555 (e.g., TI NE555P)";
    property Ra: Real = 10_000.0 /*Ohm*/;
    property Rb: Real = 68_000.0 /*Ohm*/;
    property C: Real = 1e-6 /*F*/;
    property Rled: Real = 330.0 /*Ohm*/;
    property ledVf: Real = 2.0 /*V*/;
    property ledIf: Real = 0.010 /*A*/;
    // 555 astable frequency f = 1.44 / ((Ra + 2*Rb)*C)
    derived property frequency: Real = 1.44 / ((Ra + 2.0 * Rb) * C) /*Hz*/;
    constraint frequency_in_spec: Boolean = (frequency >= 9.5) and (frequency <= 10.5);
    constraint led_current_check: Boolean = ((supplyVoltage - ledVf) / Rled) >= (0.009) and ((supplyVoltage - ledVf) / Rled) <= (0.020);
    property vendor_notes: String = "Parts sourceable from common vendors: NE555 (TI/ST/OnSemi), resistors/caps (Yageo/TDK/Murata), generic 5mm LED (Kingbright, Everlight)";
  }
}