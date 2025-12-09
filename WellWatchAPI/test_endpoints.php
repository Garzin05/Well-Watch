<?php
// ===========================================
// test_endpoints.php
// Script de teste para verificar os endpoints
// ===========================================

header('Content-Type: application/json; charset=UTF-8');

include 'db.php';

echo "===== TESTE DE ENDPOINTS =====\n\n";

// 1. Verificar todos os usuarios
echo "1. TODOS OS USUÁRIOS NA TABELA:\n";
$result = $conn->query("SELECT id, name, email, role FROM users");
if ($result) {
    $rows = [];
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
        echo "   - ID: {$row['id']}, Nome: {$row['name']}, Email: {$row['email']}, Role: '{$row['role']}'\n";
    }
    echo "   Total: " . count($rows) . " usuários\n\n";
}

// 2. Verificar pacientes especificamente
echo "2. PACIENTES (role = 'patient'):\n";
$result = $conn->query("SELECT id, name, email, role FROM users WHERE role = 'patient'");
if ($result) {
    echo "   Encontrados: " . $result->num_rows . " pacientes\n";
    while ($row = $result->fetch_assoc()) {
        echo "   - {$row['name']} ({$row['email']})\n";
    }
    echo "\n";
}

// 3. Verificar pacientes case-insensitive
echo "3. PACIENTES (LOWER(role) = 'patient'):\n";
$result = $conn->query("SELECT id, name, email, role FROM users WHERE LOWER(role) = 'patient'");
if ($result) {
    echo "   Encontrados: " . $result->num_rows . " pacientes\n";
    while ($row = $result->fetch_assoc()) {
        echo "   - {$row['name']} ({$row['email']})\n";
    }
    echo "\n";
}

// 4. Testar get_all_patient_emails.php
echo "4. TESTANDO GET_ALL_PATIENT_EMAILS.PHP:\n";
$url = 'http://localhost/WellWatchAPI/get_all_patient_emails.php';
if (function_exists('file_get_contents')) {
    $response = @file_get_contents($url);
    if ($response) {
        $json = json_decode($response, true);
        echo "   Status: " . ($json['status'] ? 'OK' : 'ERRO') . "\n";
        echo "   Total de emails: " . ($json['total'] ?? 'N/A') . "\n";
        if (isset($json['debug'])) {
            echo "   Debug Log:\n";
            foreach ($json['debug'] as $line) {
                echo "      - " . $line . "\n";
            }
        }
        echo "\n";
    }
}

echo "===== FIM DO TESTE =====\n";

$conn->close();
?>
