package RequirementsOnly {
  public import ScalarValues::*;
  requirement def RQ_001 {
    text = "Handheld form factor with maximum mass and maximum largest-dimension suitable for single-hand use.";
  }
  constraint def C_001 {
    in mass_g: Real;
    in max_dim_mm: Real;
    (mass_g <= 500.0) and (max_dim_mm <= 180.0)
  }
  requirement def RQ_002 {
    text = "PM2.5 sensing capability covering ambient concentrations up to 1000 ug/m3 with resolution and accuracy suitable for air quality monitoring.";
  }
  constraint def C_002 {
    in pm25_range_ugm3: Real;
    in pm25_resolution_ugm3: Real;
    in pm25_accuracy_percent: Real;
    (pm25_range_ugm3 >= 1000.0) and (pm25_resolution_ugm3 <= 1.0) and (pm25_accuracy_percent <= 15.0)
  }
  requirement def RQ_003 {
    text = "CO2 sensing capability covering indoor ranges up to 5000 ppm with specified resolution and accuracy.";
  }
  constraint def C_003 {
    in co2_range_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    (co2_range_ppm >= 5000.0) and (co2_accuracy_ppm <= 50.0) and (co2_resolution_ppm <= 1.0)
  }
  requirement def RQ_004 {
    text = "Temperature sensing across at least -10 to 50 C with defined accuracy and resolution.";
  }
  constraint def C_004 {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_accuracy_c: Real;
    in temp_resolution_c: Real;
    (temp_min_c <= -10.0) and (temp_max_c >= 50.0) and (temp_accuracy_c <= 0.5) and (temp_resolution_c <= 0.1)
  }
  requirement def RQ_005 {
    text = "Relative humidity sensing across 0 to 100 percent with specified accuracy and resolution.";
  }
  constraint def C_005 {
    in rh_min_percent: Real;
    in rh_max_percent: Real;
    in rh_accuracy_percent: Real;
    in rh_resolution_percent: Real;
    (rh_min_percent <= 0.0) and (rh_max_percent >= 100.0) and (rh_accuracy_percent <= 3.0) and (rh_resolution_percent <= 0.1)
  }
  requirement def RQ_006 {
    text = "Runtime of at least 8 hours on a rechargeable battery while wireless sync (Wi-Fi or Bluetooth) is active.";
  }
  constraint def C_006 {
    in runtime_hours: Real;
    in wireless_active: Boolean;
    (wireless_active == true) implies (runtime_hours >= 8.0)
  }
  requirement def RQ_007 {
    text = "Ability to sync data via Wi-Fi when Wi-Fi is enabled at practical transfer rates for periodic uploads.";
  }
  constraint def C_007 {
    in wifi_enabled: Boolean;
    in wifi_rate_mbps: Real;
    (wifi_enabled == true) implies (wifi_rate_mbps >= 1.0)
  }
  requirement def RQ_008 {
    text = "Ability to sync data via Bluetooth Low Energy (BLE) when Bluetooth is enabled with minimum protocol support and transfer rate.";
  }
  constraint def C_008 {
    in bluetooth_enabled: Boolean;
    in bt_version: Real;
    in bt_rate_kbps: Real;
    (bluetooth_enabled == true) implies ((bt_version >= 4.0) and (bt_rate_kbps >= 50.0))
  }
}

package ConceptDesign {
  public import ScalarValues::*;
  public import RequirementsOnly::*;

  part def Component {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
  }

  part def SensorModule {
    attribute pm25_range_ugm3: Real;
    attribute pm25_resolution_ugm3: Real;
    attribute pm25_accuracy_percent: Real;
    attribute co2_range_ppm: Real;
    attribute co2_resolution_ppm: Real;
    attribute co2_accuracy_ppm: Real;
    attribute temp_min_c: Real;
    attribute temp_max_c: Real;
    attribute temp_accuracy_c: Real;
    attribute temp_resolution_c: Real;
    attribute rh_min_percent: Real;
    attribute rh_max_percent: Real;
    attribute rh_accuracy_percent: Real;
    attribute rh_resolution_percent: Real;
  }

  part def ComputeModule {
    attribute mcu_power_W: Real;
    attribute sample_processing_mips: Real;
    attribute flash_MB: Real;
  }

  part def PowerModule {
    attribute batteryCapacity_mAh: Real;
    attribute battery_voltage_V: Real;
    attribute avg_system_draw_W: Real;
  }

  part def ConnectivityModule {
    attribute wifi_enabled: Boolean;
    attribute wifi_rate_mbps: Real;
    attribute ble_enabled: Boolean;
    attribute bt_version: Real;
    attribute bt_rate_kbps: Real;
  }

  part def StorageModule {
    attribute storage_MB: Real;
    attribute sd_present: Boolean;
  }

  part def UIModule {
    attribute display_in: Real;
    attribute has_leds: Boolean;
    attribute haptic: Boolean;
  }

  part def Enclosure {
    attribute mass_g: Real;
    attribute max_dim_mm: Real;
    attribute ingress_protection_rating: Real;
  }

  part def HandheldMonitor {
    part sensors: SensorModule {
      pm25_range_ugm3: Real;
      pm25_resolution_ugm3: Real;
      pm25_accuracy_percent: Real;
      co2_range_ppm: Real;
      co2_resolution_ppm: Real;
      co2_accuracy_ppm: Real;
      temp_min_c: Real;
      temp_max_c: Real;
      temp_accuracy_c: Real;
      temp_resolution_c: Real;
      rh_min_percent: Real;
      rh_max_percent: Real;
      rh_accuracy_percent: Real;
      rh_resolution_percent: Real;
    }
    part compute: ComputeModule {
      mcu_power_W: Real;
      sample_processing_mips: Real;
      flash_MB: Real;
    }
    part power: PowerModule {
      batteryCapacity_mAh: Real;
      battery_voltage_V: Real;
      avg_system_draw_W: Real;
    }
    part connectivity: ConnectivityModule {
      wifi_enabled: Boolean;
      wifi_rate_mbps: Real;
      ble_enabled: Boolean;
      bt_version: Real;
      bt_rate_kbps: Real;
    }
    part storage: StorageModule {
      storage_MB: Real;
      sd_present: Boolean;
    }
    part ui: UIModule {
      display_in: Real;
      has_leds: Boolean;
      haptic: Boolean;
    }
    part enclosure: Enclosure {
      mass_g: Real;
      max_dim_mm: Real;
      ingress_protection_rating: Real;
    }

    attribute estimated_runtime_hours: Real;
    attribute total_mass_g: Real;
    attribute largest_dimension_mm: Real;
  }

  constraint def C_runtime {
    in batteryCapacity_mAh: Real;
    in battery_voltage_V: Real;
    in avg_system_draw_W: Real;
    ((batteryCapacity_mAh * battery_voltage_V / 1000.0) / avg_system_draw_W) >= 8.0
  }

  constraint def C_pm25_spec {
    in pm25_range_ugm3: Real;
    in pm25_resolution_ugm3: Real;
    in pm25_accuracy_percent: Real;
    (pm25_range_ugm3 >= 1000.0)
  }

  constraint def C_co2_spec {
    in co2_range_ppm: Real;
    in co2_accuracy_ppm: Real;
    in co2_resolution_ppm: Real;
    (co2_range_ppm >= 5000.0)
  }

  constraint def C_temp_spec {
    in temp_min_c: Real;
    in temp_max_c: Real;
    in temp_accuracy_c: Real;
    in temp_resolution_c: Real;
    (temp_min_c <= -10.0)
  }

  constraint def C_rh_spec {
    in rh_min_percent: Real;
    in rh_max_percent: Real;
    in rh_accuracy_percent: Real;
    in rh_resolution_percent: Real;
    (rh_max_percent >= 100.0)
  }

  constraint def C_wifi_rate {
    in wifi_enabled: Boolean;
    in wifi_rate_mbps: Real;
    (wifi_rate_mbps >= 1.0)
  }

  constraint def C_bt_rate {
    in ble_enabled: Boolean;
    in bt_version: Real;
    in bt_rate_kbps: Real;
    (bt_version >= 4.0)
  }

  constraint def C_mass_limit {
    in total_mass_g: Real;
    (total_mass_g <= 500.0)
  }

  constraint def C_size_limit {
    in largest_dimension_mm: Real;
    (largest_dimension_mm <= 180.0)
  }

}
