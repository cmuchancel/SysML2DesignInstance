package FlickerCircuit {
  requirement FREQ {
    id = "REQ-001";
    text = "NE555 astable on 5 V supply producing LED blink 10 Hz ±5% (9.5–10.5 Hz). Recommended design: NE555 (standard 8‑pin) astable with Ra = 20 kΩ, Rb = 62 kΩ (or 50 kΩ potentiometer + 12 kΩ fixed), C = 1 μF. Frequency f ≈ 1.44 / ((Ra + 2·Rb)·C) ≈ 10 Hz. LED current limiting: LED Vf ≈ 2.0 V (red); R_led = 330 Ω → I ≈ (5 V − Vf)/R ≈ 9–10 mA. Parts sourceable from common vendors (e.g., NE555 / LM555 from TI/OnSemi via Digi-Key/Mouser, 1 μF MLCC/electrolytic from Murata/Vishay/TDK, standard resistors and 5 mm LEDs from Kingbright/OSRAM). Verification: measure blink frequency at 5 V and adjust Rb/pot to achieve 10 Hz ±5%.";
  }
}