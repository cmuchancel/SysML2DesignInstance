package DesignInstancesOptimized {
  public import ScalarValues::*;
  part def ConceptInstance {
    attribute name: String;
    attribute approach: String;
    attribute optimizationStatus: String;
  }
  part def OptimizedAttribute {
    attribute attr: String;
    attribute value: Real;
  }
  part def SlotSelection {
    attribute slot: String;
    attribute title: String;
    attribute url: String;
    attribute status: String;
    attribute constraintScore: Real;
    attribute stock: Real;
    attribute unitPriceUsd: Real;
  }
  part Concept_1 : ConceptInstance {
    name = "NE555-astable";
    approach = "Use an NE555 in astable mode to blink an LED near 10 Hz from 5 V with RC timing and a series current-limiting resistor.";
    optimizationStatus = "success";
    part Concept_1_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 500.00001299;
    }
    part Concept_1_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 1.41583155;
    }
    part Concept_1_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.97999964;
    }
    part Concept_1_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 13.98605827;
    }
    part Concept_1_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 100.0020014;
    }
    part Concept_1_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 5.01836478;
    }
    part Concept_1_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 7.16967517;
    }
    part Concept_1_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 19.98165549;
    }
    part Concept_1_driver : SlotSelection {
      slot = "driver";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 30s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
  }
  part Concept_2 : ConceptInstance {
    name = "Microcontroller-PWM";
    approach = "Use a low-cost 8-bit MCU (e.g., ATtiny/STM8) running a 10 Hz toggle to drive the LED via a series resistor.";
    optimizationStatus = "error";
    part Concept_2_mcu : SlotSelection {
      slot = "mcu";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_led : SlotSelection {
      slot = "led";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_resistor : SlotSelection {
      slot = "resistor";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_supply : SlotSelection {
      slot = "supply";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
  }
  part Concept_3 : ConceptInstance {
    name = "OpAmp-Relaxation";
    approach = "Use a rail-to-rail op-amp Schmitt-trigger relaxation oscillator set to ~10 Hz, feeding the LED through a resistor.";
    optimizationStatus = "error";
    part Concept_3_opamp : SlotSelection {
      slot = "opamp";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_led : SlotSelection {
      slot = "led";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_resistor : SlotSelection {
      slot = "resistor";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_supply : SlotSelection {
      slot = "supply";
      title = "optimization_failed";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
  }
} end DesignInstancesOptimized;