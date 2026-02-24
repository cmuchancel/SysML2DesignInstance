package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be suitable for single-person hand carry and one-handed operation.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in volume_l: Real;
    in one_handed_operable: Boolean;
    ((mass_kg <= 1.5) and (volume_l <= 4.0) and (one_handed_operable == true))
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 for environmental-awareness during use.";
  }
  constraint def C_002 {
    in pm25_range_min_ug_m3: Real;
    in pm25_range_max_ug_m3: Real;
    in pm25_accuracy_ug_m3: Real;
    in pm25_resolution_ug_m3: Real;
    ((pm25_range_min_ug_m3 <= 0.0) and (pm25_range_max_ug_m3 >= 500.0) and (pm25_accuracy_ug_m3 <= 10.0) and (pm25_resolution_ug_m3 <= 1.0))
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall report ambient CO2 concentration to indicate ventilation conditions during practice.";
  }
  constraint def C_003 {
    in co2_range_min_ppm: Real;
    in co2_range_max_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    ((co2_range_min_ppm <= 400.0) and (co2_range_max_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0))
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature to support environmental monitoring during use.";
  }
  constraint def C_004 {
    in temp_range_min_C: Real;
    in temp_range_max_C: Real;
    in temp_accuracy_C: Real;
    in temp_resolution_C: Real;
    ((temp_range_min_C <= -10.0) and (temp_range_max_C >= 50.0) and (temp_accuracy_C <= 1.0) and (temp_resolution_C <= 0.1))
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity to support environmental monitoring during use.";
  }
  constraint def C_005 {
    in rh_range_min_pct: Real;
    in rh_range_max_pct: Real;
    in rh_accuracy_pct: Real;
    in rh_resolution_pct: Real;
    ((rh_range_min_pct <= 0.0) and (rh_range_max_pct >= 95.0) and (rh_accuracy_pct <= 3.0) and (rh_resolution_pct <= 1.0))
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for a full practice interval on internal rechargeable battery while wireless sync may be active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    in battery_rechargeable: Boolean;
    ((wireless_on == true) implies (runtime_hours >= 4.0)) and (battery_rechargeable == true)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization of measured environmental data via Wi-Fi or equivalent networked sync.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bt_supported: Boolean;
    ((wifi_supported == true) or (bt_supported == true))
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization of measured environmental data via Bluetooth or equivalent local sync.";
  }
  constraint def C_008 {
    in bt_supported: Boolean;
    in wifi_supported: Boolean;
    ((bt_supported == true) or (wifi_supported == true))
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Component {
  }

  part def PneumaticSubsystem {
    attribute airAccumulator_L: Real;
    attribute maxPressure_psi: Real;
    attribute shotPressure_psi: Real;
    attribute compressorDuty_pct: Real;
  }

  part def MagazineSubsystem {
    attribute capacity_count: Integer;
    attribute indexTime_s: Real;
    attribute doubleFeedMitigation: Boolean;
  }

  part def DeliverySubsystem {
    attribute plungerStroke_mm: Real;
    attribute plungerPad_compliance_Nmm: Real;
    attribute guideLength_mm: Real;
    attribute tossSpeed_mps: Real;
  }

  part def SensorSuite {
    attribute pressureSensor_available: Boolean;
    attribute pressureSensor_range_psi: Real;
    attribute speedSensor_available: Boolean;
    attribute jamDetect_available: Boolean;
  }

  part def ControlSubsystem {
    attribute controllerCPU_MHz: Real;
    attribute controlLoopHz: Real;
    attribute safetyEStop_available: Boolean;
    attribute autonomousVariationModes: Integer;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute batteryVoltage_V: Real;
    attribute externalPower_supported: Boolean;
    attribute avgDraw_mA_idle: Real;
    attribute avgDraw_mA_active: Real;
  }

  part def ConnectivitySubsystem {
    attribute wifi_supported: Boolean;
    attribute wifi_band_ghz: Real;
    attribute bt_supported: Boolean;
    attribute ota_update_capable: Boolean;
  }

  part def StorageSubsystem {
    attribute configFlash_MB: Real;
    attribute logfileBuffer_MB: Real;
  }

  part def UserInterface {
    attribute uiDisplay_in: Real;
    attribute tactileButtons_count: Integer;
    attribute tabletControlCompatible: Boolean;
  }

  part def Enclosure {
    attribute mass_kg: Real;
    attribute footprint_L: Real;
    attribute ingressIP: Real;
    attribute impactResistance_J: Real;
    attribute hasHandles: Boolean;
  }

  part def TosserMachine {
    part pneumatic: PneumaticSubsystem {
      attribute airAccumulator_L: Real;
      attribute maxPressure_psi: Real;
      attribute shotPressure_psi: Real;
    }
    part magazine: MagazineSubsystem {
      attribute capacity_count: Integer;
      attribute indexTime_s: Real;
      attribute doubleFeedMitigation: Boolean;
    }
    part delivery: DeliverySubsystem {
      attribute plungerStroke_mm: Real;
      attribute plungerPad_compliance_Nmm: Real;
      attribute tossSpeed_mps: Real;
      attribute guideLength_mm: Real;
    }
    part sensors: SensorSuite {
      attribute pressureSensor_available: Boolean;
      attribute pressureSensor_range_psi: Real;
      attribute speedSensor_available: Boolean;
      attribute jamDetect_available: Boolean;
    }
    part control: ControlSubsystem {
      attribute controllerCPU_MHz: Real;
      attribute controlLoopHz: Real;
      attribute safetyEStop_available: Boolean;
      attribute autonomousVariationModes: Integer;
    }
    part power: PowerSubsystem {
      attribute batteryCapacity_mAh: Real;
      attribute batteryVoltage_V: Real;
      attribute externalPower_supported: Boolean;
      attribute avgDraw_mA_idle: Real;
      attribute avgDraw_mA_active: Real;
    }
    part comms: ConnectivitySubsystem {
      attribute wifi_supported: Boolean;
      attribute wifi_band_ghz: Real;
      attribute bt_supported: Boolean;
      attribute ota_update_capable: Boolean;
    }
    part storage: StorageSubsystem {
      attribute configFlash_MB: Real;
      attribute logfileBuffer_MB: Real;
    }
    part ui: UserInterface {
      attribute uiDisplay_in: Real;
      attribute tactileButtons_count: Integer;
      attribute tabletControlCompatible: Boolean;
    }
    part enclosure: Enclosure {
      attribute mass_kg: Real;
      attribute footprint_L: Real;
      attribute ingressIP: Real;
      attribute impactResistance_J: Real;
      attribute hasHandles: Boolean;
    }
  }

  constraint def C_runtime_budget {
    in power_battery_mAh: Real;
    in expected_active_draw_mA: Real;
    in required_hours: Real;
    power_battery_mAh >= 2000.0
  }

  constraint def C_pressure_operating_range {
    in pneumatic_maxPressure_psi: Real;
    in pneumatic_shotPressure_psi: Real;
    pneumatic_maxPressure_psi >= 40.0
  }

  constraint def C_toss_throughput {
    in delivery_tossSpeed_mps: Real;
    in magazine_indexTime_s: Real;
    in cycle_interval_s: Real;
    cycle_interval_s <= 6.0
  }

  constraint def C_connectivity_available {
    in comms_wifi_supported: Boolean;
    comms_wifi_supported == true
  }

  constraint def C_portability_size {
    in enclosure_mass_kg: Real;
    in enclosure_footprint_L: Real;
    enclosure_mass_kg <= 12.0
  }

  constraint def C_sensing_pressure_resolution {
    in sensors_pressureSensor_available: Boolean;
    in sensors_pressureSensor_range_psi: Real;
    sensors_pressureSensor_range_psi >= 0.0
  }
}
