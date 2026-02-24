package LedFlickerModel
{
    requirement FlickerRate
    {
        id = "REQ-1"
        text = "LED flickers at 10 Hz ±5% when powered from a 5 V supply."
    }

    requirement CurrentLimiting
    {
        id = "REQ-2"
        text = "Circuit provides current limiting to protect the LED and its driver."
    }

    requirement CommercialAvailability
    {
        id = "REQ-3"
        text = "Components shall be commercially available as COTS parts from major electronics distributors."
    }

    constraintDefinition FrequencyRange
    {
        id = "C-1"
        expression = "frequency >= 9.5 and frequency <= 10.5"  // frequency in Hz
    }

    block BlinkController
    {
        description = "Abstract driver producing a timed blink signal and providing LED drive interface."
        property supplyVoltage: Real { default = 5.0 }  // V
        property targetFrequency: Real { default = 10.0 }  // Hz
        part led: LED
        part currentLimiter: CurrentLimiter
        constraint applyFrequency: FrequencyRange { bind frequency = targetFrequency }
    }

    block LED
    {
        description = "Abstract LED element (specify forward voltage and allowable current in refinements)."
        property forwardVoltage: Real
        property maxContinuousCurrent: Real  // A
    }

    block CurrentLimiter
    {
        description = "Abstract current-limiting element (series resistor, constant-current driver, etc.)."
        property limitCurrent: Real  // A
    }
}