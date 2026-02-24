package pipelinetest {

  //========================
  // 0. Constraint defs
  //========================

  constraint def SystemVoltage_C {
    in v;
    (v >= 4.75) and (v <= 5.25)
  }

  constraint def MicrocontrollerRequired_C {
    in hasMicro;
    hasMicro
  }

  constraint def LEDIndicator_C {
    in hasLED;
    in hasResistor;
    hasLED and hasResistor
  }

  constraint def PushButtonRequired_C {
    in hasButton;
    hasButton
  }

  constraint def DigiKeyOnly_C {
    in allFromDigiKey;
    allFromDigiKey
  }

  //========================
  // 1. Part type
  //========================

  part def DemoBoard {
    attribute vcc;            // supply voltage
    attribute hasMicro;
    attribute hasLED;
    attribute hasResistor;
    attribute hasButton;
    attribute allFromDigiKey;

    //--- Assertions bound to the DemoBoard attributes

    assert constraint systemVoltage_ok : SystemVoltage_C {
      in v = vcc;
    }

    assert constraint micro_ok : MicrocontrollerRequired_C {
      in hasMicro = hasMicro;
    }

    assert constraint led_ok : LEDIndicator_C {
      in hasLED      = hasLED;
      in hasResistor = hasResistor;
    }

    assert constraint button_ok : PushButtonRequired_C {
      in hasButton = hasButton;
    }

    assert constraint digikey_ok : DigiKeyOnly_C {
      in allFromDigiKey = allFromDigiKey;
    }
  }

  //========================
  // 2. Configured instances
  //========================

  part demoBoard : DemoBoard {
    vcc            = 5.0;
    hasMicro       = true;
    hasLED         = true;
    hasResistor    = true;
    hasButton      = true;
    allFromDigiKey = true;
  }
}
