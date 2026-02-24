package RequirementsOnly {
  private import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor: device shall be portable for single-person transport with mass <= 3.0 kg and maximum envelope volume <= 8.0 liters.";
  }
  constraint def C_001 {
    in mass_kg: Real;
    in volume_liters: Real;
    (mass_kg <= 3.0) and (volume_liters <= 8.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing: device shall measure particulate matter PM2.5 concentration in ambient air for basic environmental awareness during use.";
  }
  constraint def C_002 {
    in pm25_supported: Boolean;
    in pm25_range_ugm3_min: Real;
    in pm25_range_ugm3_max: Real;
    pm25_supported and (pm25_range_ugm3_min <= 0.0 and pm25_range_ugm3_max >= 500.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing: device shall measure ambient CO2 concentration to identify elevated indoor levels affecting user comfort.";
  }
  constraint def C_003 {
    in co2_supported: Boolean;
    in co2_range_ppm_min: Real;
    in co2_range_ppm_max: Real;
    co2_supported and (co2_range_ppm_min <= 400.0 and co2_range_ppm_max >= 5000.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing: device shall measure ambient air temperature for environmental context during practice.";
  }
  constraint def C_004 {
    in temp_supported: Boolean;
    in temp_range_C_min: Real;
    in temp_range_C_max: Real;
    temp_supported and (temp_range_C_min <= -10.0 and temp_range_C_max >= 50.0)
  }
  requirement def RQ_005 {
    text = "Humidity sensing: device shall measure ambient relative humidity for environmental context during practice.";
  }
  constraint def C_005 {
    in rh_supported: Boolean;
    in rh_range_percent_min: Real;
    in rh_range_percent_max: Real;
    rh_supported and (rh_range_percent_min <= 0.0 and rh_range_percent_max >= 100.0)
  }
  requirement def RQ_006 {
    text = "Runtime on rechargeable battery: device shall operate for at least 6.0 hours with wireless radios active under typical practice load.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_on: Boolean;
    wireless_on and (runtime_hours >= 6.0)
  }
  requirement def RQ_007 {
    text = "Wi-Fi sync: device shall support Wi-Fi synchronization capability to external devices or services for practice session data exchange or control.";
  }
  constraint def C_007 {
    in wifi_supported: Boolean;
    in bluetooth_supported: Boolean;
    wifi_supported or bluetooth_supported
  }
  requirement def RQ_008 {
    text = "Bluetooth sync: device shall support Bluetooth Low Energy synchronization capability to external devices for local control or data exchange.";
  }
  constraint def C_008 {
    in bluetooth_supported: Boolean;
    in wifi_supported: Boolean;
    bluetooth_supported or wifi_supported
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def PowerSubsystem {
    attribute batteryCapacity_mAh: Real;
    attribute avgPower_W: Real;
    attribute charger_present: Boolean;
    attribute runtime_hours: Real;
  }

  part def ComputeSubsystem {
    attribute cpu_Perf_DMIPS: Real;
    attribute firmwareFlash_MB: Real;
    attribute watchdog_present: Boolean;
  }

  part def ConnectivitySubsystem {
    attribute wifi_supported: Boolean;
    attribute bluetooth_supported: Boolean;
    attribute connectivity_availability_percent: Real;
  }

  part def StorageSubsystem {
    attribute logCapacity_MB: Real;
    attribute sd_present: Boolean;
  }

  part def UISubsystem {
    attribute displaySize_in: Real;
    attribute has_buttons: Boolean;
    attribute eStop_present: Boolean;
    attribute feedback_leds: Boolean;
  }

  part def EnclosureSubsystem {
    attribute mass_kg: Real;
    attribute volume_liters: Real;
    attribute ingress_protection_IPx: Real;
    attribute impact_resistance_J: Real;
  }

  part def SensingSubsystem {
    attribute pm25_supported: Boolean;
    attribute pm25_range_ugm3_min: Real;
    attribute pm25_range_ugm3_max: Real;
    attribute co2_supported: Boolean;
    attribute co2_range_ppm_min: Real;
    attribute co2_range_ppm_max: Real;
    attribute temp_supported: Boolean;
    attribute temp_range_C_min: Real;
    attribute temp_range_C_max: Real;
    attribute rh_supported: Boolean;
    attribute rh_range_percent_min: Real;
    attribute rh_range_percent_max: Real;
  }

  part def BallStorageSubsystem {
    attribute hopper_capacity_balls: Integer;
    attribute anti_double_feed: Boolean;
    attribute ball_diameter_mm: Real;
  }

  part def BallFeedSubsystem {
    attribute escapement_cycle_ms: Real;
    attribute feed_consistency_score: Real;
    attribute jam_detection_present: Boolean;
  }

  part def BallDeliverySubsystem {
    attribute cam_radius_mm: Real;
    attribute spring_preload_Nm: Real;
    attribute release_angle_deg: Real;
    attribute toss_speed_mps: Real;
    attribute toss_speed_range_mps: Real;
    attribute useful_distance_m: Real;
  }

  part def AimingSubsystem {
    attribute yaw_range_deg: Real;
    attribute pitch_range_deg: Real;
    attribute repeatability_deg: Real;
    attribute aiming_resolution_deg: Real;
  }

  part def TimingControlSubsystem {
    attribute min_interval_s: Real;
    attribute max_interval_s: Real;
    attribute adjustable_during_run: Boolean;
    attribute cadence_repeatability_ms: Real;
  }

  part def SafetySubsystem {
    attribute emergency_stop_response_ms: Real;
    attribute guarding_present: Boolean;
    attribute safe_fault_state_defined: Boolean;
  }

  part def StructureSubsystem {
    attribute footprint_area_m2: Real;
    attribute foldable_for_transport: Boolean;
    attribute carry_handle_present: Boolean;
  }

  part def System {
    part power: PowerSubsystem {
      attribute batteryCapacity_mAh: Real;
      attribute avgPower_W: Real;
      attribute runtime_hours: Real;
    }
    part compute: ComputeSubsystem {
      attribute cpu_Perf_DMIPS: Real;
      attribute firmwareFlash_MB: Real;
    }
    part connectivity: ConnectivitySubsystem {
      attribute wifi_supported: Boolean;
      attribute bluetooth_supported: Boolean;
      attribute connectivity_availability_percent: Real;
    }
    part storage: StorageSubsystem {
      attribute logCapacity_MB: Real;
      attribute sd_present: Boolean;
    }
    part ui: UISubsystem {
      attribute displaySize_in: Real;
      attribute has_buttons: Boolean;
      attribute eStop_present: Boolean;
    }
    part enclosure: EnclosureSubsystem {
      attribute mass_kg: Real;
      attribute volume_liters: Real;
      attribute ingress_protection_IPx: Real;
      attribute impact_resistance_J: Real;
    }
    part sensing: SensingSubsystem {
      attribute pm25_supported: Boolean;
      attribute pm25_range_ugm3_min: Real;
      attribute pm25_range_ugm3_max: Real;
      attribute co2_supported: Boolean;
      attribute co2_range_ppm_min: Real;
      attribute co2_range_ppm_max: Real;
    }
    part storageBalls: BallStorageSubsystem {
      attribute hopper_capacity_balls: Integer;
      attribute anti_double_feed: Boolean;
      attribute ball_diameter_mm: Real;
    }
    part feed: BallFeedSubsystem {
      attribute escapement_cycle_ms: Real;
      attribute feed_consistency_score: Real;
      attribute jam_detection_present: Boolean;
    }
    part delivery: BallDeliverySubsystem {
      attribute cam_radius_mm: Real;
      attribute spring_preload_Nm: Real;
      attribute release_angle_deg: Real;
      attribute toss_speed_mps: Real;
      attribute useful_distance_m: Real;
    }
    part aiming: AimingSubsystem {
      attribute yaw_range_deg: Real;
      attribute pitch_range_deg: Real;
      attribute repeatability_deg: Real;
    }
    part timing: TimingControlSubsystem {
      attribute min_interval_s: Real;
      attribute max_interval_s: Real;
      attribute adjustable_during_run: Boolean;
    }
    part safety: SafetySubsystem {
      attribute emergency_stop_response_ms: Real;
      attribute guarding_present: Boolean;
      attribute safe_fault_state_defined: Boolean;
    }
    part structure: StructureSubsystem {
      attribute foldable_for_transport: Boolean;
      attribute carry_handle_present: Boolean;
    }
    attribute target_price_usd_min: Real;
    attribute target_price_usd_max: Real;
  }

  constraint def C_runtime {
    in power: PowerSubsystem;
    in runtime_hours: Real;
    runtime_hours >= 6.0
  }

  constraint def C_sensing_co2_range {
    in sensing: SensingSubsystem;
    in co2_max_ppm: Real;
    co2_max_ppm >= 5000.0
  }

  constraint def C_connectivity_required {
    in connectivity: ConnectivitySubsystem;
    in wifi_req: Boolean;
    wifi_req == true
  }

  constraint def C_portability_mass {
    in enclosure: EnclosureSubsystem;
    in mass_kg: Real;
    mass_kg <= 3.0
  }

  constraint def C_portability_volume {
    in enclosure: EnclosureSubsystem;
    in volume_liters: Real;
    volume_liters <= 8.0
  }

  constraint def C_target_price {
    in System: System;
    in price_usd: Real;
    price_usd <= 300.0
  }

  constraint def C_repeatability_toss {
    in delivery: BallDeliverySubsystem;
    in repeatability_deg: Real;
    repeatability_deg <= 2.0
  }

  constraint def C_feed_single_ball {
    in feed: BallFeedSubsystem;
    in anti_double_feed: Boolean;
    anti_double_feed == true
  }

}
