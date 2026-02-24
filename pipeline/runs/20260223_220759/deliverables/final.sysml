package FlasherRequirements {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from a 5 V rechargeable supply"; }
  requirement def Req_Current { text = "LED current between 8 mA and 20 mA with current limiting"; }
  requirement def Req_Runtime { text = "Operate at least 8 hours per charge"; }
  requirement def Req_OTS { text = "Use sourceable off-the-shelf components"; }
  // Assume 5 V nominal with ±5% tolerance
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V >= 4.75) and (V <= 5.25)
  }
  constraint def C_Current {
    in I_A: Real;
    (I_A >= 0.008) and (I_A <= 0.02)
  }
  constraint def C_Runtime {
    in t_hr: Real;
    (t_hr >= 8)
  }
  part def LED { }
  part def Driver { }
  part def Battery { }
}