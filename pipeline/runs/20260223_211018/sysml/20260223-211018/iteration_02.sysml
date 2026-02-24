package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz +/-5%"; }
  requirement def Req_Supply { text = "Operate from a 5 V rechargeable supply"; }
  requirement def Req_Current { text = "LED current limited between 8 mA and 20 mA"; }
  requirement def Req_Runtime { text = "Run at least 8 hours per charge"; }
  requirement def Req_OTS { text = "Use sourceable off-the-shelf parts"; }
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
    (I >= 0.008) and (I <= 0.02)
  }
  constraint def C_Runtime {
    in t_h: Real;
    (t_h >= 8)
  }
  part def LED { }
  part def Driver { }
  part def PowerSource { }
}