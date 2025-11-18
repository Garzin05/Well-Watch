<?php
header("Content-Type: application/json");
require_once "config.php";

$patient_id = $_GET['patient_id'] ?? null;

if (!$patient_id) {
    echo json_encode(["status" => false, "message" => "ID do paciente ausente"]);
    exit;
}

$stmt = $pdo->prepare("SELECT id, glucose_value, recorded_at 
                       FROM diabetes_records 
                       WHERE patient_id = ?
                       ORDER BY recorded_at ASC");

$stmt->execute([$patient_id]);
$data = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode([
    "status" => true,
    "total" => count($data),
    "records" => $data
]);
