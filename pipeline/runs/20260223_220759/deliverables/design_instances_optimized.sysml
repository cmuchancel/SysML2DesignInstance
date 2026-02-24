package DesignInstancesOptimized {
  public import ScalarValues::*;
  part def ConceptInstance {
    attribute name: String;
    attribute approach: String;
    attribute optimizationStatus: String;
    attribute partSelectionStatus: String;
    attribute constraintValidationStatus: String;
    attribute designFeasible: Boolean;
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
    partSelectionStatus = "infeasible_no_parts";
    constraintValidationStatus = "fail";
    designFeasible = false;
    part Concept_1_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 881.30261734;
    }
    part Concept_1_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 6.78272412;
    }
    part Concept_1_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.83369315;
    }
    part Concept_1_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 13.43623983;
    }
    part Concept_1_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 607.31290083;
    }
    part Concept_1_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 4.87324082;
    }
    part Concept_1_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 17.49739755;
    }
    part Concept_1_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 8.54796017;
    }
    part Concept_1_driver : SlotSelection {
      slot = "driver";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 8s";
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
    optimizationStatus = "success";
    partSelectionStatus = "infeasible_no_parts";
    constraintValidationStatus = "fail";
    designFeasible = false;
    part Concept_2_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 581.37914562;
    }
    part Concept_2_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 1.10115512;
    }
    part Concept_2_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.61344093;
    }
    part Concept_2_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 12.44115236;
    }
    part Concept_2_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 527.94880972;
    }
    part Concept_2_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 5.23447499;
    }
    part Concept_2_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 2.29012696;
    }
    part Concept_2_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 60.25173657;
    }
    part Concept_2_mcu : SlotSelection {
      slot = "mcu";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_led : SlotSelection {
      slot = "led";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 8s";
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
    optimizationStatus = "success";
    partSelectionStatus = "infeasible_no_parts";
    constraintValidationStatus = "fail";
    designFeasible = false;
    part Concept_3_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 711.89351598;
    }
    part Concept_3_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 18.63779184;
    }
    part Concept_3_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.68350961;
    }
    part Concept_3_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 12.65277084;
    }
    part Concept_3_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 145.13167348;
    }
    part Concept_3_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 4.93535402;
    }
    part Concept_3_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 8.11777645;
    }
    part Concept_3_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 17.81705945;
    }
    part Concept_3_opamp : SlotSelection {
      slot = "opamp";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_led : SlotSelection {
      slot = "led";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 8s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
  }
} end DesignInstancesOptimized;