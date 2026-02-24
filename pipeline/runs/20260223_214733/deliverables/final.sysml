package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from a 5 V rechargeable supply"; }
  requirement def Req_Current { text = "LED current maintained between 8 mA and 20 mA and include current limiting"; }
  requirement def Req_Runtime { text = "Operate at least 8 hours per charge"; }
  requirement def Req_OffTheShelf { text = "Use sourceable off-the-shelf parts"; }

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
  constraint def C_Runtime {
    in I: Real;
    in H: Real;
    in Cap_mAh: Real;
    // Assumes negligible other loads and ideal charging/discharge efficiency; Cap_mAh in mAh
    (H >= 8) and (I >= 0.008) and (I <= 0.020) and (Cap_mAh >= I * H * 1000)
  }

  part def LED { }
  part def Driver { }
  part def Battery { }
  part def Charger { }
}