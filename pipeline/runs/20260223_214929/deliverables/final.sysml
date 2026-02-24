package LEDFlasherRequirements {
  public import ScalarValues::*;
  requirement def R_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def R_Supply { text = "Operate from a 5 V rechargeable supply"; }
  requirement def R_Current { text = "LED current maintained between 8 mA and 20 mA with current limiting"; }
  requirement def R_Runtime { text = "Operates at least 8 hours per charge"; }
  requirement def R_OffTheShelf { text = "Use sourceable off-the-shelf components"; }
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
    in T: Real;
    (T >= 8.0)
  }
  // Assumption: runtime T is hours of continuous operation per full charge under typical blinking load
  part def LED { }
  part def Driver { }
  part def CurrentLimiter { }
  part def Controller { }
  part def Battery { }
  part def Charger { }
}