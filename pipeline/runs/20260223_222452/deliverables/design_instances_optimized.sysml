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
    partSelectionStatus = "all_slots_sourced";
    constraintValidationStatus = "pass";
    designFeasible = true;
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
      title = "NE555P (Texas Instruments)";
      url = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P?qs=rkhjVJ6%2F3EIf4CWgjIKuKQ%3D%3D";
      status = "selected";
      constraintScore = 4;
      stock = 28591;
      unitPriceUsd = 0.5;
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "521-8714F (Dialight)";
      url = "https://www.mouser.com/ProductDetail/Dialight/521-8714F?qs=sGAEpiMZZMv0DJfhVcWlK8AiAHwfAGPKKNEjxXhf2%252B5DZFNd2R%252BhRA%3D%3D";
      status = "selected";
      constraintScore = 5;
      stock = 1410;
      unitPriceUsd = 0.62;
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "MFR-25FBF52-100R (YAGEO)";
      url = "https://www.mouser.com/ProductDetail/YAGEO/MFR-25FBF52-100R?qs=oAGoVhmvjhyaHXp7Uz6NEg%3D%3D";
      status = "selected";
      constraintScore = 7;
      stock = 2093;
      unitPriceUsd = 0.17;
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "SWI5-5-N-MUB (CUI Inc.)";
      url = "https://www.mouser.com/ProductDetail/CUI-Inc/SWI5-5-N-MUB?qs=68fdWXBrnHLK0P9XPmNDtw%3D%3D";
      status = "selected";
      constraintScore = 5;
      stock = 1856;
      unitPriceUsd = 5.5;
    }
  }
  part Concept_2 : ConceptInstance {
    name = "Microcontroller-PWM";
    approach = "Use a low-cost 8-bit MCU (e.g., ATtiny/STM8) running a 10 Hz toggle to drive the LED via a series resistor.";
    optimizationStatus = "success";
    partSelectionStatus = "all_slots_sourced";
    constraintValidationStatus = "pass";
    designFeasible = true;
    part Concept_2_opt_battery_capacity_mah : OptimizedAttribute {
      attr = "battery_capacity_mAh";
      value = 500.01501129;
    }
    part Concept_2_opt_driver_quiescent_ma : OptimizedAttribute {
      attr = "driver_quiescent_mA";
      value = 18.16893609;
    }
    part Concept_2_opt_efficiency_factor : OptimizedAttribute {
      attr = "efficiency_factor";
      value = 0.97918731;
    }
    part Concept_2_opt_led_current_ma : OptimizedAttribute {
      attr = "led_current_mA";
      value = 13.9966201;
    }
    part Concept_2_opt_resistor_ohm : OptimizedAttribute {
      attr = "resistor_ohm";
      value = 100.00163834;
    }
    part Concept_2_opt_supply_voltage_v : OptimizedAttribute {
      attr = "supply_voltage_V";
      value = 4.91971192;
    }
    part Concept_2_opt_timing_cap_uf : OptimizedAttribute {
      attr = "timing_cap_uF";
      value = 7.37952532;
    }
    part Concept_2_opt_timing_resistor_kohm : OptimizedAttribute {
      attr = "timing_resistor_kohm";
      value = 19.52122433;
    }
    part Concept_2_mcu : SlotSelection {
      slot = "mcu";
      title = "ATTINY13A-PU (Microchip Technology)";
      url = "https://www.mouser.com/ProductDetail/Microchip-Technology/ATTINY13A-PU?qs=K8BHR703ZXiDNdm7IoCHTw%3D%3D";
      status = "selected";
      constraintScore = 4;
      stock = 5529;
      unitPriceUsd = 1.13;
    }
    part Concept_2_led : SlotSelection {
      slot = "led";
      title = "WP7113ID5V (Kingbright)";
      url = "https://www.mouser.com/ProductDetail/Kingbright/WP7113ID5V?qs=58z0TXQGVSQgkIxR0kd%2F5Q%3D%3D";
      status = "selected";
      constraintScore = 7;
      stock = 1890;
      unitPriceUsd = 0.378;
    }
    part Concept_2_resistor : SlotSelection {
      slot = "resistor";
      title = "MFR-25FRF52-100R (YAGEO)";
      url = "https://www.mouser.com/ProductDetail/YAGEO/MFR-25FRF52-100R";
      status = "selected";
      constraintScore = 9;
      stock = 34767;
      unitPriceUsd = 0.12;
    }
    part Concept_2_supply : SlotSelection {
      slot = "supply";
      title = "SWI5-5-N-MUB (CUI Inc.)";
      url = "https://www.mouser.com/ProductDetail/CUI-Inc/SWI5-5-N-MUB?qs=68fdWXBrnHLK0P9XPmNDtw%3D%3D";
      status = "selected";
      constraintScore = 2;
      stock = 1856;
      unitPriceUsd = 5.5;
    }
  }
  part Concept_3 : ConceptInstance {
    name = "OpAmp-Relaxation";
    approach = "Use a rail-to-rail op-amp Schmitt-trigger relaxation oscillator set to ~10 Hz, feeding the LED through a resistor.";
    optimizationStatus = "success";
    partSelectionStatus = "all_slots_sourced";
    constraintValidationStatus = "pass";
    designFeasible = true;
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
      title = "MCP6001T-E/OT (Microchip Technology)";
      url = "https://pt.mouser.com/ProductDetail/Microchip-Technology/MCP6001T-E-OT?qs=npqfqDPP3%2FwkX3GgGH%252BE4A%3D%3D";
      status = "selected";
      constraintScore = 6;
      stock = 33303;
      unitPriceUsd = 0.301;
    }
    part Concept_3_led : SlotSelection {
      slot = "led";
      title = "WP7113LYD (Kingbright)";
      url = "https://pt.mouser.com/ProductDetail/Kingbright/WP7113LYD?qs=58z0TXQGVST7mfYOZ14%2FqQ%3D%3D";
      status = "selected";
      constraintScore = 4;
      stock = 3479;
      unitPriceUsd = 0.215;
    }
    part Concept_3_resistor : SlotSelection {
      slot = "resistor";
      title = "RMCA0805FT100R-HP (SEI Stackpole)";
      url = "https://www.mouser.com/ProductDetail/SEI-Stackpole/RMCA0805FT100R-HP?qs=PBDs2xEllI%252BBgu8rJP2glA%3D%3D";
      status = "selected";
      constraintScore = 10;
      stock = 14860;
      unitPriceUsd = 0.12;
    }
    part Concept_3_supply : SlotSelection {
      slot = "supply";
      title = "T7633ST (Cicor)";
      url = "https://ro.mouser.com/new/cicor/stadium-charging-power-bank/";
      status = "selected";
      constraintScore = 2;
      stock = 0;
      unitPriceUsd = 0;
    }
  }
} end DesignInstancesOptimized;