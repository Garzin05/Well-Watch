<?php
include 'db.php';
header('Content-Type: application/json');

// Recebe JSON do Flutter
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!isset($data["user_id"])) {
    echo json_encode([
        "status" => false,
        "message" => "user_id is required"
    ]);
    exit;
}

$user_id = intval($data["user_id"]);

// Consulta completa do médico
$stmt = $conn->prepare("
    SELECT 
        u.id AS user_id,
        u.name,
        u.email,
        d.crm,
        d.telefone,
        d.especialidade,
        d.hospital_afiliado
    FROM users u
    INNER JOIN doctors d ON d.user_id = u.id
    WHERE u.id = ?
    LIMIT 1
");

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "Médico não encontrado"
    ]);
    exit;
}

$doctor = $result->fetch_assoc();

echo json_encode([
    "status" => true,
    "data" => $doctor
]);
?>
