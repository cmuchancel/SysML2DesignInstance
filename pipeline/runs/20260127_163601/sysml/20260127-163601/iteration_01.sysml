package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  requirement def Req_Sourcable { text = "Make components sourceable from Mouser"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V = 5.0)
  }
  // Assumed maximum LED forward current for requirement validation; adjust if different
  constraint def C_Current {
    in i: Real;
    (i > 0.0) and (i <= 0.03)
  }
  part def LED { }
  part def Driver { }
}