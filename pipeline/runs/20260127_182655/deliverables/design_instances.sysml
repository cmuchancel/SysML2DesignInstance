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
      title = "timeout";
      url = "";
      status = "timeout";
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "timeout";
      url = "";
      status = "timeout";
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout";
      url = "";
      status = "timeout";
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "timeout";
      url = "";
      status = "timeout";
    }
  }
} end DesignInstances;