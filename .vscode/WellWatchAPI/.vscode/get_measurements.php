<?php
// get_measurements.php
include 'db.php';
header('Content-Type: application/json');

$patient_id = $_GET['patient_id'] ?? null;
$type_code = $_GET['type_code'] ?? null;

if (!$patient_id) {
    http_response_code(400);
    echo json_encode(['status'=>false,'message'=>'patient_id required']);
    exit;
}

$sql = "SELECT m.*, mt.code AS type_code, mt.label AS type_label FROM measurements m JOIN measurement_types mt ON m.type_id = mt.id WHERE m.patient_id = ?";
$params = [$patient_id];
if ($type_code) {
    $sql .= " AND mt.code = ?";
    $params[] = $type_code;
}
$sql .= " ORDER BY m.recorded_at DESC LIMIT 100";

$stmt = $conn->prepare($sql);
if (count($params) === 1) $stmt->bind_param("i", $params[0]);
else $stmt->bind_param("is", $params[0], $params[1]);
$stmt->execute();
$res = $stmt->get_result();
$data = $res->fetch_all(MYSQLI_ASSOC);
echo json_encode(['status'=>true,'data'=>$data]);
