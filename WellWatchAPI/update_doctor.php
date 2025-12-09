<?php
// update_doctor.php
include 'db.php';

header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    echo json_encode(["status" => true]);
    exit;
}

// Lê JSON da requisição
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!$data) {
    echo json_encode(["status" => false, "message" => "JSON inválido"]);
    exit;
}

$user_id = $data["user_id"] ?? null;
$name = $data["name"] ?? null;
$email = $data["email"] ?? null;
$telefone = $data["telefone"] ?? null;
$crm = $data["crm"] ?? null;
$especialidade = $data["especialidade"] ?? null;
$hospital = $data["hospital"] ?? null; // campo hospital_afiliado no banco
$data_nascimento = $data["data_nascimento"] ?? null;
$cep = $data["cep"] ?? null;

if (!$user_id || !$name || !$email) {
    echo json_encode(["status" => false, "message" => "Campos obrigatórios não enviados"]);
    exit;
}

// -----------------------------
// Atualiza tabela USERS
// -----------------------------
$stmt = $conn->prepare("UPDATE users SET name = ?, email = ? WHERE id = ?");
$stmt->bind_param("ssi", $name, $email, $user_id);
$stmt->execute();

// -----------------------------
// Atualiza tabela DOCTORS
// -----------------------------
$stmt2 = $conn->prepare("
    UPDATE doctors 
    SET 
        crm = ?,
        telefone = ?,
        especialidade = ?,
        hospital_afiliado = ?,
        data_nascimento = ?,
        cep = ?
    WHERE user_id = ?
");

$stmt2->bind_param(
    "ssssssi",
    $crm,
    $telefone,
    $especialidade,
    $hospital,
    $data_nascimento,
    $cep,
    $user_id
);

if ($stmt2->execute()) {
    echo json_encode(["status" => true, "message" => "Perfil atualizado com sucesso"]);
} else {
    echo json_encode(["status" => false, "message" => "Erro ao atualizar médico", "error" => $stmt2->error]);
}
?>
