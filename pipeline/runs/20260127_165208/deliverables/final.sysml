package LEDFlicker {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  requirement def Req_Sourceable { text = "Components should be procureable from common distributors (e.g., Mouser)"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V >= 4.75) and (V <= 5.25)
  }
  constraint def C_CurrentLimit {
    in I_led: Real;
    in I_limit: Real;
    (I_led <= I_limit)
  }
  // abstract components
  part def LED { }
  part def Oscillator { }
  part def CurrentLimiter { }
  part def PowerSource { }
}