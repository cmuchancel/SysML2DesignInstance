package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V rechargeable supply"; }
  requirement def Req_Current { text = "LED current between 8 mA and 20 mA with current limiting"; }
  requirement def Req_Runtime { text = "Run at least 8 hours per charge"; }
  requirement def Req_Parts { text = "Use sourceable off-the-shelf parts"; }

  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }

  constraint def C_Supply {
    in V: Real;
    (V >= 4.75) and (V <= 5.25)
  }

  constraint def C_Current {
    in I_led_mA: Real;
    (I_led_mA >= 8) and (I_led_mA <= 20)
  }

  // Assume C_mAh is battery capacity in mAh and Iavg_mA is average system draw in mA over runtime
  constraint def C_Runtime {
    in C_mAh: Real;
    in Iavg_mA: Real;
    (C_mAh >= Iavg_mA * 8)
  }

  part def LED { }
  part def Driver { }
  part def FlasherController { }
  part def Battery { }
  part def Charger { }
  part def Regulator { }
}