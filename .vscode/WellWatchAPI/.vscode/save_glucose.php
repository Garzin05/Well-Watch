<?php
header("Content-Type: application/json");
require_once "config.php";

$patient_id = $_POST['patient_id'] ?? null;
$glucose = $_POST['glucose_value'] ?? null;

if (!$patient_id || !$glucose) {
    echo json_encode(["status" => false, "message" => "Dados incompletos"]);
    exit;
}

$stmt = $pdo->prepare("INSERT INTO diabetes_records (patient_id, glucose_value) VALUES (?, ?)");
$ok = $stmt->execute([$patient_id, $glucose]);

echo json_encode([
    "status" => $ok,
    "message" => $ok ? "Registro salvo" : "Erro ao salvar"
]);
