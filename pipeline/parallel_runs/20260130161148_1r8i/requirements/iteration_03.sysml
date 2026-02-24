package RequirementsOnly
  public import ScalarValues::*

  requirement RQ_001
  {
    id = "RQ_001"
    text = "Device shall be handheld."
    kind = "Functional/Physical"
    priority = "High"

    // structured attributes
    formFactor = "handheld"           // string
    oneHandOperable = true            // boolean
    maxWeight_g : Rational            // numeric: maximum allowed weight in grams
    maxVolume_cc : Rational           // numeric: maximum allowed volume in cubic centimeters
  }

  constraint C_001
  {
    id = "C_001"
    text = "Handheld size/weight bounds for RQ_001."
    appliesTo = [ RQ_001 ]

    // numeric bounds (no units embedded in expressions to keep SysMLv2 text simple)
    maxWeight_g <= 700.0
    maxWeight_g_recommend <= 500.0

    maxVolume_cc <= 1500.0
    maxVolume_cc_recommend <= 1000.0

    verification = "inspection, measurement"
  }

  requirement RQ_002
  {
    id = "RQ_002"
    text = "Device shall measure particulate matter PM2.5."
    kind = "Functional/Sensor"
    priority = "High"

    measurand = "PM2.5"
    pm_range_min : Rational
    pm_range_max : Rational
    pm_resolution : Rational
    pm_accuracy_pct : Rational
    pm_samplingInterval_s : Rational
  }

  constraint C_002
  {
    id = "C_002"
    text = "PM2.5 measurement range, resolution, accuracy, sampling interval."
    appliesTo = [ RQ_002 ]

    // required numeric ranges (values are raw numbers; units described in text)
    pm_range_min = 0.0
    pm_range_max >= 1000.0    // must support at least 0..1000 (µg/m3)
    pm_range_max <= 5000.0    // upper allowed extension up to 5000

    pm_resolution >= 1.0
    pm_resolution <= 10.0     // resolution in µg/m3

    pm_accuracy_pct >= 5.0
    pm_accuracy_pct <= 30.0   // accuracy expressed as percent of reading/reference

    pm_samplingInterval_s >= 1.0
    pm_samplingInterval_s <= 600.0

    verification = "test, calibration"
  }

  requirement RQ_003
  {
    id = "RQ_003"
    text = "Device shall measure carbon dioxide (CO2) concentration."
    kind = "Functional/Sensor"
    priority = "High"

    co2_range_min : Rational
    co2_range_max : Rational
    co2_resolution_ppm : Rational
    co2_accuracy_ppm_min : Rational
    co2_accuracy_ppm_max : Rational
    co2_samplingInterval_s : Rational
  }

  constraint C_003
  {
    id = "C_003"
    text = "CO2 numeric bounds, resolution, accuracy, sampling interval."
    appliesTo = [ RQ_003 ]

    co2_range_min = 0.0
    co2_range_max >= 2000.0    // must cover at least 2000 ppm
    co2_range_max <= 50000.0   // optional extension up to 50000 ppm

    co2_resolution_ppm >= 1.0
    co2_resolution_ppm <= 10.0

    co2_accuracy_ppm_min = 20.0
    co2_accuracy_ppm_max = 100.0  // acceptable accuracy band in ppm

    co2_samplingInterval_s >= 1.0
    co2_samplingInterval_s <= 600.0

    verification = "test, calibration"
  }

  requirement RQ_004
  {
    id = "RQ_004"
    text = "Device shall measure ambient temperature."
    kind = "Functional/Sensor"
    priority = "High"

    temp_range_min : Rational
    temp_range_max : Rational
    temp_resolution_C : Rational
    temp_accuracy_C : Rational
    temp_samplingInterval_s : Rational
  }

  constraint C_004
  {
    id = "C_004"
    text = "Temperature numeric bounds, resolution, accuracy, sampling interval."
    appliesTo = [ RQ_004 ]

    // ranges (degrees Celsius)
    temp_range_min >= -40.0
    temp_range_min <= -20.0   // device must at least support -20; extended support to -40 allowed

    temp_range_max >= 50.0
    temp_range_max <= 85.0    // device must at least support 50; extended support to 85 allowed

    temp_resolution_C >= 0.1
    temp_resolution_C <= 1.0

    temp_accuracy_C >= 0.1
    temp_accuracy_C <= 2.0

    temp_samplingInterval_s >= 1.0
    temp_samplingInterval_s <= 600.0

    verification = "test, calibration"
  }

  requirement RQ_005
  {
    id = "RQ_005"
    text = "Device shall measure ambient relative humidity."
    kind = "Functional/Sensor"
    priority = "High"

    rh_range_min : Rational
    rh_range_max : Rational
    rh_resolution_pct : Rational
    rh_accuracy_pct : Rational
    rh_samplingInterval_s : Rational
  }

  constraint C_005
  {
    id = "C_005"
    text = "Relative humidity numeric bounds, resolution, accuracy, sampling interval."
    appliesTo = [ RQ_005 ]

    rh_range_min = 0.0
    rh_range_max >= 90.0
    rh_range_max <= 100.0

    rh_resolution_pct >= 0.1
    rh_resolution_pct <= 1.0

    rh_accuracy_pct >= 1.0
    rh_accuracy_pct <= 5.0

    rh_samplingInterval_s >= 1.0
    rh_samplingInterval_s <= 600.0

    verification = "test, calibration"
  }

  requirement RQ_006
  {
    id = "RQ_006"
    text = "Device shall operate for 8 hours on a single battery charge."
    kind = "Performance/Power"
    priority = "High"

    runtime_hours : Rational
    runtime_condition : String
    batteryRechargeable = true
  }

  constraint C_006
  {
    id = "C_006"
    text = "Runtime and conditions for 8-hour operation."
    appliesTo = [ RQ_006 ]

    runtime_hours = 8.0

    // runtime_condition must be declared for verification (examples provided in text)
    runtime_condition_options = { "continuous full-measurement mode", "typical measurement mode" }

    verification = "battery discharge test under declared runtime_condition"
  }

  requirement RQ_007
  {
    id = "RQ_007"
    text = "Device shall include a rechargeable battery."
    kind = "Functional/Power"
    priority = "High"

    rechargeable = true
    maxRechargeTime_h : Rational
    removable_option : Boolean
  }

  constraint C_007
  {
    id = "C_007"
    text = "Rechargeable battery recharge time and optional removability."
    appliesTo = [ RQ_007 ]

    rechargeable = true

    maxRechargeTime_h >= 0.5
    maxRechargeTime_h <= 8.0    // hours; target <= 8h, recommended <= 4h

    removable_option_in { true, false } // optional; if true, document interface

    verification = "inspection, test (measure recharge time)"
  }

  requirement RQ_008
  {
    id = "RQ_008"
    text = "Device shall sync data via Wi-Fi or Bluetooth."
    kind = "Interface/Connectivity"
    priority = "High"

    interfaces_supported : String[]        // list of interface names
    minThroughput_kbps : Rational
    encryptionSupported = true
    offlineBufferingRequired = true
  }

  constraint C_008
  {
    id = "C_008"
    text = "Connectivity, throughput, security, and buffering for RQ_008."
    appliesTo = [ RQ_008 ]

    // interfaces must include at least one of these names
    interfaces_must_include_in { "Wi-Fi", "Bluetooth" }

    minThroughput_kbps >= 10.0
    minThroughput_kbps <= 5000.0

    encryptionSupported = true
    offlineBufferingRequired = true

    verification = "connectivity tests, security inspection"
  }

  requirement RQ_009
  {
    id = "RQ_009"
    text = "Device shall locally buffer measurement data when wireless connectivity is unavailable."
    kind = "Functional/Storage"
    priority = "High"

    bufferCapacity_records : Integer
    retention_days : Rational
    nonvolatile = true
  }

  constraint C_009
  {
    id = "C_009"
    text = "Local buffering capacity, retention, and nonvolatility for RQ_009."
    appliesTo = [ RQ_009 ]

    bufferCapacity_records >= 24
    bufferCapacity_records <= 1000000  // records

    retention_days >= 1.0
    retention_days <= 365.0

    nonvolatile = true

    verification = "offline buffering tests, power cycle test"
  }

  requirement RQ_010
  {
    id = "RQ_010"
    text = "Device shall operate within specified ambient conditions."
    kind = "Environmental"
    priority = "High"

    operatingTemp_min_C : Rational
    operatingTemp_max_C : Rational
    storageTemp_min_C : Rational
    storageTemp_max_C : Rational
    operatingHumidity_min_pct : Rational
    operatingHumidity_max_pct : Rational
  }

  constraint C_010
  {
    id = "C_010"
    text = "Operating and storage temperature and humidity bounds for RQ_010."
    appliesTo = [ RQ_010 ]

    // typical handheld operating range
    operatingTemp_min_C >= -20.0
    operatingTemp_max_C <= 50.0

    // storage range
    storageTemp_min_C >= -40.0
    storageTemp_max_C <= 85.0

    // operating humidity (non-condensing)
    operatingHumidity_min_pct >= 0.0
    operatingHumidity_max_pct <= 95.0

    verification = "environmental chamber test"
  }

  requirement RQ_011
  {
    id = "RQ_011"
    text = "Device shall timestamp and format measurement data for transmission and storage."
    kind = "Functional/Data"
    priority = "Medium"

    timestampAccuracy_s : Rational
    data_format : String
    includeUnits = true
  }

  constraint C_011
  {
    id = "C_011"
    text = "Timestamp accuracy and data format constraints for RQ_011."
    appliesTo = [ RQ_011 ]

    timestampAccuracy_s >= 0.001
    timestampAccuracy_s <= 60.0    // seconds

    // acceptable data formats (at least one must be supported/declared)
    data_format_in { "JSON", "CSV", "Binary", "protobuf", "custom" }

    includeUnits = true

    verification = "inspection, data exchange test"
  }

end Package RequirementsOnly

Notes:
- All numeric fields use plain numeric literals (Rational) in this textual package; units and human-readable unit guidance are described in constraint text fields and comments.
- Each requirement (RQ_001..RQ_011) has a paired constraint (C_001..C_011) that declares explicit numeric bounds, boolean settings, or required options.
- Verification guidance is included in each constraint.verification string to support test planning.
- The model is intentionally design-agnostic: no vendor or part identifiers, no implementation-level constructs.