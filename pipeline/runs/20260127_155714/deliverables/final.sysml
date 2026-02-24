package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  requirement def Req_Sourcable { text = "Components should be sourceable from Mouser"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V == 5.0)
  }
  // Assumption: typical LED current limit; refine value later if needed
  constraint def C_Ilim {
    in Imax: Real;
    (Imax <= 0.02)
  }
  part def LED { }
  part def Driver { }
  part def CurrentLimiter { }
}