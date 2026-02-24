package LEDFlasher {
  public import ScalarValues::*;
  requirement def R_Freq { text = "LED blinks at 10 Hz ±5%"; }
  requirement def R_Supply { text = "Operate from a 5 V rechargeable supply"; }
  requirement def R_Current { text = "LED current maintained between 8 mA and 20 mA"; }
  requirement def R_Runtime { text = "Run at least 8 hours per charge"; }
  requirement def R_OTS { text = "Use sourceable off-the-shelf parts"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V >= 4.75) and (V <= 5.25)
  }
  constraint def C_Current {
    in I: Real;
    (I >= 0.008) and (I <= 0.020)
  }
  constraint def C_Runtime {
    in t: Real;
    (t >= 8.0)
  }
  part def LED { }
  part def Driver { }
  part def Battery { }
  part def Charger { }
}