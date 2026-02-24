package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V supply"; }
  requirement def Req_Current { text = "Include current limiting for LED"; }
  requirement def Req_Source { text = "Components should be sourceable from mainstream distributors (e.g., Mouser)"; }
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in Vsupply: Real;
    (Vsupply = 5.0)
  }
  constraint def C_CurrentLimit {
    in I_led: Real;
    in I_max: Real;
    (I_led <= I_max)
  }
  part def LED { }
  part def Driver { }
}