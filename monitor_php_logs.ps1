# Monitor de Logs do PHP em Tempo Real
# Execute este script ANTES de iniciar o teste de medições

# Caminho do arquivo de log do PHP
$phpLogPath = "C:\php-8.2.0\php_errors.log"

# Verificar se o arquivo existe
if (-not (Test-Path $phpLogPath)) {
    Write-Host "❌ Arquivo de log não encontrado: $phpLogPath" -ForegroundColor Red
    Write-Host "Verifique a instalação do PHP ou configure o php.ini com:"
    Write-Host "  error_log = C:\php-8.2.0\php_errors.log"
    exit
}

Write-Host "📊 Monitorando logs do PHP..." -ForegroundColor Cyan
Write-Host "Arquivo: $phpLogPath" -ForegroundColor Gray
Write-Host "Pressione CTRL+C para parar`n" -ForegroundColor Gray

# Pegar o tamanho inicial do arquivo
$initialSize = (Get-Item $phpLogPath).Length

# Loop para monitorar novos logs
while ($true) {
    Start-Sleep -Milliseconds 500
    
    $currentSize = (Get-Item $phpLogPath).Length
    
    if ($currentSize -gt $initialSize) {
        # Novo conteúdo foi adicionado
        $newLines = Get-Content $phpLogPath -Tail 5
        
        foreach ($line in $newLines) {
            if ($line -match "\[INSERT_MEASUREMENT\]") {
                if ($line -match "✅|Sucesso") {
                    Write-Host $line -ForegroundColor Green
                } elseif ($line -match "❌|Erro") {
                    Write-Host $line -ForegroundColor Red
                } else {
                    Write-Host $line -ForegroundColor Yellow
                }
            }
        }
        
        $initialSize = $currentSize
    }
}
