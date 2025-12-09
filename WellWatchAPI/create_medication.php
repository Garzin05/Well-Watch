<?php
// create_medication.php
include 'db.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);
$patient_id = $data['patient_id'] ?? null;
$name = $data['name'] ?? null;

if (!$patient_id || !$name) {
    http_response_code(400);
    echo json_encode(['status'=>false,'message'=>'patient_id and name required']);
    exit;
}

$dose = $data['dose'] ?? null;
$frequency = $data['frequency'] ?? null;
$instructions = $data['instructions'] ?? null;
$start_date = $data['start_date'] ?? null;
$end_date = $data['end_date'] ?? null;

$stmt = $conn->prepare("INSERT INTO medications (patient_id, name, dose, frequency, instructions, start_date, end_date) VALUES (?,?,?,?,?,?,?)");
$stmt->bind_param("issssss", $patient_id, $name, $dose, $frequency, $instructions, $start_date, $end_date);
$stmt->execute();
echo json_encode(['status'=>true,'medication_id'=>$stmt->insert_id]);
