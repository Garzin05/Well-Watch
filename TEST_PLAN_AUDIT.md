# End-to-End Data Flow Audit Test Plan

## Objective
Trace where measurement data disappears when doctor views patient measurements.

## Test Scenario
**Doctor (admin/123456) selects a patient with known measurements**

### Expected Data Flow
```
[Browser] Doctor selects patient
    ↓
[Dart] DiabetesPage calls getGlucoseMeasurements(patientId)
    ↓
[Dart] ApiService.getMeasurements() makes HTTP GET request
    ↓
[Backend] get_measurements.php receives request
    ↓
[MySQL] Queries measurements table WHERE patient_id=X AND type_code='glucose'
    ↓
[PHP] Logs results (0 rows? X rows? Which measurements?)
    ↓
[PHP] Sends JSON response back
    ↓
[Dart] ApiService receives response, logs it completely
    ↓
[Dart] Parses measurements array into VitalRecord objects
    ↓
[Dart] Logs each record: "Sucesso ao parsear: glucose=XXX"
    ↓
[Browser] Display shows chart with data
```

## Test Matrix

| Point | Component | Expected Result | Log Evidence |
|-------|-----------|-----------------|--------------|
| 1 | Dart Request | patientId sent | `[API-GLUCOSE] Iniciando busca para patientId=5` |
| 2 | PHP Query | SQL returns N rows | `Query executada. Linhas encontradas: 3` |
| 3 | PHP Response | JSON array with measurements | `Primeira medicao: {"id":42, ...}` |
| 4 | Dart Parse | measurements.length > 0 | `[API-GLUCOSE] Total de medicoes brutas: 3` |
| 5 | Dart VitalRecord | Successful VitalRecord creation | `[API-GLUCOSE] Sucesso ao parsear: glucose=100.0` |
| 6 | Dart Return | List has X records | `[API-GLUCOSE] Total parseado: 3` |
| 7 | Display | Chart shows measurements | Visual: Y-axis shows 100 mg/dL |

## Test Execution

### Step 1: Check PHP Log File
**After** selecting patient in doctor view, check:
```
C:\xampp\htdocs\WellWatchAPI\logs\get_measurements_YYYY-MM-DD.log
```

**What to look for:**
- If file doesn't exist → PHP never received request
- If file empty → PHP received request but SQL didn't return data
- If file has "Linhas encontradas: 0" → SQL query is wrong
- If file has "Linhas encontradas: 3" → Backend is working

### Step 2: Check Flutter Console
**In VS Code Terminal (flutter run output)**

**Look for these log lines:**
```
[API-GLUCOSE] Iniciando busca para patientId=5
[API-GLUCOSE] Resposta da API: {status: true, measurements: [...]}
[API-GLUCOSE] Total de medicoes brutas: 3
[API-GLUCOSE] Parseando: {id: 42, patient_id: 5, glucose_value: 100.0, ...}
[API-GLUCOSE] Sucesso ao parsear: glucose=100.0, date=...
[API-GLUCOSE] Total parseado: 3
```

### Step 3: Check Browser Console
**F12 in Edge** → Console tab

**Look for:**
- Network request to `http://localhost:8080/get_measurements.php?patient_id=5&type_code=glucose`
- Response status 200 with JSON
- Any JavaScript errors preventing display

### Step 4: Visual Test
**Does the chart show 100 mg/dL?**
- YES → Data flow is complete ✅
- NO → Data is retrieved but not displayed (UI issue)
- "Nenhum registro" → Data is not being retrieved (earlier point in chain)

## Diagnostic Decision Tree

```
Patient selected in doctor view
│
├─ "Nenhum registro de glicose"
│  │
│  ├─ PHP log file missing/empty?
│  │  └─ NO request received → Frontend not calling API
│  │     Solution: Check if patient selection code is executing
│  │
│  ├─ PHP log says "Linhas encontradas: 0"
│  │  └─ SQL returns nothing → patient_id not in database
│  │     OR type_code='glucose' records don't exist
│  │     Solution: Insert test measurement for patient
│  │
│  ├─ [API-GLUCOSE] logs show empty measurements array
│  │  └─ PHP returned {"measurements": []} → backend issue
│  │     Solution: Check SQL in get_measurements.php
│  │
│  ├─ [API-GLUCOSE] logs show parsing errors
│  │  └─ JSON format mismatch → field names wrong
│  │     Solution: Log JSON structure and compare to VitalRecord.fromJson()
│  │
│  └─ Total parseado: 0 but measurements had items
│     └─ All records failed parsing
│        Solution: Check exception handling in parsing
│
└─ Chart displays measurement data ✅
   └─ SUCCESS - Data flow is complete
```

## Test Data Requirements

**For testing to be valid, need:**
1. Known patient ID (e.g., patient_id=5)
2. Known measurement in database (e.g., glucose_value=100.0, recorded_at=TODAY)
3. Doctor account logged in (admin/123456)

**Before running test, verify in MySQL:**
```sql
SELECT * FROM measurements WHERE patient_id=5 AND type_code='glucose' LIMIT 5;
```

Should show at least one row with data.

## Success Criteria

✅ **PASS** if:
- All 7 points in test matrix show expected results
- Flutter console has all [API-GLUCOSE] logs
- Chart displays at least one measurement point
- No errors in any log file

❌ **FAIL** if:
- Any test matrix point shows unexpected result
- Missing logs at any stage
- PHP log shows 0 rows but measurements exist in MySQL
- Parsing errors in Flutter console

## Action Items
- [ ] Verify test measurement exists in MySQL
- [ ] Open browser F12 console before testing
- [ ] Tail PHP log file before doctor selection
- [ ] Check Flutter console output in VS Code
- [ ] Document exact log line numbers where issue occurs
