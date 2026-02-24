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
    part Concept_1_opt_avg_current_ma : OptimizedAttribute {
      attr = "avg_current_mA";
      value = 10.78662666;
    }
    part Concept_1_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 4380.06356579;
    }
    part Concept_1_opt_blink_frequency_hz : OptimizedAttribute {
      attr = "blink_frequency_hz";
      value = 9.5006053;
    }
    part Concept_1_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 2.86607522;
    }
    part Concept_1_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.9620509;
    }
    part Concept_1_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 15.85771014;
    }
    part Concept_1_opt_performance_penalty : OptimizedAttribute {
      attr = "performance_penalty";
      value = 4.68068575;
    }
    part Concept_1_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 2037.46586523;
    }
    part Concept_1_opt_runtime_hours : OptimizedAttribute {
      attr = "runtime_hours";
      value = 405.75064379;
    }
    part Concept_1_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 5.19020172;
    }
    part Concept_1_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 4.96735278;
    }
    part Concept_1_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 31.52778908;
    }
    part Concept_1_opt_total_cost_usd : OptimizedAttribute {
      attr = "total_cost_usd";
      value = 29.82593827;
    }
    part Concept_1_driver : SlotSelection {
      slot = "driver";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 20s";
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
    part Concept_2_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 500.00003447;
    }
    part Concept_2_opt_blink_frequency_hz : OptimizedAttribute {
      attr = "blink_frequency_hz";
      value = 10.18638146;
    }
    part Concept_2_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 8.75854782;
    }
    part Concept_2_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.97999986;
    }
    part Concept_2_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 14.00012206;
    }
    part Concept_2_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 100.00007024;
    }
    part Concept_2_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 5.01034654;
    }
    part Concept_2_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 18.1084389;
    }
    part Concept_2_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 7.80611821;
    }
    part Concept_2_mcu : SlotSelection {
      slot = "mcu";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_led : SlotSelection {
      slot = "led";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_2_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 20s";
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
    part Concept_3_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 500.00001299;
    }
    part Concept_3_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 1.41583155;
    }
    part Concept_3_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.97999964;
    }
    part Concept_3_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 13.98605827;
    }
    part Concept_3_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 100.0020014;
    }
    part Concept_3_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 5.01836478;
    }
    part Concept_3_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 7.16967517;
    }
    part Concept_3_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 19.98165549;
    }
    part Concept_3_opamp : SlotSelection {
      slot = "opamp";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_led : SlotSelection {
      slot = "led";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_resistor : SlotSelection {
      slot = "resistor";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
    part Concept_3_supply : SlotSelection {
      slot = "supply";
      title = "timeout after 20s";
      url = "";
      status = "not_found";
      constraintScore = 0;
      stock = 0;
      unitPriceUsd = 0;
    }
  }
} end DesignInstancesOptimized;