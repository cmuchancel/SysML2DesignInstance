package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  requirement def Req_Sourcing { text = "Components sourceable from Mouser"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in Vs: Real;
    (Vs == 5.0)
  }
  // Assumption: a safe LED forward current limit is 20 mA; refine if different requirements apply
  constraint def C_Current {
    in Iled: Real;
    (Iled > 0.0) and (Iled <= 0.02)
  }
  part def LED { }
  part def Driver { }
  part def CurrentLimiter { }
  part def PowerSupply { }
}