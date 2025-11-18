<?php
// update_patient.php
include 'cors.php';
include 'db.php';

$raw = file_get_contents("php://input");
$raw = trim($raw);
$raw = preg_replace('/^\xEF\xBB\xBF/', '', $raw);
$data = json_decode($raw, true);

if (!is_array($data) || !isset($data['user_id'])) {
    echo json_encode(["status" => false, "message" => "user_id is required"]);
    exit;
}

$user_id = intval($data['user_id']);
$name     = trim($data['name'] ?? "");
$email    = trim($data['email'] ?? "");
$telefone = trim($data['telefone'] ?? "");

// Campos do paciente (numéricos)
$age    = isset($data['age']) ? intval($data['age']) : null;
$height = isset($data['height']) ? floatval($data['height']) : null;
$weight = isset($data['weight']) ? floatval($data['weight']) : null;

if ($name === "" || $email === "") {
    echo json_encode(["status" => false, "message" => "Campos obrigatórios não enviados"]);
    exit;
}

// Atualiza users
$stmt = $conn->prepare("UPDATE users SET name = ?, email = ? WHERE id = ?");
$stmt->bind_param("ssi", $name, $email, $user_id);
if (!$stmt->execute()) {
    echo json_encode(["status" => false, "message" => "Erro ao atualizar usuário", "error" => $stmt->error]);
    exit;
}

// Atualiza patients (algumas colunas podem variar no seu schema)
$stmt2 = $conn->prepare("
    UPDATE patients 
    SET telefone = ?, idade = ?, altura = ?, peso_inicial = ?
    WHERE user_id = ?
");
$stmt2->bind_param("siddi", $telefone, $age, $height, $weight, $user_id);
if (!$stmt2->execute()) {
    echo json_encode(["status" => false, "message" => "Erro ao atualizar paciente", "error" => $stmt2->error]);
    exit;
}

echo json_encode(["status" => true, "message" => "Perfil do paciente atualizado com sucesso!"], JSON_UNESCAPED_UNICODE);
?>
