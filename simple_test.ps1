#!/usr/bin/env powershell

Write-Host "Testando API de Insercao de Medicoes..." -ForegroundColor Cyan
Write-Host ""

$apiUrl = "http://localhost/WellWatchAPI/insert_measurement.php"

# Criar JSON com dados de teste
$jsonBody = @{
    patient_id   = 5
    type_code    = "glucose"
    glucose_value = 150.0
    recorded_at  = (Get-Date).ToString("o")
} | ConvertTo-Json

Write-Host "URL: $apiUrl" -ForegroundColor Green
Write-Host "Corpo JSON:" -ForegroundColor Green
Write-Host $jsonBody -ForegroundColor Gray
Write-Host ""

try {
    # Testar conexao basica com curl (mais confiavel que Invoke-WebRequest)
    Write-Host "Enviando requisicao..." -ForegroundColor Yellow
    
    $result = curl.exe -X POST `
        -H "Content-Type: application/json" `
        -d $jsonBody `
        "$apiUrl" `
        2>&1
    
    Write-Host ""
    Write-Host "RESPOSTA DA API:" -ForegroundColor Cyan
    Write-Host $result -ForegroundColor Gray
    
} catch {
    Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Verificando se log foi criado..." -ForegroundColor Yellow

$logDir = "C:\xampp\htdocs\WellWatchAPI\logs"
if (Test-Path $logDir) {
    Write-Host "[OK] Pasta logs existe" -ForegroundColor Green
    
    $logFile = Get-ChildItem $logDir -Filter "insert_measurement*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($logFile) {
        Write-Host "[OK] Arquivo de log encontrado: $($logFile.Name)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Conteudo do log:" -ForegroundColor Yellow
        Get-Content $logFile.FullName -Tail 50
    } else {
        Write-Host "[AVISO] Nenhum arquivo de log encontrado em $logDir" -ForegroundColor Yellow
    }
} else {
    Write-Host "[AVISO] Pasta logs nao existe: $logDir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pronto! Verifique o banco de dados em http://localhost/phpmyadmin" -ForegroundColor Green
