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

  part def SoftTossPod {
    attribute mass_kg: Real;
    attribute footprint_cm2: Real;
    part reservoir: PneumaticReservoir;
    part pump: Pump;
    part valve: LaunchValve;
    part feed: FeedMechanism;
    part nozzle: NozzleAssembly;
    part sensors: SensorSuite;
    part control: ControlUnit;
    part power: PowerSystem;
    part ui: UserInterface;
    part enclosure: Enclosure;
    attribute max_operating_pressure_psi: Real;
    attribute typical_cycle_rate_tpm: Real;
    attribute stowed_volume_L: Real;
  }

  part def PneumaticReservoir {
    attribute nominal_volume_L: Real;
    attribute max_pressure_psi: Real;
    attribute leak_rate_L_per_hr: Real;
    attribute pressure_sensor_installed: Boolean;
    attribute valve_interface_ms: Real;
    attribute reservoir_mass_kg: Real;
  }

  part def Pump {
    attribute manual_handpump: Boolean;
    attribute motorized: Boolean;
    attribute charge_time_min: Real;
    attribute power_draw_W: Real;
    attribute supported_pressure_psi: Real;
  }

  part def LaunchValve {
    attribute valve_type: String;
    attribute valve_pulse_ms: Real;
    attribute seat_reliability_cycles: Real;
    attribute actuator_power_W: Real;
    attribute effective_flow_LPM: Real;
  }

  part def NozzleAssembly {
    attribute nozzle_angle_deg: Real;
    attribute lateral_swivel_deg: Real;
    attribute effective_exit_diameter_mm: Real;
    attribute aim_stability_mm: Real;
    attribute enclosure_mount_mass_kg: Real;
  }

  part def FeedMechanism {
    attribute single_feed_pocket: Boolean;
    attribute anti_double_feed_gate: Boolean;
    attribute jam_clear_access: Boolean;
    attribute feed_cycle_time_ms: Real;
    attribute ball_capacity: Integer;
  }

  part def SensorSuite {
    attribute pressure_sensor_range_psi: Real;
    attribute flow_sensor_LPM: Real;
    attribute position_sensor_present: Boolean;
    attribute imu_present: Boolean;
    attribute sensor_sample_rate_Hz: Real;
  }

  part def ControlUnit {
    attribute mcu_flash_MB: Real;
    attribute control_loop_latency_ms: Real;
    attribute toss_variation_modes: Integer;
    attribute emergency_stop_input_present: Boolean;
    attribute fault_detection_enabled: Boolean;
  }

  part def PowerSystem {
    attribute batteryCapacity_mAh: Real;
    attribute battery_voltage_V: Real;
    attribute avg_power_W: Real;
    attribute supports_external_power: Boolean;
    attribute protection_ip_rating: String;
  }

  part def UserInterface {
    attribute displaySize_in: Real;
    attribute physical_buttons: Integer;
    attribute indicators_rgb: Boolean;
    attribute tactile_emergency_stop: Boolean;
  }

  part def Enclosure {
    attribute ingress_protection_ip: String;
    attribute impact_resistance_J: Real;
    attribute material: String;
    attribute carry_handle_present: Boolean;
    attribute stowed_dimensions_cm3: Real;
  }

  constraint def C_runtime_budget {
    in batteryCapacity_mAh: Real;
    in avg_power_W: Real;
    ( (batteryCapacity_mAh * 3.7 / 1000) / avg_power_W ) >= 3.0
  }

  constraint def C_pressure_sensor_range {
    in pressure_sensor_range_psi: Real;
    (pressure_sensor_range_psi >= 60.0)
  }

  constraint def C_connectivity_avail {
    in wifi_supported: Boolean;
    (wifi_supported == true)
  }

  constraint def C_cycle_rate {
    in typical_cycle_rate_tpm: Real;
    (typical_cycle_rate_tpm >= 12.0)
  }

  constraint def C_mass_portability {
    in SoftTossPod_mass_kg: Real;
    (SoftTossPod_mass_kg <= 12.0)
  }

  constraint def C_nozzle_angle_limit {
    in nozzle_angle_deg: Real;
    (nozzle_angle_deg <= 60.0)
  }

  constraint def C_feed_reliability {
    in feed_cycle_time_ms: Real;
    (feed_cycle_time_ms <= 2000.0)
  }

  constraint def C_pressure_leak {
    in leak_rate_L_per_hr: Real;
    (leak_rate_L_per_hr <= 0.5)
  }

  constraint def C_control_latency {
    in control_loop_latency_ms: Real;
    (control_loop_latency_ms <= 50.0)
  }

  constraint def C_enclosure_ip {
    in ingress_protection_ip: String;
    (ingress_protection_ip == "IP54")
  }

  constraint def C_valve_flow_min {
    in effective_flow_LPM: Real;
    (effective_flow_LPM >= 15.0)
  }

  constraint def C_aim_stability {
    in aim_stability_mm: Real;
    (aim_stability_mm <= 150.0)
  }

  constraint def C_stow_volume {
    in stowed_dimensions_cm3: Real;
    (stowed_dimensions_cm3 <= 40000.0)
  }

  constraint def C_emergency_stop {
    in emergency_stop_input_present: Boolean;
    (emergency_stop_input_present == true)
  }

  constraint def C_fault_detection {
    in fault_detection_enabled: Boolean;
    (fault_detection_enabled == true)
  }

  constraint def C_external_power {
    in supports_external_power: Boolean;
    (supports_external_power == true)
  }

  constraint def C_sensor_sample_rate {
    in sensor_sample_rate_Hz: Real;
    (sensor_sample_rate_Hz >= 50.0)
  }

  constraint def C_pressure_capacity {
    in max_pressure_psi: Real;
    (max_pressure_psi >= 80.0)
  }

  constraint def C_battery_mass_trade {
    in batteryCapacity_mAh: Real;
    in SoftTossPod_mass_kg: Real;
    (SoftTossPod_mass_kg <= 12.0)
  }
}
