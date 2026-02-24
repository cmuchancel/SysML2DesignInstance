package RequirementsOnly {
  public import ScalarValues::*;

  requirement def RQ_001 {
    text = "Handheld form factor: device shall be suitable for single-person handheld transport and operation.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    (mass_kg <= 2.0)
  }

  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 to support air-quality-aware operation.";
  }
  constraint def C_002 {
    in pm25_accuracy_ug: Real;
    (pm25_accuracy_ug <= 5.0)
  }

  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration to inform indoor air conditions.";
  }
  constraint def C_003 {
    in co2_max_range_ppm: Real;
    (co2_max_range_ppm >= 2000.0)
  }

  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient temperature to support environmental awareness.";
  }
  constraint def C_004 {
    in temp_accuracy_C: Real;
    (temp_accuracy_C <= 0.5)
  }

  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure relative humidity to support environmental awareness.";
  }
  constraint def C_005 {
    in rh_accuracy_pct: Real;
    (rh_accuracy_pct <= 3.0)
  }

  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate on an internal rechargeable battery for typical session use.";
  }
  constraint def C_006 {
    in runtime_hours: Real; in wireless_on: Boolean;
    (runtime_hours >= 8.0) and (wireless_on == true)
  }

  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support wireless synchronization over Wi-Fi to exchange data with external systems.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    (wifi_supported == true)
  }

  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support wireless synchronization over Bluetooth to exchange data with external systems.";
  }
  constraint def C_008 {
    in bt_supported: Boolean;
    (bt_supported == true)
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Component {
    attribute mass_kg: Real;
    attribute notes: String;
  }

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute avg_power_W: Real;
    attribute supportsExternalPower: Boolean;
    attribute rechargeTime_hr: Real;
  }

  part def MechanicalLaunch {
    attribute camOptions_count: Integer;
    attribute armPreload_Nm: Real;
    attribute tossSpeed_mps: Real;
    attribute tossAngle_deg: Real;
    attribute tossHeight_m: Real;
    attribute reliability_cycles: Integer;
  }

  part def BallHandling {
    attribute hopperCapacity_balls: Integer;
    attribute singleBallGate: Boolean;
    attribute jamClearable_withoutTools: Boolean;
    attribute feed_rate_bpm: Real;
  }

  part def FeedEscapement {
    attribute escapementPrecision_ms: Real;
    attribute doubleFeedProbability_pct: Real;
  }

  part def AimingSubsystem {
    attribute adjustableAim_deg: Real;
    attribute repeatability_deg: Real;
    attribute alignmentStability_mm: Real;
  }

  part def TimingControl {
    attribute minInterval_s: Real;
    attribute maxInterval_s: Real;
    attribute adjustableDuringRun: Boolean;
    attribute cycle_rate_per_min: Real;
  }

  part def Electronics {
    attribute mcu_present: Boolean;
    attribute statusLED_count: Integer;
    attribute emergencyStop_present: Boolean;
    attribute controlInterface_simpleButtons: Boolean;
  }

  part def Connectivity {
    attribute wifi_supported: Boolean;
    attribute bt_supported: Boolean;
    attribute wirelessRange_m: Real;
  }

  part def Enclosure {
    attribute foldable: Boolean;
    attribute ingressProtection_IP: Integer;
    attribute impactTolerance_J: Real;
    attribute packedVolume_L: Real;
    attribute mass_kg: Real;
  }

  part def UserInterface {
    attribute display_present: Boolean;
    attribute displayLED_count: Integer;
    attribute physicalControls_count: Integer;
    attribute ergonomicHandles_present: Boolean;
  }

  part def TossboxSystem {
    part powerSubsystem: PowerSubsystem {
      batteryCapacity_mAh: Real;
      avg_power_W: Real;
      supportsExternalPower: Boolean;
      rechargeTime_hr: Real;
    }
    part mechanicalLaunch: MechanicalLaunch {
      camOptions_count: Integer;
      armPreload_Nm: Real;
      tossSpeed_mps: Real;
      tossAngle_deg: Real;
      tossHeight_m: Real;
      reliability_cycles: Integer;
    }
    part ballHandling: BallHandling {
      hopperCapacity_balls: Integer;
      singleBallGate: Boolean;
      jamClearable_withoutTools: Boolean;
      feed_rate_bpm: Real;
    }
    part feedEscapement: FeedEscapement {
      escapementPrecision_ms: Real;
      doubleFeedProbability_pct: Real;
    }
    part aiming: AimingSubsystem {
      adjustableAim_deg: Real;
      repeatability_deg: Real;
      alignmentStability_mm: Real;
    }
    part timingControl: TimingControl {
      minInterval_s: Real;
      maxInterval_s: Real;
      adjustableDuringRun: Boolean;
      cycle_rate_per_min: Real;
    }
    part electronics: Electronics {
      mcu_present: Boolean;
      statusLED_count: Integer;
      emergencyStop_present: Boolean;
      controlInterface_simpleButtons: Boolean;
    }
    part connectivity: Connectivity {
      wifi_supported: Boolean;
      bt_supported: Boolean;
      wirelessRange_m: Real;
    }
    part enclosure: Enclosure {
      foldable: Boolean;
      ingressProtection_IP: Integer;
      impactTolerance_J: Real;
      packedVolume_L: Real;
      mass_kg: Real;
    }
    part ui: UserInterface {
      display_present: Boolean;
      displayLED_count: Integer;
      physicalControls_count: Integer;
      ergonomicHandles_present: Boolean;
    }

    attribute target_cost_USD_min: Real;
    attribute target_cost_USD_max: Real;
    attribute service_life_cycles: Integer;
    attribute portable_singlePerson_mass_kg: Real;
  }

  constraint def C_runtime_budget {
    in batteryCapacity_mAh: Real;
    in avg_power_W: Real;
    in required_runtime_hours: Real;
    (batteryCapacity_mAh * 3.7 / 1000 / avg_power_W) >= required_runtime_hours
  }

  constraint def C_cycle_rate_min {
    in cycle_rate_per_min: Real;
    cycle_rate_per_min >= 6.0
  }

  constraint def C_toss_speed_min {
    in tossSpeed_mps: Real;
    in min_required_mps: Real;
    tossSpeed_mps >= min_required_mps
  }

  constraint def C_aiming_repeatability {
    in repeatability_deg: Real;
    repeatability_deg <= 2.0
  }

  constraint def C_double_feed_risk {
    in doubleFeedProbability_pct: Real;
    doubleFeedProbability_pct <= 1.0
  }

  constraint def C_connectivity_wifi {
    in wifi_supported: Boolean;
    wifi_supported == true
  }

  constraint def C_portability_mass {
    in enclosure_mass_kg: Real;
    enclosure_mass_kg <= 10.0
  }

  constraint def C_ingress_protection {
    in ingressProtection_IP: Integer;
    ingressProtection_IP >= 4
  }

  constraint def C_emergency_stop_present {
    in emergencyStop_present: Boolean;
    emergencyStop_present == true
  }

}
