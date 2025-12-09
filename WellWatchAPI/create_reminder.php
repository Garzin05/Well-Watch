<?php
// create_reminder.php
include 'db.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);
$patient_id = $data['patient_id'] ?? null;
$medication_id = $data['medication_id'] ?? null;
$title = $data['title'] ?? null;
$remind_at = $data['remind_at'] ?? null;

if (!$patient_id || !$title || !$remind_at) {
    http_response_code(400);
    echo json_encode(['status'=>false,'message'=>'patient_id,title,remind_at required']);
    exit;
}

$repeat_rule = $data['repeat_rule'] ?? null;

$stmt = $conn->prepare("INSERT INTO reminders (patient_id, medication_id, title, description, remind_at, repeat_rule) VALUES (?,?,?,?,?,?)");
$stmt->bind_param("iissss", $patient_id, $medication_id, $title, $data['description'] ?? null, $remind_at, $repeat_rule);
$stmt->execute();
echo json_encode(['status'=>true,'reminder_id'=>$stmt->insert_id]);
