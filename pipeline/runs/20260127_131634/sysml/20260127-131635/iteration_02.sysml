package LedFlicker {
  requirement LED_Flicker {
    short = "LED flickers at 10 Hz ±5% from 5 V supply with current limiting and vendor-sourceable parts"
    text = "Specification: LED blink frequency = 10 Hz ±5% (9.5–10.5 Hz) when powered from a 5.0 V supply. Include a series current-limiting resistor sized for typical LED forward voltage (assume Vf ≈ 2.0 V) and target current ≈10 mA → R ≈ (5.0−2.0)/0.01 = 300 Ω (use standard 330 Ω). Example vendor-sourceable parts: LED Kingbright WP710A10ID, Resistor Vishay CRCW0805330R (330 Ω), Timer NE555P (Texas Instruments) or equivalent microcontroller PWM source. Assumption: Vf ≈ 2.0 V and target LED current ≈10 mA unless specified otherwise."
  }
}