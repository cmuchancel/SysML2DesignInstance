package LEDFlickerModel
{
    requirement REQ_Flicker
    {
        id = "REQ-1"
        text = "LED flickers at 10 Hz ±5% when powered from a 5 V supply."
    }

    requirement REQ_CurrentLimit
    {
        id = "REQ-2"
        text = "Circuit shall include current limiting to protect the LED."
    }

    requirement REQ_Sourceable
    {
        id = "REQ-3"
        text = "All discrete components shall be commercially available from Mouser."
    }

    constraintdef C_FrequencyRange
    {
        parameter freq: Real
        expression = "9.5 <= freq <= 10.5"
        comment = "Enforces 10 Hz ±5% requirement (units: Hz)."
    }

    block PowerSupply
    {
        property voltage: Real
        comment = "Abstract 5 V source (value specified downstream)."
    }

    block LED
    {
        property nominalForwardVoltage: Real
        property maxContinuousCurrent: Real
        port anode: ElectricalPort
        port cathode: ElectricalPort
        comment = "Abstract LED device properties; specific part selected downstream."
    }

    block CurrentLimiter
    {
        property targetCurrentLimit: Real
        port in: ElectricalPort
        port out: ElectricalPort
        comment = "Abstract current-limiting element (resistive or active)."
    }

    block Oscillator
    {
        property targetFrequency: Real
        port output: DigitalSignalPort
        comment = "Abstract flicker/timing source; implements frequency constrained by C_FrequencyRange."
    }
}