package concept_2_microcontroller_pwm_optimization {
  public import ScalarValues::*;

  part def FlasherDesign {
    attribute timing_resistor_kohm : Real;
    attribute timing_cap_uF : Real;
    attribute resistor_ohm : Real;
    attribute led_current_mA : Real;
    attribute supply_voltage_V : Real;
    attribute driver_quiescent_mA : Real;
    attribute battery_capacity_mAh : Real;
    attribute efficiency_factor : Real;

    attribute blink_frequency_hz : Real;
    attribute avg_current_mA : Real;
    attribute runtime_hours : Real;
    attribute total_cost_usd : Real;
    attribute performance_penalty : Real;
  }

  part design : FlasherDesign;

  requirement def OptimizationObjectives {
    attribute minimize_cost : Boolean = true;
    attribute minimize_performance_penalty : Boolean = true;
  }

  constraint def VariableBounds {
    parameter timing_resistor_kohm : Real;
    parameter timing_cap_uF : Real;
    parameter resistor_ohm : Real;
    parameter led_current_mA : Real;
    parameter supply_voltage_V : Real;
    parameter driver_quiescent_mA : Real;
    parameter battery_capacity_mAh : Real;
    parameter efficiency_factor : Real;

    constraint { timing_resistor_kohm >= 1.0 and timing_resistor_kohm <= 200.0; }
    constraint { timing_cap_uF >= 0.01 and timing_cap_uF <= 100.0; }
    constraint { resistor_ohm >= 100.0 and resistor_ohm <= 2200.0; }
    constraint { led_current_mA >= 8 and led_current_mA <= 20; }
    constraint { supply_voltage_V >= 4.75 and supply_voltage_V <= 5.25; }
    constraint { driver_quiescent_mA >= 0.2 and driver_quiescent_mA <= 20.0; }
    constraint { battery_capacity_mAh >= 500.0 and battery_capacity_mAh <= 6000.0; }
    constraint { efficiency_factor >= 0.60 and efficiency_factor <= 0.98; }
  }

  constraint def SystemModel {
    parameter timing_resistor_kohm : Real;
    parameter timing_cap_uF : Real;
    parameter resistor_ohm : Real;
    parameter led_current_mA : Real;
    parameter supply_voltage_V : Real;
    parameter driver_quiescent_mA : Real;
    parameter battery_capacity_mAh : Real;
    parameter efficiency_factor : Real;

    parameter blink_frequency_hz : Real;
    parameter avg_current_mA : Real;
    parameter runtime_hours : Real;
    parameter total_cost_usd : Real;
    parameter performance_penalty : Real;

    parameter target_freq_hz : Real = 10;
    parameter target_current_mA : Real = 14;

    constraint {
      blink_frequency_hz == 1.44 / ((timing_resistor_kohm * 1000.0) * (timing_cap_uF * 0.000001));
    }
    constraint {
      avg_current_mA == driver_quiescent_mA + (0.5 * led_current_mA);
    }
    constraint {
      runtime_hours == battery_capacity_mAh / avg_current_mA;
    }
    constraint {
      total_cost_usd == (0.04 * timing_resistor_kohm) + (0.12 * timing_cap_uF) + (0.0025 * resistor_ohm)
                        + (0.02 * led_current_mA) + (0.005 * battery_capacity_mAh) + (0.4 / efficiency_factor);
    }
    constraint {
      performance_penalty == ((blink_frequency_hz - target_freq_hz) * (blink_frequency_hz - target_freq_hz))
                             + ((led_current_mA - target_current_mA) * (led_current_mA - target_current_mA));
    }
  }

  constraint def RequirementConstraints {
    parameter blink_frequency_hz : Real;
    parameter led_current_mA : Real;
    parameter runtime_hours : Real;
    parameter supply_voltage_V : Real;

    constraint { blink_frequency_hz >= 9.5 and blink_frequency_hz <= 10.5; }
    constraint { led_current_mA >= 8 and led_current_mA <= 20; }
    constraint { runtime_hours >= 8; }
    constraint { supply_voltage_V >= 4.75 and supply_voltage_V <= 5.25; }
  }

  constraint def ObjectiveCost {
    parameter total_cost_usd : Real;
    constraint { total_cost_usd == design.total_cost_usd; }
  }

  constraint def ObjectivePerformance {
    parameter performance_penalty : Real;
    constraint { performance_penalty == design.performance_penalty; }
  }

  assert VariableBounds(
    timing_resistor_kohm=design.timing_resistor_kohm,
    timing_cap_uF=design.timing_cap_uF,
    resistor_ohm=design.resistor_ohm,
    led_current_mA=design.led_current_mA,
    supply_voltage_V=design.supply_voltage_V,
    driver_quiescent_mA=design.driver_quiescent_mA,
    battery_capacity_mAh=design.battery_capacity_mAh,
    efficiency_factor=design.efficiency_factor
  );

  assert SystemModel(
    timing_resistor_kohm=design.timing_resistor_kohm,
    timing_cap_uF=design.timing_cap_uF,
    resistor_ohm=design.resistor_ohm,
    led_current_mA=design.led_current_mA,
    supply_voltage_V=design.supply_voltage_V,
    driver_quiescent_mA=design.driver_quiescent_mA,
    battery_capacity_mAh=design.battery_capacity_mAh,
    efficiency_factor=design.efficiency_factor,
    blink_frequency_hz=design.blink_frequency_hz,
    avg_current_mA=design.avg_current_mA,
    runtime_hours=design.runtime_hours,
    total_cost_usd=design.total_cost_usd,
    performance_penalty=design.performance_penalty
  );

  assert RequirementConstraints(
    blink_frequency_hz=design.blink_frequency_hz,
    led_current_mA=design.led_current_mA,
    runtime_hours=design.runtime_hours,
    supply_voltage_V=design.supply_voltage_V
  );

  assert ObjectiveCost(total_cost_usd=design.total_cost_usd);
  assert ObjectivePerformance(performance_penalty=design.performance_penalty);
  assert OptimizationObjectives();
}
