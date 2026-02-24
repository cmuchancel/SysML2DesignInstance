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
  public import RequirementsOnly::*;
  public import ScalarValues::*;

  part def Component {
    attribute mass_kg: Real;
    attribute volume_l: Real;
  }

  part def Sensor {
    attribute co2Range_ppm: Real = 5000.0;
    attribute pm25Range_max_ug_m3: Real = 500.0;
    attribute tempRange_max_C: Real = 60.0;
    attribute mass_kg: Real = 0.03;
    attribute volume_l: Real = 0.02;
  }

  part def Battery {
    attribute batteryCapacity_mAh: Real = 5000.0;
    attribute batteryRechargeable: Boolean = true;
    attribute nominalVoltage_V: Real = 7.4;
    attribute mass_kg: Real = 0.45;
    attribute volume_l: Real = 1.2;
  }

  part def MotorDrive {
    attribute motor_power_W: Real = 60.0;
    attribute motor_controller_efficiency_pct: Real = 85.0;
    attribute mass_kg: Real = 0.6;
    attribute volume_l: Real = 0.8;
  }

  part def MechanicalCam {
    attribute cam_angle_deg: Real = 180.0;
    attribute release_precision_deg: Real = 2.0;
    attribute mass_kg: Real = 0.4;
    attribute volume_l: Real = 0.6;
  }

  part def SpringArm {
    attribute spring_energy_J: Real = 25.0;
    attribute tossSpeed_m_s: Real = 6.0;
    attribute tossAngle_deg: Real = 45.0;
    attribute mass_kg: Real = 0.5;
    attribute volume_l: Real = 0.9;
  }

  part def Clutch {
    attribute clutch_release_repeatability_ms: Real = 10.0;
    attribute clutch_max_torque_Nm: Real = 3.0;
    attribute mass_kg: Real = 0.2;
    attribute volume_l: Real = 0.2;
  }

  part def HopperEscapement {
    attribute hopper_capacity_balls: Integer = 12;
    attribute feed_single_reliability_pct: Real = 99.0;
    attribute mass_kg: Real = 0.3;
    attribute volume_l: Real = 1.0;
  }

  part def Compute {
    attribute cpu_mhz: Real = 120.0;
    attribute firmware_storage_MB: Real = 4.0;
    attribute mass_kg: Real = 0.05;
    attribute volume_l: Real = 0.05;
  }

  part def UI {
    attribute displaySize_in: Real = 2.8;
    attribute buttons_count: Integer = 5;
    attribute emergency_stop_present: Boolean = true;
    attribute mass_kg: Real = 0.08;
    attribute volume_l: Real = 0.06;
  }

  part def Radio {
    attribute wifi_supported: Boolean = true;
    attribute bt_supported: Boolean = true;
    attribute antenna_gain_dBi: Real = 2.0;
    attribute mass_kg: Real = 0.02;
    attribute volume_l: Real = 0.02;
  }

  part def Storage {
    attribute log_capacity_cycles: Integer = 10000;
    attribute persistent_settings: Boolean = true;
    attribute mass_kg: Real = 0.01;
    attribute volume_l: Real = 0.01;
  }

  part def Enclosure {
    attribute ingress_protection_ip: Real = 54.0;
    attribute impact_rating_j: Real = 50.0;
    attribute one_handed_operable: Boolean = true;
    attribute mass_kg: Real = 1.2;
    attribute volume_l: Real = 3.0;
  }

  part def SoftTossMachine {
    attribute system_mass_kg: Real;
    attribute system_volume_l: Real;
    attribute target_price_usd: Real;

    part battery: Battery;
    part motor: MotorDrive;
    part cam: MechanicalCam;
    part springArm: SpringArm;
    part clutchMech: Clutch;
    part hopper: HopperEscapement;
    part compute: Compute;
    part ui: UI;
    part radio: Radio;
    part storage: Storage;
    part sensors: Sensor;
    part enclosure: Enclosure;
  }

  constraint def C_BatteryRuntime {
    in batteryCapacity_mAh: Real;
    in nominalVoltage_V: Real;
    in average_power_W: Real;
    batteryCapacity_mAh >= 4000.0
  }

  constraint def C_SensingCO2 {
    in co2Range_ppm: Real;
    co2Range_ppm >= 5000.0
  }

  constraint def C_SensingPM25 {
    in pm25Range_max_ug_m3: Real;
    pm25Range_max_ug_m3 >= 500.0
  }

  constraint def C_ConnectivityAvailability {
    in wifi_supported: Boolean;
    wifi_supported == true
  }

  constraint def C_PortabilityMass {
    in system_mass_kg: Real;
    system_mass_kg <= 10.0
  }

  constraint def C_TargetPrice {
    in target_price_usd: Real;
    target_price_usd <= 300.0
  }

}
