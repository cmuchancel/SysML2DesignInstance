package LED_Flicker_Circuit {
  datatype Real;
  datatype Boolean;
  datatype String;

  class Circuit {
    property supplyVoltage: Real = 5.0;
    property timer: String = "NE555";
    property Ra: Real = 10000.0;
    property Rb: Real = 68000.0;
    property C: Real = 1e-6;
    property Rled: Real = 330.0;
    property ledVf: Real = 2.0;
    property ledIf: Real = 0.01;

    property frequency: Real { derived } = 1.44 / ((Ra + 2.0 * Rb) * C);

    constraint frequency_in_spec = frequency >= 9.5 and frequency <= 10.5;
    constraint led_current_check = ((supplyVoltage - ledVf) / Rled) >= 0.009 and ((supplyVoltage - ledVf) / Rled) <= 0.020;

    property vendor_notes: String = "NE555 (TI/ST/OnSemi), resistors/capacitors and LEDs from common vendors (Yageo/TDK/Murata, Kingbright/Everlight)";
  }
}