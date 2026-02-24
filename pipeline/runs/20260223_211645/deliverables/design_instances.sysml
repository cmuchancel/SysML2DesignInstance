package DesignInstances {
  public import ScalarValues::*;
  part def ConceptInstance {
    attribute name: String;
    attribute approach: String;
  }
  part def SlotSelection {
    attribute slot: String;
    attribute title: String;
    attribute url: String;
    attribute status: String;
  }
  part Concept_1 : ConceptInstance {
    name = "NE555-astable";
    approach = "Use an NE555 in astable mode to blink an LED near 10 Hz from 5 V with RC timing and a series current-limiting resistor.";
    part Concept_1_driver : SlotSelection {
      slot = "driver";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
    }
  }
  part Concept_2 : ConceptInstance {
    name = "Microcontroller-PWM";
    approach = "Use a low-cost 8-bit MCU (e.g., ATtiny/STM8) running a 10 Hz toggle to drive the LED via a series resistor.";
    part Concept_2_mcu : SlotSelection {
      slot = "mcu";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
    part Concept_2_led : SlotSelection {
      slot = "led";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
    part Concept_2_resistor : SlotSelection {
      slot = "resistor";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
    part Concept_2_supply : SlotSelection {
      slot = "supply";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
  }
  part Concept_3 : ConceptInstance {
    name = "OpAmp-Relaxation";
    approach = "Use a rail-to-rail op-amp Schmitt-trigger relaxation oscillator set to ~10 Hz, feeding the LED through a resistor.";
    part Concept_3_opamp : SlotSelection {
      slot = "opamp";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
    part Concept_3_led : SlotSelection {
      slot = "led";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
    part Concept_3_resistor : SlotSelection {
      slot = "resistor";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
    part Concept_3_supply : SlotSelection {
      slot = "supply";
      title = "optimization_failed";
      url = "";
      status = "not_found";
    }
  }
} end DesignInstances;