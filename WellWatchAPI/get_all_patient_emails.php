<?php
// ===========================================
// get_all_patient_emails.php
// Retorna lista de todos os emails de pacientes cadastrados
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

try {
    // Busca todos os emails de pacientes cadastrados
    // role é ENUM('patient','doctor')
    $query = "SELECT id, email, role FROM users WHERE role = 'patient' ORDER BY email ASC";
    
    $stmt = $conn->prepare($query);
    
    if (!$stmt) {
        throw new Exception("Erro na preparação da query: " . $conn->error);
    }
    
    if (!$stmt->execute()) {
        throw new Exception("Erro ao executar query: " . $stmt->error);
    }
    
    $result = $stmt->get_result();
    
    $emails = [];
    while ($row = $result->fetch_assoc()) {
        $emails[] = $row['email'];
    }
    
    // Resposta limpa (sem debug)
    echo json_encode([
        "status" => true,
        "emails" => $emails,
        "total" => count($emails)
    ]);
    
    $stmt->close();
    
} catch (Exception $e) {
    echo json_encode([
        "status" => false,
        "message" => "Erro ao buscar emails: " . $e->getMessage()
    ]);
}

$conn->close();
?>

        "message" => "Erro ao buscar emails: " . $e->getMessage()
    ]);
}

$conn->close();
?>
