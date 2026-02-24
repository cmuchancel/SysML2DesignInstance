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
      title = "NE555P (Texas Instruments)";
      url = "https://www.mouser.com/ProductDetail/Texas-Instruments/NE555P?qs=rkhjVJ6%2F3EIf4CWgjIKuKQ%3D%3D";
      status = "selected";
    }
    part Concept_1_led : SlotSelection {
      slot = "led";
      title = "521-8714F (Dialight)";
      url = "https://www.mouser.com/ProductDetail/Dialight/521-8714F?qs=sGAEpiMZZMv0DJfhVcWlK8AiAHwfAGPKKNEjxXhf2%252B5DZFNd2R%252BhRA%3D%3D";
      status = "selected";
    }
    part Concept_1_resistor : SlotSelection {
      slot = "resistor";
      title = "MFR-25FBF52-100R (YAGEO)";
      url = "https://www.mouser.com/ProductDetail/YAGEO/MFR-25FBF52-100R?qs=oAGoVhmvjhyaHXp7Uz6NEg%3D%3D";
      status = "selected";
    }
    part Concept_1_supply : SlotSelection {
      slot = "supply";
      title = "SWI5-5-N-MUB (CUI Inc.)";
      url = "https://www.mouser.com/ProductDetail/CUI-Inc/SWI5-5-N-MUB?qs=68fdWXBrnHLK0P9XPmNDtw%3D%3D";
      status = "selected";
    }
  }
  part Concept_2 : ConceptInstance {
    name = "Microcontroller-PWM";
    approach = "Use a low-cost 8-bit MCU (e.g., ATtiny/STM8) running a 10 Hz toggle to drive the LED via a series resistor.";
    part Concept_2_mcu : SlotSelection {
      slot = "mcu";
      title = "ATTINY13A-PU (Microchip Technology)";
      url = "https://www.mouser.com/ProductDetail/Microchip-Technology/ATTINY13A-PU?qs=K8BHR703ZXiDNdm7IoCHTw%3D%3D";
      status = "selected";
    }
    part Concept_2_led : SlotSelection {
      slot = "led";
      title = "WP7113ID5V (Kingbright)";
      url = "https://www.mouser.com/ProductDetail/Kingbright/WP7113ID5V?qs=58z0TXQGVSQgkIxR0kd%2F5Q%3D%3D";
      status = "selected";
    }
    part Concept_2_resistor : SlotSelection {
      slot = "resistor";
      title = "MFR-25FRF52-100R (YAGEO)";
      url = "https://www.mouser.com/ProductDetail/YAGEO/MFR-25FRF52-100R";
      status = "selected";
    }
    part Concept_2_supply : SlotSelection {
      slot = "supply";
      title = "SWI5-5-N-MUB (CUI Inc.)";
      url = "https://www.mouser.com/ProductDetail/CUI-Inc/SWI5-5-N-MUB?qs=68fdWXBrnHLK0P9XPmNDtw%3D%3D";
      status = "selected";
    }
  }
  part Concept_3 : ConceptInstance {
    name = "OpAmp-Relaxation";
    approach = "Use a rail-to-rail op-amp Schmitt-trigger relaxation oscillator set to ~10 Hz, feeding the LED through a resistor.";
    part Concept_3_opamp : SlotSelection {
      slot = "opamp";
      title = "MCP6001T-E/OT (Microchip Technology)";
      url = "https://pt.mouser.com/ProductDetail/Microchip-Technology/MCP6001T-E-OT?qs=npqfqDPP3%2FwkX3GgGH%252BE4A%3D%3D";
      status = "selected";
    }
    part Concept_3_led : SlotSelection {
      slot = "led";
      title = "WP7113LYD (Kingbright)";
      url = "https://pt.mouser.com/ProductDetail/Kingbright/WP7113LYD?qs=58z0TXQGVST7mfYOZ14%2FqQ%3D%3D";
      status = "selected";
    }
    part Concept_3_resistor : SlotSelection {
      slot = "resistor";
      title = "RMCA0805FT100R-HP (SEI Stackpole)";
      url = "https://www.mouser.com/ProductDetail/SEI-Stackpole/RMCA0805FT100R-HP?qs=PBDs2xEllI%252BBgu8rJP2glA%3D%3D";
      status = "selected";
    }
    part Concept_3_supply : SlotSelection {
      slot = "supply";
      title = "T7633ST (Cicor)";
      url = "https://ro.mouser.com/new/cicor/stadium-charging-power-bank/";
      status = "selected";
    }
  }
} end DesignInstances;