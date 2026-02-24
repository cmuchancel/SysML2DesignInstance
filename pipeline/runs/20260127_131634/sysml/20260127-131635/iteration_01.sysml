package LedFlicker {
  model Circuit {
    // Assumption: LED Vf ≈ 2.0 V, target current 10 mA → R = (5-2)/0.01 = 300 Ω.
    block Supply {
      property voltage: Real = 5.0
    }
    block LED {
      property Vf: Real = 2.0
      property If_target: Real = 0.01
    }
    block Resistor {
      property resistanceOhm: Real = 300.0
    }
    block Oscillator {
      property frequencyHz: Real = 10.0
      invariant frequencyHz >= 9.5 and frequencyHz <= 10.5
    }
    part supply: Supply
    part led: LED
    part r: Resistor
    part osc: Oscillator

    // Vendor-sourceable reference parts (common vendors / Digi-Key links)
    block VendorPart {
      property vendor: String
      property partNumber: String
      property url: String
    }
    part led_part: VendorPart { vendor = "Kingbright"; partNumber = "WP710A10ID"; url = "https://www.digikey.com" }
    part resistor_part: VendorPart { vendor = "Vishay"; partNumber = "CRCW0805300R"; url = "https://www.digikey.com" }
    part osc_part: VendorPart { vendor = "Texas Instruments"; partNumber = "NE555P"; url = "https://www.digikey.com" }
  }
}