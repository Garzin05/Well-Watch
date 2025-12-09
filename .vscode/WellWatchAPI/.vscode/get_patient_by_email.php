<?php
// get_patient_by_email.php
// Fetch patient data by email (case-insensitive)
ob_start();
error_reporting(E_ERROR | E_PARSE);
include 'cors.php';
include 'db.php';

// Get email parameter from GET request
$email = trim($_GET['email'] ?? '');

// Validate email parameter
if (!$email) {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode([
        "status" => false,
        "message" => "Email parameter is required"
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Query patient by email (case-insensitive)
$stmt = $conn->prepare("SELECT id, name, email, role, created_at FROM users WHERE LOWER(email) = LOWER(?) AND role = 'patient' LIMIT 1");
if (!$stmt) {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode([
        "status" => false,
        "message" => "Database error",
        "error" => $conn->error
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode([
        "status" => false,
        "message" => "Patient not found"
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$patient = $result->fetch_assoc();

// Get additional patient profile data if exists
$stmtProfile = $conn->prepare("SELECT telefone, idade, genero, endereco, cidade FROM patients WHERE user_id = ? LIMIT 1");
if ($stmtProfile) {
    $stmtProfile->bind_param("i", $patient['id']);
    $stmtProfile->execute();
    $profileResult = $stmtProfile->get_result();
    
    if ($profileResult->num_rows > 0) {
        $profileData = $profileResult->fetch_assoc();
        $patient = array_merge($patient, $profileData);
    }
    $stmtProfile->close();
}

header('Content-Type: application/json; charset=UTF-8');
echo json_encode([
    "status" => true,
    "patient" => $patient
], JSON_UNESCAPED_UNICODE);

$stmt->close();
?>
