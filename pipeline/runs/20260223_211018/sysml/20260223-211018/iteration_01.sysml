package RequirementsOnly {
  public import ScalarValues::*;
  requirement def Req_Brief1 { text = "Design a 5V rechargeable LED flasher that blinks at 10 Hz ±5%, keeps LED current between 8 mA and 20 mA, runs at least 8 hours per charge, and uses sourceable off-the-shelf parts." }
  requirement def Req_Brief2 { text = "Design a 5V rechargeable LED flasher that blinks at 10 Hz ±5%, keeps LED current between 8 mA and 20 mA, runs at least 8 hours per charge, and uses sourceable off-the-shelf parts." }
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
    (I >= 0.008) and (I <= 0.02)
  }
  constraint def C_Runtime {
    in t_h: Real;
    (t_h >= 8)
  }
  part def LED { }
  part def PowerSource { }
  part def FlasherDriver { }
}