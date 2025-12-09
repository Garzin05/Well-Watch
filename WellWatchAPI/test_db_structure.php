<?php
// ===========================================
// test_db_structure.php
// Verifica a estrutura do banco de dados
// ===========================================

header('Content-Type: application/json; charset=UTF-8');

include 'db.php';

$output = [];

// 1. Verificar estrutura da tabela users
$output[] = "=== ESTRUTURA DA TABELA 'users' ===";
$result = $conn->query("DESCRIBE users");
if ($result) {
    $output[] = "Colunas:";
    while ($row = $result->fetch_assoc()) {
        $output[] = "  - {$row['Field']}: {$row['Type']} ({$row['Null']}) Default: {$row['Default']}";
    }
}

$output[] = "";
$output[] = "=== DADOS NA TABELA 'users' ===";

// 2. Contar todos os usuarios
$result = $conn->query("SELECT COUNT(*) as total FROM users");
$row = $result->fetch_assoc();
$output[] = "Total de usuários: " . $row['total'];

// 3. Listar todas as roles únicas
$output[] = "";
$output[] = "Roles únicas no banco:";
$result = $conn->query("SELECT DISTINCT role, COUNT(*) as count FROM users GROUP BY role");
while ($row = $result->fetch_assoc()) {
    $output[] = "  - '{$row['role']}': {$row['count']} usuários";
}

// 4. Listar todos os usuários com detalhes
$output[] = "";
$output[] = "Todos os usuários:";
$result = $conn->query("SELECT id, name, email, role FROM users ORDER BY id ASC");
while ($row = $result->fetch_assoc()) {
    $roleDisplay = $row['role'] . " (len: " . strlen($row['role']) . ", ascii: " . implode(",", array_map('ord', str_split($row['role']))) . ")";
    $output[] = "  ID {$row['id']}: {$row['name']} / {$row['email']} / Role: {$roleDisplay}";
}

// 5. Testar queries
$output[] = "";
$output[] = "=== TESTES DE QUERY ===";

$queries = [
    "SELECT COUNT(*) as count FROM users WHERE role = 'patient'" => "Contagem com role = 'patient'",
    "SELECT COUNT(*) as count FROM users WHERE LOWER(role) = 'patient'" => "Contagem com LOWER(role) = 'patient'",
    "SELECT COUNT(*) as count FROM users WHERE role LIKE 'patient'" => "Contagem com role LIKE 'patient'",
    "SELECT email FROM users WHERE role = 'patient' ORDER BY email" => "Emails com role = 'patient'",
];

foreach ($queries as $query => $description) {
    $output[] = "";
    $output[] = "$description:";
    $output[] = "  Query: $query";
    
    $result = $conn->query($query);
    if (!$result) {
        $output[] = "  ERRO: " . $conn->error;
        continue;
    }
    
    if ($result->num_rows === 0) {
        $output[] = "  Resultado: (vazio)";
    } else {
        while ($row = $result->fetch_assoc()) {
            $output[] = "  Resultado: " . json_encode($row);
        }
    }
}

// Enviar resposta
echo json_encode([
    "status" => true,
    "output" => $output
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

$conn->close();
?>
