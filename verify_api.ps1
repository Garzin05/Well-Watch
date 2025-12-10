# Script para verificar se a API esta funcionando

Write-Host "Verificando API de Persistencia de Dados..." -ForegroundColor Cyan

$apiUrl = "http://localhost/WellWatchAPI/insert_measurement.php"
$logPath = "C:\xampp\htdocs\WellWatchAPI\logs"

# Verificar se pasta de logs existe
Write-Host ""
Write-Host "1. Verificando pasta de logs..." -ForegroundColor Yellow
if (Test-Path $logPath) {
    Write-Host "[OK] Pasta de logs encontrada: $logPath" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Pasta de logs NAO ENCONTRADA: $logPath" -ForegroundColor Red
}

# Verificar se arquivo de log existe
Write-Host ""
Write-Host "2. Procurando arquivos de log..." -ForegroundColor Yellow
$logFiles = Get-ChildItem -Path $logPath -Filter "insert_measurement*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
if ($logFiles) {
    Write-Host "[OK] Encontrados arquivos de log:" -ForegroundColor Green
    $logFiles | ForEach-Object {
        $size = (Get-Item $_.FullName).Length
        Write-Host "     Arquivo: $($_.Name) ($size bytes)" -ForegroundColor Cyan
    }
} else {
    Write-Host "[AVISO] Nenhum arquivo de log encontrado" -ForegroundColor Yellow
}

# Testar API com requisicao simples
Write-Host ""
Write-Host "3. Testando conectividade com API..." -ForegroundColor Yellow

$jsonData = @{
    patient_id   = 5
    type_code    = "glucose"
    glucose_value = 150.0
    recorded_at  = (Get-Date).ToString("o")
} | ConvertTo-Json

Write-Host "[ENVIANDO] POST para: $apiUrl" -ForegroundColor Cyan
Write-Host "[CORPO] $jsonData" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri $apiUrl `
        -Method POST `
        -ContentType "application/json; charset=UTF-8" `
        -Body $jsonData `
        -TimeoutSec 10 `
        -SkipHttpErrorCheck

    Write-Host ""
    Write-Host "[OK] Resposta recebida!" -ForegroundColor Green
    Write-Host "     Status Code: $($response.StatusCode)" -ForegroundColor Cyan
    Write-Host "     Body: $($response.Content)" -ForegroundColor Gray
    
    # Tentar parsear como JSON
    try {
        $json = $response.Content | ConvertFrom-Json
        Write-Host ""
        Write-Host "[JSON] Decodificado:" -ForegroundColor Yellow
        $json | Format-Table -AutoSize
    } catch {
        Write-Host "[AVISO] Nao conseguiu decodificar resposta como JSON" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "[ERRO] Erro ao conectar com API:" -ForegroundColor Red
    Write-Host "       $($_.Exception.Message)" -ForegroundColor Red
}

# Exibir ultimas linhas do log
Write-Host ""
Write-Host "4. Ultimas linhas do log..." -ForegroundColor Yellow

if ($logFiles) {
    $latestLog = $logFiles[0].FullName
    Write-Host "[ARQUIVO] $($logFiles[0].Name)" -ForegroundColor Cyan
    Write-Host ""
    Get-Content -Path $latestLog -Tail 40 | Write-Host -ForegroundColor Gray
} else {
    Write-Host "[ERRO] Nenhum log para exibir" -ForegroundColor Red
}

# Verificar banco de dados
Write-Host ""
Write-Host "5. Verificando se paciente_id foi salvo..." -ForegroundColor Yellow
Write-Host "[SQL] Executar em phpMyAdmin:" -ForegroundColor Cyan
Write-Host ""
Write-Host "SELECT * FROM measurements WHERE patient_id = 5 ORDER BY created_at DESC LIMIT 5;" -ForegroundColor Green
Write-Host ""
Write-Host "[ACESSO] http://localhost/phpmyadmin" -ForegroundColor Cyan

Write-Host ""
Write-Host "[OK] Diagnostico concluido!" -ForegroundColor Green
