<?php
// get_doctor_profile.php
include 'cors.php';
include 'db.php';

// Recebe JSON
$raw = file_get_contents("php://input");
$raw = trim($raw);
$raw = preg_replace('/^\xEF\xBB\xBF/', '', $raw);
$data = json_decode($raw, true);

if (!is_array($data) || !isset($data["user_id"])) {
    echo json_encode(["status" => false, "message" => "user_id is required"]);
    exit;
}

$user_id = intval($data["user_id"]);

$stmt = $conn->prepare("
    SELECT 
        u.id AS user_id,
        u.name,
        u.email,
        d.id AS doctor_id,
        d.crm,
        d.telefone,
        d.especialidade,
        d.hospital_afiliado,
        d.data_nascimento,
        d.cep
    FROM users u
    INNER JOIN doctors d ON d.user_id = u.id
    WHERE u.id = ?
    LIMIT 1
");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => false, "message" => "Médico não encontrado"]);
    exit;
}

$doctor = $result->fetch_assoc();

echo json_encode(["status" => true, "data" => $doctor], JSON_UNESCAPED_UNICODE);
?>
