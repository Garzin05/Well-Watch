<?php
// create_appointment.php
include 'db.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);
$patient_id = $data['patient_id'] ?? null;
$doctor_id = $data['doctor_id'] ?? null;
$scheduled_at = $data['scheduled_at'] ?? null;
$title = $data['title'] ?? 'Consulta';

if (!$patient_id || !$doctor_id || !$scheduled_at) {
    http_response_code(400);
    echo json_encode(['status'=>false,'message'=>'patient_id, doctor_id and scheduled_at required']);
    exit;
}

$stmt = $conn->prepare("INSERT INTO appointments (patient_id, doctor_id, title, scheduled_at) VALUES (?,?,?,?)");
$stmt->bind_param("iiss", $patient_id, $doctor_id, $title, $scheduled_at);
$stmt->execute();
echo json_encode(['status'=>true,'appointment_id'=>$stmt->insert_id]);
