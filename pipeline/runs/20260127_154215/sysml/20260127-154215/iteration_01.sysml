package LEDFlickerModel
{
    requirement Flicker {
        id = "REQ-001"
        text = "LED flickers at 10 Hz ±5% when driven from a 5 V supply."
    }

    requirement CurrentLimit {
        id = "REQ-002"
        text = "Circuit provides current limiting to protect the LED and driver."
    }

    requirement Sourceable {
        id = "REQ-003"
        text = "All components shall be commercially available and sourceable from Mouser."
    }

    constraintblock FlickerConstraint {
        parameter frequency : Real
        parameter supplyVoltage : Real
        expression = "frequency >= 10*0.95 and frequency <= 10*1.05 and supplyVoltage == 5.0"
    }

    block Oscillator {
        property outputFrequency : Real
    }

    block CurrentLimiter {
        property limitCurrent : Real
    }

    block LEDDriver {
        part oscillator : Oscillator
        part limiter : CurrentLimiter
        property supplyVoltage : Real
    }

    /* Assumption: concrete component selection, resistor/driver values, and Mouser part numbers will be provided in downstream refinements; this model remains solution-agnostic. */
}