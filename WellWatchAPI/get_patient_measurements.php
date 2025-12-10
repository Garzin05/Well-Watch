<?php
// ===========================================
// get_patient_measurements.php
// Busca todas as medições de um paciente
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

$patient_id = isset($_GET['patient_id']) ? intval($_GET['patient_id']) : null;

if (!$patient_id || $patient_id <= 0) {
    http_response_code(400);
    echo json_encode([
        'status' => false,
        'message' => 'patient_id é obrigatório e deve ser um número válido'
    ]);
    exit;
}

try {
    // Buscar todas as medições do paciente, ordenadas por data (mais recentes primeiro)
    $query = "SELECT id, patient_id, type_id, glucose_value, systolic, diastolic, heart_rate, weight_value, recorded_at, created_at 
              FROM measurements 
              WHERE patient_id = ? 
              ORDER BY recorded_at DESC";
    
    $stmt = $conn->prepare($query);
    
    if (!$stmt) {
        throw new Exception("Erro na preparação da query: " . $conn->error);
    }
    
    $stmt->bind_param("i", $patient_id);
    
    if (!$stmt->execute()) {
        throw new Exception("Erro ao executar query: " . $stmt->error);
    }
    
    $result = $stmt->get_result();
    
    $measurements = [];
    while ($row = $result->fetch_assoc()) {
        // Converter para formato esperado pelo app
        $measurement = [
            'id' => (int)$row['id'],
            'patient_id' => (int)$row['patient_id'],
            'type_id' => (int)$row['type_id'],
            'glucose_value' => $row['glucose_value'] ? (float)$row['glucose_value'] : null,
            'systolic' => $row['systolic'] ? (int)$row['systolic'] : null,
            'diastolic' => $row['diastolic'] ? (int)$row['diastolic'] : null,
            'heart_rate' => $row['heart_rate'] ? (int)$row['heart_rate'] : null,
            'weight_value' => $row['weight_value'] ? (float)$row['weight_value'] : null,
            'recorded_at' => $row['recorded_at'],
            'created_at' => $row['created_at']
        ];
        $measurements[] = $measurement;
    }
    
    http_response_code(200);
    echo json_encode([
        'status' => true,
        'message' => 'Medições recuperadas com sucesso',
        'measurements' => $measurements,
        'count' => count($measurements)
    ]);
    
    $stmt->close();
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => false,
        'message' => 'Erro ao buscar medições: ' . $e->getMessage()
    ]);
}

$conn->close();
?>
