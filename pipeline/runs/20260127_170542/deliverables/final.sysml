package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  requirement def Req_Sourceable { text = "Components and modules sourceable from Mouser"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V >= 4.75) and (V <= 5.25)
  }
  // assume typical LED forward current limit of 20 mA if not otherwise specified
  constraint def C_Current {
    in I: Real;
    (I >= 0.0) and (I <= 0.02)
  }
  part def LED { }
  part def Driver { }
  part def CurrentLimiter { }
  part def Supply { }
}