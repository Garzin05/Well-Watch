<?php
// link_doctor_patient.php
include 'db.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);
$doctor_id = $data['doctor_id'] ?? null;
$patient_id = $data['patient_id'] ?? null;

if (!$doctor_id || !$patient_id) {
    http_response_code(400);
    echo json_encode(['status'=>false,'message'=>'doctor_id and patient_id required']);
    exit;
}

$stmt = $conn->prepare("INSERT IGNORE INTO doctor_patient (doctor_id, patient_id) VALUES (?,?)");
$stmt->bind_param("ii", $doctor_id, $patient_id);
$stmt->execute();
echo json_encode(['status'=>true,'message'=>'Vinculado']);
