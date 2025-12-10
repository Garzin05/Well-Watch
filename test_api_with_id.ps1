#!/usr/bin/env powershell
# Script para testar API com patient_id válido

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "TESTE DE INSERCAO DE MEDICOES - Well Watch API" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Pedir patient_id ao usuário
$patient_id = Read-Host "Digite o ID do paciente (ex: 1, 2, 3...)"

if (-not $patient_id) {
    Write-Host "ERRO: Você não digitou nenhum ID!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Testando com patient_id = $patient_id" -ForegroundColor Green
Write-Host ""

# Criar JSON manualmente (sem problemas de escape)
$date = Get-Date -Format "o"
$json = "{`"patient_id`": $patient_id, `"type_code`": `"glucose`", `"glucose_value`": 150.0, `"recorded_at`": `"$date`"}"

Write-Host "JSON enviado:" -ForegroundColor Yellow
Write-Host $json -ForegroundColor Gray
Write-Host ""

# Enviar requisição
$uri = "http://localhost/WellWatchAPI/insert_measurement.php"

try {
    Write-Host "Enviando... " -ForegroundColor Cyan -NoNewline
    
    $response = Invoke-WebRequest -Uri $uri `
        -Method POST `
        -ContentType "application/json" `
        -Body $json `
        -UseBasicParsing `
        -WarningAction SilentlyContinue
    
    Write-Host "OK!" -ForegroundColor Green
    Write-Host ""
    
    # Parsear resposta
    $json_response = $response.Content | ConvertFrom-Json
    
    Write-Host "RESPOSTA DA API:" -ForegroundColor Green
    Write-Host "===============" -ForegroundColor Green
    
    if ($json_response.status -eq $true) {
        Write-Host "[SUCESSO] Status: true" -ForegroundColor Green
        Write-Host "Measurement ID: $($json_response.measurement_id)" -ForegroundColor Green
        Write-Host "Patient ID: $($json_response.patient_id)" -ForegroundColor Green
        Write-Host "Type: $($json_response.type_code)" -ForegroundColor Green
        Write-Host ""
        Write-Host "DADOS SALVOS COM SUCESSO!" -ForegroundColor Green
        Write-Host "Verifique em: http://localhost/phpmyadmin" -ForegroundColor Cyan
    } else {
        Write-Host "[ERRO] Status: false" -ForegroundColor Red
        Write-Host "Mensagem: $($json_response.message)" -ForegroundColor Red
        Write-Host ""
        
        if ($json_response.code) {
            Write-Host "Código de erro: $($json_response.code)" -ForegroundColor Yellow
        }
        
        if ($json_response.error) {
            Write-Host "Detalhes: $($json_response.error)" -ForegroundColor Yellow
        }
    }
    
} catch {
    # Tentar parsear mesmo com erro
    Write-Host "ERRO" -ForegroundColor Red
    Write-Host ""
    
    try {
        $json_response = $_.Exception.Response.Content | ConvertFrom-Json
        Write-Host "Resposta: $($json_response.message)" -ForegroundColor Yellow
    } catch {
        Write-Host "Erro de requisição: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Verificar log
Write-Host ""
Write-Host "Verificando arquivo de log..." -ForegroundColor Cyan

$log_dir = "C:\xampp\htdocs\WellWatchAPI\logs"
if (Test-Path $log_dir) {
    $log_files = Get-ChildItem $log_dir -Filter "insert_measurement*.log" | Sort-Object LastWriteTime -Descending
    
    if ($log_files) {
        Write-Host "Arquivo de log: $($log_files[0].Name)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Últimas linhas do log:" -ForegroundColor Yellow
        Write-Host "=====================" -ForegroundColor Yellow
        Get-Content $log_files[0].FullName -Tail 30 | Write-Host -ForegroundColor Gray
    } else {
        Write-Host "Nenhum arquivo de log encontrado ainda" -ForegroundColor Yellow
    }
} else {
    Write-Host "Pasta de logs não encontrada: $log_dir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Teste concluído!" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
