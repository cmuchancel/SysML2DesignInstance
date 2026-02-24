package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  part def LED { }
  part def Driver { }
  part def Supply { }
  part def CurrentLimiter { }
}