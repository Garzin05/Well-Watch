# ============================================
# Script de Teste - Verificar Fluxo de Dados
# ============================================

Write-Host "🧪 TESTE DE INSERÇÃO DE MEDIÇÃO" -ForegroundColor Cyan
Write-Host "================================`n"

# Simulação de requisição POST
$patient_id = 5
$type_code = "glucose"
$glucose_value = 150.0
$recorded_at = Get-Date -Format "o"  # ISO 8601

Write-Host "📤 Enviando requisição para API:" -ForegroundColor Yellow
Write-Host "  - URL: http://localhost/WellWatchAPI/insert_measurement.php"
Write-Host "  - Method: POST"
Write-Host "  - patient_id: $patient_id"
Write-Host "  - type_code: $type_code"
Write-Host "  - glucose_value: $glucose_value"
Write-Host "  - recorded_at: $recorded_at"
Write-Host ""

$body = @{
    patient_id = $patient_id
    type_code = $type_code
    glucose_value = $glucose_value
    recorded_at = $recorded_at
} | ConvertTo-Json

Write-Host "📋 JSON Body:" -ForegroundColor Yellow
Write-Host $body
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost/WellWatchAPI/insert_measurement.php" `
        -Method Post `
        -ContentType "application/json; charset=UTF-8" `
        -Body $body `
        -ErrorAction Stop

    Write-Host "📥 Resposta recebida:" -ForegroundColor Green
    Write-Host "  - Status Code: $($response.StatusCode)"
    Write-Host "  - Content: $($response.Content)"
    
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.status) {
        Write-Host "`n✅ SUCESSO!" -ForegroundColor Green
        Write-Host "  - Measurement ID: $($result.measurement_id)"
    } else {
        Write-Host "`n❌ ERRO NA API!" -ForegroundColor Red
        Write-Host "  - Mensagem: $($result.message)"
        if ($result.error) {
            Write-Host "  - Erro DB: $($result.error)"
        }
    }
}
catch {
    Write-Host "❌ ERRO NA REQUISIÇÃO!" -ForegroundColor Red
    Write-Host "  - Erro: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "📊 Verificando logs:" -ForegroundColor Cyan
$log_dir = "C:\xampp\htdocs\WellWatchAPI\logs"
if (Test-Path $log_dir) {
    $latest_log = Get-ChildItem $log_dir -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest_log) {
        Write-Host "📄 Arquivo de log: $($latest_log.FullName)"
        Write-Host "`n--- ÚLTIMAS 30 LINHAS ---" -ForegroundColor Yellow
        Get-Content $latest_log.FullName -Tail 30
    }
} else {
    Write-Host "❌ Diretório de logs não encontrado: $log_dir" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 Verificando banco de dados:" -ForegroundColor Cyan
Write-Host "Execute no phpMyAdmin:" -ForegroundColor Yellow
Write-Host "SELECT * FROM measurements WHERE patient_id = $patient_id ORDER BY created_at DESC LIMIT 5;" -ForegroundColor White
