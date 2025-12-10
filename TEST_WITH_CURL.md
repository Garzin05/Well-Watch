# 🧪 Teste Manual com CURL

## Simular uma requisição de inserção de medição

### 1. Via PowerShell (Mais Fácil)

```powershell
# Inserir glicose de 150 mg/dL para paciente_id=5
$body = @{
    patient_id = 5
    type_code = "glucose"
    glucose_value = 150.0
    recorded_at = [datetime]::Now.ToUniversalTime().ToString('o')
} | ConvertTo-Json

$uri = "http://localhost/WellWatchAPI/insert_measurement.php"
$response = Invoke-WebRequest -Uri $uri -Method Post `
    -ContentType "application/json; charset=UTF-8" `
    -Body $body

Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"

# Esperado:
# Status Code: 200
# Response: {"status":true,"message":"Medição inserida com sucesso","measurement_id":XXX}
```

### 2. Via curl (Se tiver instalado)

```bash
curl -X POST http://localhost/WellWatchAPI/insert_measurement.php \
  -H "Content-Type: application/json; charset=UTF-8" \
  -d '{
    "patient_id": 5,
    "type_code": "glucose",
    "glucose_value": 150.0,
    "recorded_at": "'$(date -u +%Y-%m-%dT%H:%M:%S.000Z)'"
  }'

# Esperado:
# {"status":true,"message":"Medição inserida com sucesso","measurement_id":42}
```

### 3. Testar Peso

```powershell
$body = @{
    patient_id = 5
    type_code = "weight"
    weight_value = 75.5
    recorded_at = [datetime]::Now.ToUniversalTime().ToString('o')
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/insert_measurement.php" `
    -Method Post -ContentType "application/json; charset=UTF-8" -Body $body | Select-Object -ExpandProperty Content
```

### 4. Testar Pressão

```powershell
$body = @{
    patient_id = 5
    type_code = "pressure"
    systolic = 130
    diastolic = 85
    heart_rate = 72
    recorded_at = [datetime]::Now.ToUniversalTime().ToString('o')
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/insert_measurement.php" `
    -Method Post -ContentType "application/json; charset=UTF-8" -Body $body | Select-Object -ExpandProperty Content
```

## Verificar Inserções via GET

```powershell
# Ver medições do paciente 5 (glicose)
Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/get_measurements.php?patient_id=5&type_code=glucose" `
    | Select-Object -ExpandProperty Content | ConvertFrom-Json | ConvertTo-Json -Depth 10

# Ver medições do paciente 5 (todas)
Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/get_measurements.php?patient_id=5" `
    | Select-Object -ExpandProperty Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

## Script Completo de Teste (salvar como test_measurements.ps1)

```powershell
# ============================================
# Script de Teste - Inserção de Medições
# ============================================

param(
    [int]$PatientId = 5,
    [string]$Type = "glucose"  # glucose, weight, pressure
)

$baseUrl = "http://localhost/WellWatchAPI"
$timestamp = [datetime]::Now.ToUniversalTime().ToString('o')

Write-Host "🧪 Teste de Inserção de Medição" -ForegroundColor Cyan
Write-Host "Patient ID: $PatientId"
Write-Host "Tipo: $Type"
Write-Host "Timestamp: $timestamp`n"

# Preparar dados conforme tipo
$body = @{
    patient_id = $PatientId
    type_code = $Type
    recorded_at = $timestamp
}

switch($Type) {
    "glucose" {
        $body['glucose_value'] = 145.0
    }
    "weight" {
        $body['weight_value'] = 75.5
    }
    "pressure" {
        $body['systolic'] = 130
        $body['diastolic'] = 85
        $body['heart_rate'] = 72
    }
}

# Converter para JSON
$jsonBody = $body | ConvertTo-Json
Write-Host "📤 Enviando:`n$jsonBody`n" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/insert_measurement.php" `
        -Method Post `
        -ContentType "application/json; charset=UTF-8" `
        -Body $jsonBody

    Write-Host "✅ Status: $($response.StatusCode)" -ForegroundColor Green
    
    $content = $response.Content | ConvertFrom-Json
    Write-Host "📥 Resposta:`n$(($content | ConvertTo-Json -Depth 10))`n" -ForegroundColor Green
    
    if ($content.status) {
        Write-Host "🎉 Medição inserida com sucesso! ID: $($content.measurement_id)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Erro: $($content.message)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Erro na requisição: $_" -ForegroundColor Red
}

# Verificar no banco
Write-Host "`n📊 Verificando no banco..." -ForegroundColor Cyan
$getResponse = Invoke-WebRequest -Uri "$baseUrl/get_measurements.php?patient_id=$PatientId&type_code=$Type"
$measurements = $getResponse.Content | ConvertFrom-Json
Write-Host "Registros encontrados: $($measurements.measurements.Count)`n"
$measurements.measurements | Format-Table -AutoSize
```

## Executar Teste Automatizado

```powershell
# Teste de glicose
& "C:\Users\Pudinga\Documents\Well-Watch\test_measurements.ps1" -PatientId 5 -Type "glucose"

# Teste de peso
& "C:\Users\Pudinga\Documents\Well-Watch\test_measurements.ps1" -PatientId 5 -Type "weight"

# Teste de pressão
& "C:\Users\Pudinga\Documents\Well-Watch\test_measurements.ps1" -PatientId 5 -Type "pressure"
```

## Esperado

```
🧪 Teste de Inserção de Medição
Patient ID: 5
Tipo: glucose
Timestamp: 2024-01-15T14:30:00.000Z

📤 Enviando:
{
  "patient_id":  5,
  "type_code":  "glucose",
  "recorded_at":  "2024-01-15T14:30:00.000Z",
  "glucose_value":  145
}

✅ Status: 200
📥 Resposta:
{
  "status": true,
  "message": "Medição inserida com sucesso",
  "measurement_id": 42
}

🎉 Medição inserida com sucesso! ID: 42

📊 Verificando no banco...
Registros encontrados: 1

recorded_at              glucose_value patient_id
-----------              ------------- ----------
2024-01-15 14:30:00.000  145.0         5
```

---

**Dica**: Use este teste se quiser verificar a API sem passar pela interface gráfica do Flutter.
