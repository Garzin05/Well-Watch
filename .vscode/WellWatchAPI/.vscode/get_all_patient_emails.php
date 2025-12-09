<?php
// get_all_patient_emails.php
// Fetch all patient emails (DEBUG endpoint)
ob_start();
error_reporting(E_ERROR | E_PARSE);
include 'cors.php';
include 'db.php';

// Query all patient emails
$stmt = $conn->prepare("SELECT email FROM users WHERE role = 'patient' ORDER BY email ASC");
if (!$stmt) {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode([
        "status" => false,
        "message" => "Database error",
        "error" => $conn->error
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$stmt->execute();
$result = $stmt->get_result();

$emails = [];
while ($row = $result->fetch_assoc()) {
    $emails[] = $row['email'];
}

header('Content-Type: application/json; charset=UTF-8');
echo json_encode([
    "status" => true,
    "emails" => $emails,
    "count" => count($emails)
], JSON_UNESCAPED_UNICODE);

$stmt->close();
?>
