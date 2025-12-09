<?php
// ===========================================
// get_patient_by_email.php
// Busca um paciente específico por email
// ===========================================

header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    echo json_encode(["status" => true]);
    exit;
}

include 'db.php';

// Captura o email do parâmetro GET
$email = trim($_GET['email'] ?? '');

if (empty($email)) {
    echo json_encode([
        "status" => false,
        "message" => "Email não fornecido"
    ]);
    exit;
}

try {
    // Busca paciente por email (role é ENUM)
    $query = "SELECT id, name, email, role FROM users WHERE email = ? AND role = 'patient' LIMIT 1";
    
    $stmt = $conn->prepare($query);
    
    if (!$stmt) {
        throw new Exception("Erro na preparação da query: " . $conn->error);
    }
    
    $stmt->bind_param("s", $email);
    
    if (!$stmt->execute()) {
        throw new Exception("Erro ao executar query: " . $stmt->error);
    }
    
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode([
            "status" => false,
            "message" => "Paciente não encontrado"
        ]);
        exit;
    }
    
    $patient = $result->fetch_assoc();
    
    echo json_encode([
        "status" => true,
        "patient" => [
            "id" => (int)$patient['id'],
            "name" => $patient['name'],
            "email" => $patient['email'],
            "role" => $patient['role']
        ]
    ]);
    
    $stmt->close();
    
} catch (Exception $e) {
    echo json_encode([
        "status" => false,
        "message" => "Erro ao buscar paciente: " . $e->getMessage()
    ]);
}

$conn->close();
?>
