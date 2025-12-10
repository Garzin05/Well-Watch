#!/usr/bin/env powershell
# Script para mostrar pacientes válidos no banco de dados

Write-Host "Conectando ao banco de dados..." -ForegroundColor Cyan

$db_config = @{
    host = "localhost"
    user = "root"
    password = ""
    database = "well_watch"
}

# Tentar criar conexão com banco via arquivos PHP
$query_file = "C:\xampp\htdocs\WellWatchAPI\get_patients.php"

if (-not (Test-Path $query_file)) {
    # Criar arquivo PHP temporário
    $php_code = @'
<?php
include 'db.php';

$result = $conn->query("SELECT id, email, nome FROM patients ORDER BY id LIMIT 20");

if ($result->num_rows > 0) {
    echo "ID,Email,Nome\n";
    while($row = $result->fetch_assoc()) {
        $id = $row['id'];
        $email = $row['email'];
        $nome = $row['nome'] ?? $row['name'] ?? 'UNKN OWN';
        echo "$id,$email,$nome\n";
    }
} else {
    echo "Nenhum paciente encontrado!\n";
}
$conn->close();
?>
'@

    Set-Content -Path $query_file -Value $php_code -Encoding UTF8
}

# Executar via curl
Write-Host ""
Write-Host "Pacientes no banco de dados:" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

curl.exe -s "http://localhost/WellWatchAPI/get_patients.php" 2>/dev/null | Out-Host

Write-Host ""
Write-Host "Use um dos IDs acima para testar a API!" -ForegroundColor Cyan
Write-Host ""
