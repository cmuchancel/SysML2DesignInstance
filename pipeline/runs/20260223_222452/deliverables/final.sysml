package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Freq { text = "LED flickers at 10 Hz ±5%"; }
  requirement def Req_Supply { text = "Operate from 5 V rechargeable supply"; }
  requirement def Req_CurrentRange { text = "LED current maintained between 8 mA and 20 mA"; }
  requirement def Req_CurrentLimit { text = "Include current limiting for LED"; }
  requirement def Req_RunTime { text = "Run at least 8 hours per charge"; }
  requirement def Req_Rechargeable { text = "Provide rechargeable battery and charging function"; }
  requirement def Req_OTS { text = "Use sourceable off-the-shelf components"; }

  // Assumption: duty cycle d (0<d<=1) models average LED-on fraction; runtime computed from capacity (mAh), current (mA), and hours.
  constraint def C_Freq {
    in f: Real;
    (f >= 9.5) and (f <= 10.5)
  }
  constraint def C_Supply {
    in V: Real;
    (V >= 4.75) and (V <= 5.25)
  }
  constraint def C_Current {
    in I_pk_mA: Real;
    (I_pk_mA >= 8.0) and (I_pk_mA <= 20.0)
  }
  constraint def C_Runtime {
    in capacity_mAh: Real;
    in I_pk_mA: Real;
    in d: Real;
    in T_h: Real;
    (T_h >= 8.0) and (d > 0.0) and (d <= 1.0) and (capacity_mAh >= I_pk_mA * d * T_h)
  }

  part def LED { }
  part def FlasherDriver { }
  part def Battery { }
  part def Charger { }
}