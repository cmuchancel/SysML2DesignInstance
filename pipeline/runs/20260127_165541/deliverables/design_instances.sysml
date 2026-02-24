package DesignInstances {
  public import ScalarValues::*;
  part def ConceptInstance {
    attribute name: String;
    attribute approach: String;
    attribute note: String;
  }
  part Concept_1 : ConceptInstance {
    name = "NE555-astable";
    approach = "Use an NE555 in astable mode to blink an LED near 10 Hz from 5 V with RC timing and a series current-limiting resistor.";
    note = "timeout";
  }
  part Concept_2 : ConceptInstance {
    name = "Microcontroller-PWM";
    approach = "Use a low-cost 8-bit MCU (e.g., ATtiny/STM8) running a 10 Hz toggle to drive the LED via a series resistor.";
    note = "timeout";
  }
  part Concept_3 : ConceptInstance {
    name = "OpAmp-Relaxation";
    approach = "Use a rail-to-rail op-amp Schmitt-trigger relaxation oscillator set to ~10 Hz, feeding the LED through a resistor.";
    note = "timeout";
  }
} end DesignInstances;