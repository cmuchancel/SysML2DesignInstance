package LED_Flashing {

  // Requirements (traceable statements)
  requirement def REQ_FREQ {
    id = "REQ-1";
    text = "LED shall flicker at 10 Hz ±5% (9.5–10.5 Hz) when powered from 5 V.";
  }

  requirement def REQ_SUPPLY {
    id = "REQ-2";
    text = "Supply voltage shall stay within 4.75–5.25 V.";
  }

  requirement def REQ_CURRENT {
    id = "REQ-3";
    text = "LED current shall stay between 9 mA and 20 mA during operation.";
  }

  requirement def REQ_MOUSER {
    id = "REQ-4";
    text = "All BOM line items shall be sourceable from Mouser.";
  }

  // Constraints (kept separate from design)
  constraint def SupplyRange_C {
    in v;
    (v >= 4.75) and (v <= 5.25)
  }

  constraint def FlickerBand_C {
    in f;
    (f >= 9.5) and (f <= 10.5)
  }

  constraint def LedCurrent_C {
    in i;
    (i >= 0.009) and (i <= 0.020)
  }

  // Parts
  part def LEDFlasher {
    attribute vcc = 5.0;
    attribute targetFreq = 10.0;
    attribute ledVf = 2.0;
    attribute ledCurrent = 0.015;
    attribute ra = 20000.0;
    attribute rb = 62000.0;
    attribute c = 1.0e-6;
    attribute r_series = 330.0;

    assert constraint supply_ok : SupplyRange_C {
      in v = vcc;
    }

    assert constraint freq_ok : FlickerBand_C {
      in f = targetFreq;
    }

    assert constraint led_current_ok : LedCurrent_C {
      in i = ((vcc - ledVf) / r_series);
    }
  }

  // Design instance for concept "NE555-astable"
  part design_NE555 : LEDFlasher {
    vcc = 5.0;
    targetFreq = 10.0;
    ra = 20000.0;
    rb = 62000.0;
    c = 1.0e-6;
    r_series = 330.0;

    // Solution-space sourcing kept at instance level
    attribute timer_pn = "595-NE555P";
    attribute timer_url = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P?qs=VwcoTNY2j2N6Qpj2rRCfPw%3D%3D";
    attribute led_pn = "604-APTD1608LVBC/D";
    attribute led_url = "https://www.mouser.com/ProductDetail/Kingbright/APTD1608LVBC-D?qs=Q0R7m%252BlHqK2%252Bi6l1O4ZAbQ%3D%3D";
    attribute resistor_pn = "603-RC0603FR-07330RL";
    attribute resistor_url = "https://www.mouser.com/ProductDetail/YAGEO/RC0603FR-07330RL?qs=4%252BhYCGU3ho4OlbdPzSaqQw%3D%3D";

  }
}
