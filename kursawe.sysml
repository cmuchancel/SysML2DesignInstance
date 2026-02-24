package KursaweDemo {
  public import ScalarValues::*;
  public import RealFunctions::*;
  public import TrigFunctions::*;

  // Base of natural logarithm for exp(x) definition
  attribute E: Real = 2.718281828459045;

  calc def exp {
    in x: Real;
    return : Real = E ** x;
  }

  constraint def Bounds_C {
    in x: Real;
    in lower: Real;
    in upper: Real;
    (x >= lower) and (x <= upper)
  }

  constraint def F1_Def {
    in x1: Real;
    in x2: Real;
    in x3: Real;
    in f1: Real;
    f1 ==
      (-10.0 * exp(-0.2 * sqrt(x1 ** 2.0 + x2 ** 2.0))) +
      (-10.0 * exp(-0.2 * sqrt(x2 ** 2.0 + x3 ** 2.0)))
  }

  constraint def F2_Def {
    in x1: Real;
    in x2: Real;
    in x3: Real;
    in f2: Real;
    f2 ==
      (abs(x1) ** 0.8 + 5.0 * sin(x1 ** 3.0)) +
      (abs(x2) ** 0.8 + 5.0 * sin(x2 ** 3.0)) +
      (abs(x3) ** 0.8 + 5.0 * sin(x3 ** 3.0))
  }

  part def KursaweDesign {
    attribute x1: Real;
    attribute x2: Real;
    attribute x3: Real;

    attribute f1: Real;
    attribute f2: Real;

    // objective: minimize f1
    // objective: minimize f2

    assert constraint x1_bounds: Bounds_C { in x = x1; in lower = -5.0; in upper = 5.0; }
    assert constraint x2_bounds: Bounds_C { in x = x2; in lower = -5.0; in upper = 5.0; }
    assert constraint x3_bounds: Bounds_C { in x = x3; in lower = -5.0; in upper = 5.0; }

    assert constraint f1_def: F1_Def { in x1 = x1; in x2 = x2; in x3 = x3; in f1 = f1; }
    assert constraint f2_def: F2_Def { in x1 = x1; in x2 = x2; in x3 = x3; in f2 = f2; }
  }

  part def SystemContext {
    part design: KursaweDesign;
  }
}
