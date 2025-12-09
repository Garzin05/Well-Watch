<?php
include 'db.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Lê JSON do Flutter
$raw = file_get_contents('php://input');
$data = json_decode($raw, true);

if (!isset($data['user_id'])) {
    echo json_encode([
        'status' => false,
        'message' => 'user_id is required'
    ]);
    exit;
}

$user_id = intval($data['user_id']);

// Busca o paciente pelo user_id (não pelo patient_id)
$stmt = $conn->prepare("SELECT 
        p.id AS patient_id,
        u.name,
        u.email,
        p.telefone,
        p.idade AS age,
        p.altura AS height,
        p.peso_inicial AS weight
    FROM patients p
    JOIN users u ON u.id = p.user_id
    WHERE p.user_id = ?
    LIMIT 1");

$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
    echo json_encode([
        'status' => false,
        'message' => 'Paciente não encontrado'
    ]);
    exit;
}

$data = $res->fetch_assoc();

echo json_encode([
    'status' => true,
    'data' => $data
]);

?>
