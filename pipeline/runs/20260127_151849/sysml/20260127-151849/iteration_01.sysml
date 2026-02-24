/* assumption: "flicker" is a periodic on/off toggle at the specified frequency; 5 V is nominal DC supply. */

package LEDFlickerModel {

    requirement REQ_FREQUENCY {
        name: "LED flicker frequency";
        statement: "LED shall flicker at 10 Hz ±5%";
        id: "REQ-001";
    }

    requirement REQ_SUPPLY {
        name: "Supply voltage";
        statement: "Circuit shall operate from a 5 V DC supply";
        id: "REQ-002";
    }

    requirement REQ_CURRENT_LIMIT {
        name: "Current limiting";
        statement: "Circuit shall include a current-limiting element to protect the LED";
        id: "REQ-003";
    }

    requirement REQ_SOURCEABLE {
        name: "Commercial sourceability";
        statement: "Circuit components shall be commercially available from Mouser";
        id: "REQ-004";
    }

    constraint C_FREQUENCY_RANGE {
        name: "Frequency tolerance";
        expression: "Oscillator.frequency_Hz >= 9.5 and Oscillator.frequency_Hz <= 10.5";
    }

    constraint C_SUPPLY_VOLTAGE {
        name: "Supply voltage nominal";
        expression: "LED_Flicker_Circuit.supplyVoltage_V = 5.0";
    }

    constraint C_CURRENT_LIMIT {
        name: "Current limit <= LED rating";
        expression: "CurrentLimiter.limitedCurrent_mA <= LED.maxContinuousCurrent_mA";
    }

    block LED {
        property forwardVoltage_V: Real;
        property maxContinuousCurrent_mA: Real;
    }

    block CurrentLimiter {
        property limitedCurrent_mA: Real;
        property method: String?; // e.g., resistor or active limiter (abstract)
    }

    block Oscillator {
        property frequency_Hz: Real;
        property driveType: String?; // e.g., digital toggle (abstract)
    }

    block LED_Flicker_Circuit {
        part led: LED;
        part limiter: CurrentLimiter;
        part osc: Oscillator;
        property supplyVoltage_V: Real;
    }

}