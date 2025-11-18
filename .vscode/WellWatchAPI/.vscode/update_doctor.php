<?php
// update_doctor.php
include 'cors.php';
include 'db.php';

$raw = file_get_contents("php://input");
$raw = trim($raw);
$raw = preg_replace('/^\xEF\xBB\xBF/', '', $raw);
$data = json_decode($raw, true);

if (!is_array($data)) {
    echo json_encode(["status" => false, "message" => "JSON inválido"]);
    exit;
}

$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : null;
$name = trim($data["name"] ?? "");
$email = trim($data["email"] ?? "");
$telefone = trim($data["telefone"] ?? "");
$crm = trim($data["crm"] ?? "");
$especialidade = trim($data["especialidade"] ?? "");
$hospital = trim($data["hospital"] ?? "");
$data_nascimento = trim($data["data_nascimento"] ?? "");
$cep = trim($data["cep"] ?? "");

if (!$user_id || $name === "" || $email === "") {
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

// Atualiza doctors (se existir)
$stmt2 = $conn->prepare("
    UPDATE doctors 
    SET crm = ?, telefone = ?, especialidade = ?, hospital_afiliado = ?, data_nascimento = ?, cep = ?
    WHERE user_id = ?
");
$stmt2->bind_param("ssssssi", $crm, $telefone, $especialidade, $hospital, $data_nascimento, $cep, $user_id);

if ($stmt2->execute()) {
    echo json_encode(["status" => true, "message" => "Perfil atualizado com sucesso"], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(["status" => false, "message" => "Erro ao atualizar médico", "error" => $stmt2->error], JSON_UNESCAPED_UNICODE);
}
?>
