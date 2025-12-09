<?php
include 'db.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Lê JSON do Flutter
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!isset($data['user_id'])) {
    echo json_encode([
        "status" => false,
        "message" => "user_id is required"
    ]);
    exit;
}

$user_id = intval($data['user_id']);

// Campos comuns
$name     = trim($data['name'] ?? "");
$email    = trim($data['email'] ?? "");
$telefone = trim($data['telefone'] ?? "");

// Campos do paciente
$age    = intval($data['age'] ?? 0);
$height = floatval($data['height'] ?? 0);
$weight = floatval($data['weight'] ?? 0);

// ---------------------------
// Atualiza tabela USERS
// ---------------------------
$stmt = $conn->prepare("
    UPDATE users 
    SET name = ?, email = ?
    WHERE id = ?
");
$stmt->bind_param("ssi", $name, $email, $user_id);

if (!$stmt->execute()) {
    echo json_encode([
        "status" => false,
        "message" => "Erro ao atualizar usuário",
        "error" => $stmt->error
    ]);
    exit;
}

// ---------------------------
// Atualiza tabela PATIENTS
// ---------------------------
$stmt2 = $conn->prepare("
    UPDATE patients 
    SET telefone = ?, idade = ?, altura = ?, peso_inicial = ?
    WHERE user_id = ?
");
$stmt2->bind_param("siddi", $telefone, $age, $height, $weight, $user_id);

if (!$stmt2->execute()) {
    echo json_encode([
        "status" => false,
        "message" => "Erro ao atualizar paciente",
        "error" => $stmt2->error
    ]);
    exit;
}

echo json_encode([
    "status" => true,
    "message" => "Perfil do paciente atualizado com sucesso!"
]);
?>
