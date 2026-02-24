// Assumption: "Mouser" refers to a commercial electronic components distributor; selection of specific part numbers is deferred downstream.

package FlickerLEDModel {
  requirement R_FLICKER {
    id = "REQ-001"
    text = "LED flickers at 10 Hz ±5%."
  }

  requirement R_SUPPLY {
    id = "REQ-002"
    text = "Operates from a 5 V DC supply."
  }

  requirement R_CURRENT_LIMIT {
    id = "REQ-003"
    text = "Includes current limiting to protect the LED and constrain LED current to safe operating levels."
  }

  requirement R_SOURCEABLE {
    id = "REQ-004"
    text = "All components shall be available for purchase from Mouser Electronics."
  }

  constraint FrequencyConstraint {
    expression = "oscillator.frequency >= 9.5 and oscillator.frequency <= 10.5"
    comment = "Frequency bounds in Hz (10 Hz ±5%)."
  }

  constraint SupplyConstraint {
    expression = "power.nominalVoltage = 5.0"
    comment = "Supply nominal voltage in volts."
  }

  constraint CurrentLimitConstraint {
    expression = "currentLimiter.maxCurrent <= led.ratedCurrent"
    comment = "Current limiter must limit current to at-or-below LED rated current."
  }

  block FlickerCircuit {
    property power: PowerInterface[1];
    property oscillator: Oscillator[1];
    property driver: DriveStage[1];
    property led: LED[1];
    property currentLimiter: CurrentLimiter[1];
  }

  block PowerInterface {
    property nominalVoltage: Real;
  }

  block Oscillator {
    property frequency: Real;
  }

  block DriveStage {
    property driveCurrent: Real;
  }

  block LED {
    property forwardVoltage: Real;
    property ratedCurrent: Real;
  }

  block CurrentLimiter {
    property maxCurrent: Real;
  }
}