package RequirementsOnly
import public ScalarValues::*

/*
Concise, design-agnostic SysMLv2 requirements package for a handheld environmental monitor.
Each atomic natural-language clause is decomposed into a requirement (RQ_xxx) with structured
properties and at least one associated constraint (C_xxx) that gives numeric/boolean/string bounds.
No concrete parts or vendors referenced.
*/

/* RQ_001 - Handheld form factor */
requirement def RQ_001
{
    id = "RQ_001"
    text = "Device shall be handheld."
    rationale = "User portability and one-handed operation."
    type = "Functional/Physical"
    priority = "High"
    verifMethod = "Inspection, Measurement"
    attributes =
    {
        formFactor : String[1] = "handheld"
        maxWeight_g : Real[1]  -- see C_001
        maxVolume_cc : Real[1] -- see C_001
        oneHandOperable : Boolean[1] = true
    }
}
constraint def C_001
{
    id = "C_001"
    text = "Handheld size/weight bounds."
    appliesTo = [ RQ_001 ]
    expression = {
        RQ_001.attributes.maxWeight_g >= 0.0 and RQ_001.attributes.maxWeight_g <= 700.0
        and RQ_001.attributes.maxVolume_cc >= 0.0 and RQ_001.attributes.maxVolume_cc <= 1500.0
    }
    notes = "Weight <=700 g and volume <=1500 cc to ensure handheld usability; values adjustable by verification."
}

/* RQ_002 - PM2.5 measurement capability */
requirement def RQ_002
{
    id = "RQ_002"
    text = "Device shall measure particulate matter PM2.5."
    rationale = "Air quality monitoring."
    type = "Functional/Sensor"
    priority = "High"
    verifMethod = "Test, Calibration"
    attributes =
    {
        measurand : String[1] = "PM2.5"
        range_ug_m3 : Real[2]  -- min, max (see C_002)
        resolution_ug_m3 : Real[1] -- see C_002
        accuracy_percent : Real[1] -- see C_002
        samplingInterval_s : Real[1] -- see C_002
    }
}
constraint def C_002
{
    id = "C_002"
    text = "PM2.5 numeric bounds, resolution, accuracy, and sampling."
    appliesTo = [ RQ_002 ]
    expression = {
        RQ_002.attributes.range_ug_m3[1] = 0.0
        and RQ_002.attributes.range_ug_m3[2] >= 1000.0 and RQ_002.attributes.range_ug_m3[2] <= 5000.0
        and RQ_002.attributes.resolution_ug_m3 >= 1.0 and RQ_002.attributes.resolution_ug_m3 <= 10.0
        and RQ_002.attributes.accuracy_percent >= 5.0 and RQ_002.attributes.accuracy_percent <= 30.0
        and RQ_002.attributes.samplingInterval_s >= 1.0 and RQ_002.attributes.samplingInterval_s <= 600.0
    }
    notes = "Range minimum 0 µg/m3; upper bound typical 1000–5000 µg/m3 to cover extreme events. Resolution 1–10 µg/m3. Accuracy expressed as percent of reading or reference. Sampling interval 1–600 s."
}

/* RQ_003 - CO2 measurement capability */
requirement def RQ_003
{
    id = "RQ_003"
    text = "Device shall measure carbon dioxide (CO2) concentration."
    rationale = "Indoor air quality indicator."
    type = "Functional/Sensor"
    priority = "High"
    verifMethod = "Test, Calibration"
    attributes =
    {
        measurand : String[1] = "CO2"
        range_ppm : Real[2] -- min, max (see C_003)
        resolution_ppm : Real[1] -- see C_003
        accuracy_ppm : Real[1] -- see C_003
        samplingInterval_s : Real[1] -- see C_003
    }
}
constraint def C_003
{
    id = "C_003"
    text = "CO2 numeric bounds, resolution, accuracy, and sampling."
    appliesTo = [ RQ_003 ]
    expression = {
        RQ_003.attributes.range_ppm[1] = 0.0
        and RQ_003.attributes.range_ppm[2] >= 2000.0 and RQ_003.attributes.range_ppm[2] <= 50000.0
        and RQ_003.attributes.resolution_ppm >= 1.0 and RQ_003.attributes.resolution_ppm <= 10.0
        and RQ_003.attributes.accuracy_ppm >= 20.0 and RQ_003.attributes.accuracy_ppm <= 100.0
        and RQ_003.attributes.samplingInterval_s >= 1.0 and RQ_003.attributes.samplingInterval_s <= 600.0
    }
    notes = "Range up to at least 2000–50000 ppm to include crowded/industrial conditions. Accuracy given in ppm; resolution 1–10 ppm."
}

/* RQ_004 - Temperature measurement capability */
requirement def RQ_004
{
    id = "RQ_004"
    text = "Device shall measure ambient temperature."
    rationale = "Environmental context for other sensors."
    type = "Functional/Sensor"
    priority = "High"
    verifMethod = "Test, Calibration"
    attributes =
    {
        measurand : String[1] = "Temperature"
        range_C : Real[2] -- min, max (see C_004)
        resolution_C : Real[1] -- see C_004
        accuracy_C : Real[1] -- see C_004
        samplingInterval_s : Real[1] -- see C_004
    }
}
constraint def C_004
{
    id = "C_004"
    text = "Temperature numeric bounds, resolution, accuracy, and sampling."
    appliesTo = [ RQ_004 ]
    expression = {
        RQ_004.attributes.range_C[1] <= -20.0 and RQ_004.attributes.range_C[1] >= -40.0
        and RQ_004.attributes.range_C[2] >= 50.0 and RQ_004.attributes.range_C[2] <= 85.0
        and RQ_004.attributes.resolution_C <= 1.0 and RQ_004.attributes.resolution_C >= 0.1
        and RQ_004.attributes.accuracy_C <= 2.0 and RQ_004.attributes.accuracy_C >= 0.1
        and RQ_004.attributes.samplingInterval_s >= 1.0 and RQ_004.attributes.samplingInterval_s <= 600.0
    }
    notes = "Operating measurement span typically -20 to 50 °C; allow extended min -40 °C and max up to 85 °C. Resolution 0.1–1.0 °C; accuracy 0.1–2.0 °C."
}

/* RQ_005 - Relative humidity measurement capability */
requirement def RQ_005
{
    id = "RQ_005"
    text = "Device shall measure ambient relative humidity."
    rationale = "Environmental context and comfort metrics."
    type = "Functional/Sensor"
    priority = "High"
    verifMethod = "Test, Calibration"
    attributes =
    {
        measurand : String[1] = "Relative Humidity"
        range_pct : Real[2] -- min, max (see C_005)
        resolution_pct : Real[1] -- see C_005
        accuracy_pct : Real[1] -- see C_005
        samplingInterval_s : Real[1] -- see C_005
    }
}
constraint def C_005
{
    id = "C_005"
    text = "Relative humidity numeric bounds, resolution, accuracy, and sampling."
    appliesTo = [ RQ_005 ]
    expression = {
        RQ_005.attributes.range_pct[1] = 0.0
        and RQ_005.attributes.range_pct[2] >= 90.0 and RQ_005.attributes.range_pct[2] <= 100.0
        and RQ_005.attributes.resolution_pct >= 0.1 and RQ_005.attributes.resolution_pct <= 1.0
        and RQ_005.attributes.accuracy_pct >= 1.0 and RQ_005.attributes.accuracy_pct <= 5.0
        and RQ_005.attributes.samplingInterval_s >= 1.0 and RQ_005.attributes.samplingInterval_s <= 600.0
    }
    notes = "Range 0–90/100% RH. Resolution 0.1–1% RH; accuracy 1–5% RH."
}

/* RQ_006 - Battery runtime */
requirement def RQ_006
{
    id = "RQ_006"
    text = "Device shall operate for 8 hours on a single battery charge."
    rationale = "Support typical portable monitoring sessions."
    type = "Performance/Power"
    priority = "High"
    verifMethod = "Test"
    attributes =
    {
        runtime_hours : Real[1] -- see C_006
        runtime_condition : String[1] -- see C_006
        batteryRechargable : Boolean[1] = true
    }
}
constraint def C_006
{
    id = "C_006"
    text = "Runtime and measurement conditions for 8-hour operation."
    appliesTo = [ RQ_006 ]
    expression = {
        RQ_006.attributes.runtime_hours = 8.0
        and RQ_006.attributes.runtime_condition in {"continuous full-measurement mode", "typical measurement mode"}
    }
    notes = "Runtime defined as continuous operation with all enabled sensors and wireless idle or periodic sync as specified by RQ_008. Verification by battery-discharge test under stated condition."
}

/* RQ_007 - Rechargeable battery requirement */
requirement def RQ_007
{
    id = "RQ_007"
    text = "Device shall include a rechargeable battery."
    rationale = "Energy source for portable operation."
    type = "Functional/Power"
    priority = "High"
    verifMethod = "Inspection, Test"
    attributes =
    {
        rechargeable : Boolean[1] = true
        maxRechargeTime_h : Real[1] -- see C_007
        removable : Boolean[1]? -- optional, see C_007
    }
}
constraint def C_007
{
    id = "C_007"
    text = "Rechargeable battery recharge time and optional removability."
    appliesTo = [ RQ_007 ]
    expression = {
        RQ_007.attributes.rechargeable = true
        and RQ_007.attributes.maxRechargeTime_h >= 0.5 and RQ_007.attributes.maxRechargeTime_h <= 8.0
    }
    notes = "Target recharge time <=8 h; recommended <=4 h. Battery removability not required; if provided, document as a design option."
}

/* RQ_008 - Wireless data sync via Wi‑Fi or Bluetooth */
requirement def RQ_008
{
    id = "RQ_008"
    text = "Device shall sync data via Wi‑Fi or Bluetooth."
    rationale = "Flexible data transfer to phones/gateways."
    type = "Interface/Connectivity"
    priority = "High"
    verifMethod = "Test, Inspection"
    attributes =
    {
        interfaces : String[*] -- see C_008
        minThroughput_kbps : Real[1] -- see C_008
        encryptionSupported : Boolean[1] -- see C_008
        offlineBufferingRequired : Boolean[1] -- see C_008
    }
}
constraint def C_008
{
    id = "C_008"
    text = "Connectivity options, throughput, security, and buffering."
    appliesTo = [ RQ_008 ]
    expression = {
        // Must support at least one of Wi‑Fi or Bluetooth
        ("Wi‑Fi" in RQ_008.attributes.interfaces) or ("Bluetooth" in RQ_008.attributes.interfaces)
        and RQ_008.attributes.minThroughput_kbps >= 10.0 and RQ_008.attributes.minThroughput_kbps <= 5000.0
        and RQ_008.attributes.encryptionSupported = true
        and RQ_008.attributes.offlineBufferingRequired = true
    }
    notes = "At least one of Wi‑Fi or Bluetooth must be implemented. Minimum throughput 10 kb/s to support periodic data batches. Encryption required for data-in-transit. Offline buffering required for periods without connectivity (see RQ_009 for storage)."
}

/* RQ_009 - Local data storage/buffering */
requirement def RQ_009
{
    id = "RQ_009"
    text = "Device shall locally buffer measurement data when wireless connectivity is unavailable."
    rationale = "Avoid data loss between sync events."
    type = "Functional/Storage"
    priority = "High"
    verifMethod = "Test"
    attributes =
    {
        bufferCapacity_records : Integer[1] -- see C_009
        retention_days : Real[1] -- see C_009
        nonvolatile : Boolean[1] = true
    }
}
constraint def C_009
{
    id = "C_009"
    text = "Local buffering capacity and retention."
    appliesTo = [ RQ_009 ]
    expression = {
        RQ_009.attributes.bufferCapacity_records >= 24
        and RQ_009.attributes.bufferCapacity_records <= 1000000
        and RQ_009.attributes.retention_days >= 1.0 and RQ_009.attributes.retention_days <= 365.0
        and RQ_009.attributes.nonvolatile = true
    }
    notes = "Minimum buffer to store at least 24 records (e.g., 1 per 15 min for 6 hours); allow large capacity for extended offline use. Data must be retained in nonvolatile storage across power cycles."
}

/* RQ_010 - Environmental operating conditions */
requirement def RQ_010
{
    id = "RQ_010"
    text = "Device shall operate within specified ambient conditions."
    rationale = "Reliable operation across expected environments."
    type = "Environmental"
    priority = "High"
    verifMethod = "Test"
    attributes =
    {
        operatingTemp_C : Real[2] -- min, max (see C_010)
        storageTemp_C : Real[2] -- min, max (see C_010)
        operatingHumidity_pct : Real[2] -- min, max (see C_010)
    }
}
constraint def C_010
{
    id = "C_010"
    text = "Operating and storage temperature/humidity bounds."
    appliesTo = [ RQ_010 ]
    expression = {
        RQ_010.attributes.operatingTemp_C[1] >= -20.0 and RQ_010.attributes.operatingTemp_C[2] <= 50.0
        and RQ_010.attributes.storageTemp_C[1] >= -40.0 and RQ_010.attributes.storageTemp_C[2] <= 85.0
        and RQ_010.attributes.operatingHumidity_pct[1] >= 0.0 and RQ_010.attributes.operatingHumidity_pct[2] <= 95.0
    }
    notes = "Typical handheld operating range -20 to 50 °C, storage -40 to 85 °C, operating RH 0–95% non-condensing."
}

/* RQ_011 - Data format and time-stamping */
requirement def RQ_011
{
    id = "RQ_011"
    text = "Device shall timestamp and format measurement data for transmission and storage."
    rationale = "Ensure data integrity and temporal context."
    type = "Functional/Data"
    priority = "Medium"
    verifMethod = "Inspection, Test"
    attributes =
    {
        timestampAccuracy_s : Real[1] -- see C_011
        format : String[1] -- see C_011
        includeUnits : Boolean[1] = true
    }
}
constraint def C_011
{
    id = "C_011"
    text = "Timestamp accuracy and data format constraints."
    appliesTo = [ RQ_011 ]
    expression = {
        RQ_011.attributes.timestampAccuracy_s >= 0.001 and RQ_011.attributes.timestampAccuracy_s <= 60.0
        and RQ_011.attributes.format in {"JSON","CSV","Binary","protobuf","custom"} 
        and RQ_011.attributes.includeUnits = true
    }
    notes = "Timestamp accuracy between 1 ms and 60 s acceptable depending on sync strategy. Format