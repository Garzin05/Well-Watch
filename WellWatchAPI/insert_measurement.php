<?php
header('Content-Type: application/json');
include 'db.php'; // arquivo com conexão $conn

$input = json_decode(file_get_contents('php://input'), true);

$patient_id = isset($input['patient_id']) ? (int)$input['patient_id'] : null;
$type_code = $input['type_code'] ?? null;
$recorded_at = $input['recorded_at'] ?? null;

if (!$patient_id || !$type_code || !$recorded_at) {
    echo json_encode(['status' => false, 'message' => 'Dados incompletos']);
    exit;
}

try {
    if ($type_code === 'glucose') {
        $glucose_value = isset($input['glucose_value']) ? (float)$input['glucose_value'] : null;
        if ($glucose_value === null) {
            echo json_encode(['status' => false, 'message' => 'Valor de glicose faltando']);
            exit;
        }
        $stmt = $conn->prepare("INSERT INTO measurements (patient_id, type_id, glucose_value, recorded_at, created_at) VALUES (?, ?, ?, ?, NOW())");
        $type_id = 1; // 1 = glucose
        $stmt->bind_param("idds", $patient_id, $type_id, $glucose_value, $recorded_at);

    } elseif ($type_code === 'weight') {
        $weight_value = isset($input['weight_value']) ? (float)$input['weight_value'] : null;
        if ($weight_value === null) {
            echo json_encode(['status' => false, 'message' => 'Valor de peso faltando']);
            exit;
        }
        $stmt = $conn->prepare("INSERT INTO measurements (patient_id, type_id, weight_value, recorded_at, created_at) VALUES (?, ?, ?, ?, NOW())");
        $type_id = 3; // 3 = weight
        $stmt->bind_param("idds", $patient_id, $type_id, $weight_value, $recorded_at);

    } elseif ($type_code === 'pressure') {
        $systolic = isset($input['systolic']) ? (int)$input['systolic'] : null;
        $diastolic = isset($input['diastolic']) ? (int)$input['diastolic'] : null;
        $heart_rate = isset($input['heart_rate']) ? (int)$input['heart_rate'] : null;
        if ($systolic === null || $diastolic === null || $heart_rate === null) {
            echo json_encode(['status' => false, 'message' => 'Valores de pressão faltando']);
            exit;
        }
        $stmt = $conn->prepare("INSERT INTO measurements (patient_id, type_id, systolic, diastolic, heart_rate, recorded_at, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())");
        $type_id = 2; // 2 = pressure
        $stmt->bind_param("iiiiis", $patient_id, $type_id, $systolic, $diastolic, $heart_rate, $recorded_at);

    } else {
        echo json_encode(['status' => false, 'message' => 'Tipo inválido']);
        exit;
    }

    if ($stmt->execute()) {
        echo json_encode(['status' => true, 'message' => 'Medição inserida com sucesso']);
    } else {
        echo json_encode(['status' => false, 'message' => 'Erro ao inserir medição: ' . $stmt->error]);
    }

} catch (Exception $e) {
    echo json_encode(['status' => false, 'message' => $e->getMessage()]);
}
?>
