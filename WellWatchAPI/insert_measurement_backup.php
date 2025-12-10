<?php
header('Content-Type: application/json; charset=UTF-8');
include 'db.php'; // arquivo com conexão $conn

// ============================================
// LOG DETALHADO DO FLUXO
// ============================================
$log_file = __DIR__ . '/logs/insert_measurement_' . date('Y-m-d') . '.log';
if (!is_dir(__DIR__ . '/logs')) {
    mkdir(__DIR__ . '/logs', 0755, true);
}

function log_detailed($message) {
    global $log_file;
    $timestamp = date('Y-m-d H:i:s.u');
    $log_entry = "[$timestamp] $message\n";
    file_put_contents($log_file, $log_entry, FILE_APPEND);
    error_log("[INSERT_MEASUREMENT] $message");
}

log_detailed("======== NOVA REQUISIÇÃO ========");

// DEBUG: Log da requisição recebida
$raw_input = file_get_contents('php://input');
log_detailed("1️⃣  RAW INPUT RECEBIDO:");
log_detailed("   Length: " . strlen($raw_input) . " bytes");
log_detailed("   Content: " . $raw_input);

$input = json_decode($raw_input, true);
if ($input === null && $raw_input !== '') {
    $json_error = json_last_error_msg();
    log_detailed("❌ ERRO AO DECODIFICAR JSON: $json_error");
    echo json_encode(['status' => false, 'message' => "Erro ao decodificar JSON: $json_error"]);
    exit;
}

log_detailed("2️⃣  VARIÁVEIS DECODIFICADAS:");
log_detailed("   Full Input: " . json_encode($input));

// Extrair variáveis
$patient_id = isset($input['patient_id']) ? (int)$input['patient_id'] : null;
$type_code = $input['type_code'] ?? null;
$recorded_at = $input['recorded_at'] ?? null;
$glucose_value = $input['glucose_value'] ?? null;
$weight_value = $input['weight_value'] ?? null;
$systolic = $input['systolic'] ?? null;
$diastolic = $input['diastolic'] ?? null;
$heart_rate = $input['heart_rate'] ?? null;

log_detailed("3️⃣  VARIÁVEIS EXTRAÍDAS:");
log_detailed("   patient_id: $patient_id (type: " . gettype($patient_id) . ")");
log_detailed("   type_code: $type_code");
log_detailed("   recorded_at: $recorded_at");
log_detailed("   glucose_value: $glucose_value");
log_detailed("   weight_value: $weight_value");
log_detailed("   systolic: $systolic, diastolic: $diastolic, heart_rate: $heart_rate");

// VALIDAÇÃO
log_detailed("4️⃣  VALIDAÇÃO:");
if (!$patient_id) {
    log_detailed("   ❌ patient_id está vazio ou nulo: '$patient_id'");
}
if (!$type_code) {
    log_detailed("   ❌ type_code está vazio ou nulo: '$type_code'");
}
if (!$recorded_at) {
    log_detailed("   ❌ recorded_at está vazio ou nulo: '$recorded_at'");
}

if (!$patient_id || !$type_code || !$recorded_at) {
    log_detailed("❌ VALIDAÇÃO FALHOU - Dados incompletos!");
    echo json_encode(['status' => false, 'message' => 'Dados incompletos', 'details' => [
        'patient_id' => $patient_id,
        'type_code' => $type_code,
        'recorded_at' => $recorded_at
    ]]);
    exit;
}

log_detailed("✅ VALIDAÇÃO PASSOU");

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
        $last_id = $stmt->insert_id;
        error_log("[INSERT_MEASUREMENT] ✅ Sucesso! Medição inserida. ID: $last_id, patient_id: $patient_id, type_code: $type_code");
        echo json_encode(['status' => true, 'message' => 'Medição inserida com sucesso', 'measurement_id' => $last_id]);
    } else {
        error_log("[INSERT_MEASUREMENT] ❌ Erro ao executar query: " . $stmt->error);
        echo json_encode(['status' => false, 'message' => 'Erro ao inserir medição: ' . $stmt->error]);
    }

} catch (Exception $e) {
    echo json_encode(['status' => false, 'message' => $e->getMessage()]);
}
?>
