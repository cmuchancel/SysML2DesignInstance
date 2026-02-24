package ConceptValidation_1_ne555_astable {
    part def Candidate {
        attribute timing_resistor_kohm = 20.0;
        attribute timing_cap_uF = 7.0;
        attribute resistor_ohm = 330.0;
        attribute led_current_mA = 12.0;
        attribute supply_voltage_V = 5.0;
        attribute driver_quiescent_mA = 2.0;
        attribute battery_capacity_mAh = 1000.0;
        attribute efficiency_factor = 0.85;
        attribute selected_slots = 0.0;
        attribute total_slots = 0.0;

        assert constraint freqInRange {
            (1.44e3 / (timing_resistor_kohm * timing_cap_uF)) >= 9.5 and
            (1.44e3 / (timing_resistor_kohm * timing_cap_uF)) <= 10.5
        }
        assert constraint currentInRange {
            led_current_mA >= 8 and led_current_mA <= 20
        }
        assert constraint runtimeMin {
            (battery_capacity_mAh / (driver_quiescent_mA + 0.5 * led_current_mA)) >= 8
        }
        assert constraint supplyInRange {
            supply_voltage_V >= 4.75 and supply_voltage_V <= 5.25
        }
        assert constraint partsAvailable {
            selected_slots > 0
        }
    }

    part candidate_1 : Candidate {
        attribute timing_resistor_kohm redefines timing_resistor_kohm = 8.54796017;
        attribute timing_cap_uF redefines timing_cap_uF = 17.49739755;
        attribute resistor_ohm redefines resistor_ohm = 607.31290083;
        attribute led_current_mA redefines led_current_mA = 13.43623983;
        attribute supply_voltage_V redefines supply_voltage_V = 4.87324082;
        attribute driver_quiescent_mA redefines driver_quiescent_mA = 6.78272412;
        attribute battery_capacity_mAh redefines battery_capacity_mAh = 881.30261734;
        attribute efficiency_factor redefines efficiency_factor = 0.83369315;
        attribute selected_slots redefines selected_slots = 0;
        attribute total_slots redefines total_slots = 4;
    }
}
