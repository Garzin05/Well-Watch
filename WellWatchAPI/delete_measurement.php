<?php
header('Content-Type: application/json');
include 'db.php'; // arquivo com conexão $conn

$input = json_decode(file_get_contents('php://input'), true);

$patient_id = $input['patient_id'] ?? null;
$type_code = $input['type_code'] ?? null;
$recorded_at = $input['recorded_at'] ?? null;

if (!$patient_id || !$type_code || !$recorded_at) {
    echo json_encode(['status' => false, 'message' => 'Dados incompletos']);
    exit;
}

try {
    $stmt = $conn->prepare("DELETE FROM measurements WHERE patient_id=? AND type_code=? AND recorded_at=?");
    $stmt->bind_param("iss", $patient_id, $type_code, $recorded_at);

    if ($stmt->execute()) {
        echo json_encode(['status' => true, 'message' => 'Medição removida com sucesso']);
    } else {
        echo json_encode(['status' => false, 'message' => 'Erro ao remover medição']);
    }
} catch (Exception $e) {
    echo json_encode(['status' => false, 'message' => $e->getMessage()]);
}
?>
