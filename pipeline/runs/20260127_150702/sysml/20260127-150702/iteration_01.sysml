// Assumptions: using SysMLv2 textual-style model; constraint expressions are informal predicates.
// If syntax requires adjustment, these are semantic placeholders to be checked by SysIDE.

model FlickerLEDModel
{
    // Requirements (top-level)
    requirement R_FLICKER
    {
        id = "REQ-001"
        text = "Circuit shall produce an LED flicker frequency of 10 Hz ±5%."
    }

    requirement R_SUPPLY
    {
        id = "REQ-002"
        text = "Circuit shall operate from a 5 V DC supply."
    }

    requirement R_CURRENT_LIMIT
    {
        id = "REQ-003"
        text = "Circuit shall include current limiting to protect the LED."
    }

    requirement R_SOURCEABLE
    {
        id = "REQ-004"
        text = "Circuit components shall be sourceable from commercial electronic distributors (e.g., Mouser)."
    }

    // Abstract reusable elements (solution-agnostic)
    block LED
    {
        // LED electrical characteristics (abstract; no specific part numbers)
        property Vf: Real   // nominal forward voltage (V)
        property IF_max: Real  // maximum recommended forward current (A)
    }

    block CurrentLimiter
    {
        // Abstract current-limiting element (could be resistor, regulator, constant-current driver, etc.)
        property I_limit: Real  // configured maximum current delivered to LED (A)
    }

    block OscillatorDriver
    {
        // Drives LED blinking; may be analog or digital timer/oscillator
        property f_out: Real  // output flicker frequency (Hz)
        property dutyCycle: Real  // output duty cycle (0..1), optional
    }

    block PowerInterface
    {
        // Interface to the 5 V supply
        property V_in: Real  // supply voltage (V)
    }

    block FlickerCircuit
    {
        part led: LED
        part limiter: CurrentLimiter
        part driver: OscillatorDriver
        part pwr: PowerInterface

        // Exposed/system-level properties
        property flickerFrequency: Real
        property supplyVoltage: Real

        // Constraints (separate, concise)
        constraint FlickerFrequencyConstraint
        {
            // Satisfies R_FLICKER: 10 Hz ±5% => [9.5, 10.5] Hz
            expression = "flickerFrequency >= 9.5 and flickerFrequency <= 10.5"
        }

        constraint SupplyVoltageConstraint
        {
            // Satisfies R_SUPPLY
            expression = "supplyVoltage = 5.0 and pwr.V_in = supplyVoltage"
        }

        constraint CurrentLimitingConstraint
        {
            // Satisfies R_CURRENT_LIMIT: limiter must limit to <= LED IF_max
            expression = "limiter.I_limit <= led.IF_max and limiter.I_limit > 0"
        }

        constraint DriverFrequencyBind
        {
            // Ensure driver output and system flicker frequency are consistent
            expression = "driver.f_out = flickerFrequency"
        }

        constraint SourceabilityConstraint
        {
            // Satisfies R_SOURCEABLE: components shall be procurable (abstract flag; concrete verification downstream)
            expression = "/* Components shall be commercially procureable (to be verified downstream per-part) */ true"
        }
    }
}