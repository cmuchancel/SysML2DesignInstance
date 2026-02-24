package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED blinks at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from a 5 V rechargeable supply"; }
  requirement def Req_Current { text = "LED current maintained between 8 mA and 20 mA"; }
  requirement def Req_RunTime { text = "Runtime of at least 8 hours per full charge"; }
  requirement def Req_SOTF { text = "Design uses sourceable off-the-shelf parts"; }

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
  // t_hr is in hours
  constraint def C_RunTime {
    in t_hr: Real;
    (t_hr >= 8.0)
  }

  part def LED { }
  part def FlasherCircuit { }
  part def Driver { }
  part def PowerSource { }
}