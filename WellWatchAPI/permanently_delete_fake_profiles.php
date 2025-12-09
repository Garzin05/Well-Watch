<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "well_watch";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => false, "message" => "Conexão falhou: " . $conn->connect_error]));
}

// PERMANENTEMENTE EXCLUIR TODOS OS PERFIS FAKE
$fakeNames = ['Joao Silva', 'Maria Santos', 'Pedro Oliveira', 'Mario Barros'];
$placeholders = implode(',', array_fill(0, count($fakeNames), '?'));

$stmt = $conn->prepare("DELETE FROM users WHERE name IN ($placeholders) AND role = 'patient'");

if (!$stmt) {
    die(json_encode(["status" => false, "message" => "Erro ao preparar statement: " . $conn->error]));
}

// Bind parameters
$types = str_repeat('s', count($fakeNames));
$stmt->bind_param($types, ...$fakeNames);

if ($stmt->execute()) {
    $deletedRows = $stmt->affected_rows;
    $result = [
        "status" => true,
        "message" => "EXCLUSÃO PERMANENTE: $deletedRows perfis fake removidos do banco de dados",
        "deleted_rows" => $deletedRows,
        "deleted_names" => $fakeNames,
        "timestamp" => date('Y-m-d H:i:s')
    ];
} else {
    $result = [
        "status" => false,
        "message" => "Erro ao deletar: " . $stmt->error
    ];
}

$stmt->close();

// Verify remaining patients
$verifyResult = $conn->query("SELECT COUNT(*) as total FROM users WHERE role = 'patient'");
$countRow = $verifyResult->fetch_assoc();
$result['remaining_patients'] = $countRow['total'];

// Log final status
$allPatients = $conn->query("SELECT id, name, email, role FROM users WHERE role = 'patient' ORDER BY name");
$remaining = [];
while ($row = $allPatients->fetch_assoc()) {
    $remaining[] = $row;
}
$result['remaining_patients_list'] = $remaining;

$conn->close();

echo json_encode($result, JSON_PRETTY_PRINT);
?>
