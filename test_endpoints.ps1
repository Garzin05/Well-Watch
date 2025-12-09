# Script para testar endpoints PHP

Write-Host "=== Testando Endpoints ===" -ForegroundColor Green

# Teste 1: get_all_patient_emails
Write-Host "`n1. Testando get_all_patient_emails.php..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/get_all_patient_emails.php" -Method GET
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Status: $($data.status)" -ForegroundColor Green
    Write-Host "Total de pacientes: $($data.total)" -ForegroundColor Green
    Write-Host "Emails:" -ForegroundColor Cyan
    $data.emails | ForEach-Object { Write-Host "  - $_" }
} catch {
    Write-Host "ERRO: $_" -ForegroundColor Red
}

# Teste 2: get_patient_by_email
Write-Host "`n2. Testando get_patient_by_email.php com paciente1@gmail.com..." -ForegroundColor Yellow
try {
    $email = "paciente1@gmail.com"
    $response = Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/get_patient_by_email.php?email=$email" -Method GET
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Status: $($data.status)" -ForegroundColor Green
    if ($data.status) {
        Write-Host "Paciente encontrado:" -ForegroundColor Green
        Write-Host "  ID: $($data.patient.id)"
        Write-Host "  Nome: $($data.patient.name)"
        Write-Host "  Email: $($data.patient.email)"
        Write-Host "  Role: $($data.patient.role)"
    } else {
        Write-Host "Paciente não encontrado: $($data.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "ERRO: $_" -ForegroundColor Red
}

Write-Host "`n=== Testes Completos ===" -ForegroundColor Green
