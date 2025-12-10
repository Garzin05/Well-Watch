<?php
header('Content-Type: application/json; charset=UTF-8');
include 'db.php'; // arquivo com conexão $conn

// ============================================
// LOGGING EXTREMAMENTE DETALHADO
// ============================================
$log_dir = __DIR__ . '/logs';
if (!is_dir($log_dir)) {
    mkdir($log_dir, 0755, true);
}

$log_file = $log_dir . '/insert_measurement_' . date('Y-m-d') . '.log';

function log_msg($msg) {
    global $log_file;
    $timestamp = date('Y-m-d H:i:s.u');
    $entry = "[$timestamp] $msg\n";
    file_put_contents($log_file, $entry, FILE_APPEND);
    error_log("[INSERT_MEASUREMENT] $msg");
}

log_msg("================== INÍCIO DA REQUISIÇÃO ==================");
log_msg("Horário: " . date('Y-m-d H:i:s'));
log_msg("User-Agent: " . ($_SERVER['HTTP_USER_AGENT'] ?? 'UNKNOWN'));
log_msg("IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN'));

// ============================================
// 1. LER O INPUT
// ============================================
log_msg("STEP 1: Lendo input bruto");
$raw_input = file_get_contents('php://input');
log_msg("  - Length: " . strlen($raw_input) . " bytes");
log_msg("  - Content-Type Header: " . ($_SERVER['CONTENT_TYPE'] ?? 'NONE'));

if (strlen($raw_input) == 0) {
    log_msg("  ❌ INPUT VAZIO!");
    log_msg("  - GET: " . json_encode($_GET));
    log_msg("  - POST: " . json_encode($_POST));
}

log_msg("  - Raw Content (primeiro 500 chars): " . substr($raw_input, 0, 500));

// ============================================
// 2. DECODIFICAR JSON
// ============================================
log_msg("STEP 2: Decodificando JSON");
$input = json_decode($raw_input, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    $json_error = json_last_error_msg();
    log_msg("  ❌ ERRO JSON: $json_error (Code: " . json_last_error() . ")");
    http_response_code(400);
    echo json_encode([
        'status' => false,
        'message' => "Erro ao decodificar JSON: $json_error",
        'received' => substr($raw_input, 0, 200)
    ]);
    exit;
}

if ($input === null) {
    log_msg("  ❌ JSON decodificou para NULL!");
    http_response_code(400);
    echo json_encode(['status' => false, 'message' => 'JSON inválido']);
    exit;
}

log_msg("  ✅ JSON decodificado com sucesso");
log_msg("  - Chaves: " . json_encode(array_keys($input)));

// ============================================
// 3. EXTRAIR E VALIDAR VARIÁVEIS
// ============================================
log_msg("STEP 3: Extraindo variáveis");

$patient_id = isset($input['patient_id']) ? (int)$input['patient_id'] : null;
$type_code = $input['type_code'] ?? null;
$recorded_at = $input['recorded_at'] ?? null;
$glucose_value = $input['glucose_value'] ?? null;
$weight_value = $input['weight_value'] ?? null;
$systolic = $input['systolic'] ?? null;
$diastolic = $input['diastolic'] ?? null;
$heart_rate = $input['heart_rate'] ?? null;

log_msg("  - patient_id: $patient_id (type: " . gettype($patient_id) . ", valor bruto: " . json_encode($input['patient_id'] ?? 'NOT_SET') . ")");
log_msg("  - type_code: $type_code (type: " . gettype($type_code) . ")");
log_msg("  - recorded_at: $recorded_at (type: " . gettype($recorded_at) . ")");
log_msg("  - glucose_value: $glucose_value (type: " . gettype($glucose_value) . ")");
log_msg("  - weight_value: $weight_value (type: " . gettype($weight_value) . ")");
log_msg("  - systolic: $systolic, diastolic: $diastolic, heart_rate: $heart_rate");

log_msg("STEP 4: Validação inicial");

if (!$patient_id) {
    log_msg("  ❌ patient_id inválido: '$patient_id' (vazio ou zero)");
}
if (!$type_code) {
    log_msg("  ❌ type_code inválido: '$type_code' (vazio)");
}
if (!$recorded_at) {
    log_msg("  ❌ recorded_at inválido: '$recorded_at' (vazio)");
}

if (!$patient_id || !$type_code || !$recorded_at) {
    log_msg("❌ VALIDAÇÃO INICIAL FALHOU!");
    http_response_code(400);
    echo json_encode([
        'status' => false,
        'message' => 'Dados obrigatórios faltando',
        'received' => [
            'patient_id' => $patient_id,
            'type_code' => $type_code,
            'recorded_at' => $recorded_at
        ]
    ]);
    exit;
}

log_msg("  ✅ Validação inicial passou");

// ============================================
// 5. PREPARAR STATEMENT SQL
// ============================================
log_msg("STEP 5: Preparando statement SQL para type_code='$type_code'");

try {
    if ($type_code === 'glucose') {
        log_msg("  - Type: GLUCOSE");
        
        if ($glucose_value === null) {
            log_msg("  ❌ glucose_value é nulo!");
            http_response_code(400);
            echo json_encode(['status' => false, 'message' => 'glucose_value faltando']);
            exit;
        }
        
        log_msg("  - glucose_value: $glucose_value");
        
        $query = "INSERT INTO measurements (patient_id, type_id, glucose_value, recorded_at, created_at) VALUES (?, ?, ?, ?, NOW())";
        log_msg("  - Query: $query");
        log_msg("  - Tipo de bind: idds (int, int, double, string)");
        log_msg("  - Valores para bind: patient_id=$patient_id, type_id=1, glucose_value=$glucose_value, recorded_at=$recorded_at");
        
        $stmt = $conn->prepare($query);
        if (!$stmt) {
            log_msg("  ❌ ERRO ao preparar statement: " . $conn->error);
            http_response_code(500);
            echo json_encode(['status' => false, 'message' => 'Erro ao preparar SQL: ' . $conn->error]);
            exit;
        }
        log_msg("  ✅ Statement preparado");
        
        $type_id = 1;
        $bind_result = $stmt->bind_param("idds", $patient_id, $type_id, $glucose_value, $recorded_at);
        if (!$bind_result) {
            log_msg("  ❌ ERRO ao fazer bind_param: " . $stmt->error);
            http_response_code(500);
            echo json_encode(['status' => false, 'message' => 'Erro ao fazer bind: ' . $stmt->error]);
            exit;
        }
        log_msg("  ✅ Bind executado");

    } elseif ($type_code === 'weight') {
        log_msg("  - Type: WEIGHT");
        
        if ($weight_value === null) {
            log_msg("  ❌ weight_value é nulo!");
            http_response_code(400);
            echo json_encode(['status' => false, 'message' => 'weight_value faltando']);
            exit;
        }
        
        log_msg("  - weight_value: $weight_value");
        
        $query = "INSERT INTO measurements (patient_id, type_id, weight_value, recorded_at, created_at) VALUES (?, ?, ?, ?, NOW())";
        log_msg("  - Query: $query");
        log_msg("  - Tipo de bind: idds");
        log_msg("  - Valores para bind: patient_id=$patient_id, type_id=3, weight_value=$weight_value, recorded_at=$recorded_at");
        
        $stmt = $conn->prepare($query);
        if (!$stmt) {
            log_msg("  ❌ ERRO ao preparar statement: " . $conn->error);
            http_response_code(500);
            echo json_encode(['status' => false, 'message' => 'Erro ao preparar SQL: ' . $conn->error]);
            exit;
        }
        log_msg("  ✅ Statement preparado");
        
        $type_id = 3;
        $bind_result = $stmt->bind_param("idds", $patient_id, $type_id, $weight_value, $recorded_at);
        if (!$bind_result) {
            log_msg("  ❌ ERRO ao fazer bind_param: " . $stmt->error);
            http_response_code(500);
            echo json_encode(['status' => false, 'message' => 'Erro ao fazer bind: ' . $stmt->error]);
            exit;
        }
        log_msg("  ✅ Bind executado");

    } elseif ($type_code === 'pressure') {
        log_msg("  - Type: PRESSURE");
        
        if ($systolic === null || $diastolic === null || $heart_rate === null) {
            log_msg("  ❌ Um ou mais valores faltando!");
            http_response_code(400);
            echo json_encode(['status' => false, 'message' => 'Valores de pressão faltando']);
            exit;
        }
        
        log_msg("  - systolic: $systolic, diastolic: $diastolic, heart_rate: $heart_rate");
        
        $query = "INSERT INTO measurements (patient_id, type_id, systolic, diastolic, heart_rate, recorded_at, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())";
        log_msg("  - Query: $query");
        log_msg("  - Tipo de bind: iiiiis");
        log_msg("  - Valores para bind: patient_id=$patient_id, type_id=2, systolic=$systolic, diastolic=$diastolic, heart_rate=$heart_rate, recorded_at=$recorded_at");
        
        $stmt = $conn->prepare($query);
        if (!$stmt) {
            log_msg("  ❌ ERRO ao preparar statement: " . $conn->error);
            http_response_code(500);
            echo json_encode(['status' => false, 'message' => 'Erro ao preparar SQL: ' . $conn->error]);
            exit;
        }
        log_msg("  ✅ Statement preparado");
        
        $type_id = 2;
        $bind_result = $stmt->bind_param("iiiiis", $patient_id, $type_id, $systolic, $diastolic, $heart_rate, $recorded_at);
        if (!$bind_result) {
            log_msg("  ❌ ERRO ao fazer bind_param: " . $stmt->error);
            http_response_code(500);
            echo json_encode(['status' => false, 'message' => 'Erro ao fazer bind: ' . $stmt->error]);
            exit;
        }
        log_msg("  ✅ Bind executado");

    } else {
        log_msg("  ❌ type_code inválido: '$type_code'");
        http_response_code(400);
        echo json_encode(['status' => false, 'message' => 'type_code inválido']);
        exit;
    }

    // ============================================
    // 6. EXECUTAR STATEMENT
    // ============================================
    log_msg("STEP 6: Executando statement SQL");
    
    $execute_result = $stmt->execute();
    
    if ($execute_result) {
        $last_id = $stmt->insert_id;
        log_msg("✅✅✅ SUCESSO! MEDIÇÃO INSERIDA COM SUCESSO!");
        log_msg("  - Measurement ID (insert_id): $last_id");
        log_msg("  - Patient ID: $patient_id");
        log_msg("  - Type Code: $type_code");
        log_msg("  - Recorded At: $recorded_at");
        log_msg("  - Affected Rows: " . $stmt->affected_rows);
        
        http_response_code(200);
        echo json_encode([
            'status' => true,
            'message' => 'Medição inserida com sucesso',
            'measurement_id' => $last_id,
            'patient_id' => $patient_id,
            'type_code' => $type_code
        ]);
    } else {
        log_msg("❌ ERRO AO EXECUTAR STATEMENT!");
        log_msg("  - Error: " . $stmt->error);
        log_msg("  - Errno: " . $stmt->errno);
        log_msg("  - Sqlstate: " . $stmt->sqlstate);
        
        http_response_code(500);
        echo json_encode([
            'status' => false,
            'message' => 'Erro ao inserir no banco de dados',
            'error' => $stmt->error,
            'error_code' => $stmt->errno
        ]);
    }
    
    $stmt->close();

} catch (Exception $e) {
    log_msg("❌ EXCEÇÃO CAPTURADA!");
    log_msg("  - Message: " . $e->getMessage());
    log_msg("  - Code: " . $e->getCode());
    log_msg("  - File: " . $e->getFile());
    log_msg("  - Line: " . $e->getLine());
    
    http_response_code(500);
    echo json_encode([
        'status' => false,
        'message' => 'Erro: ' . $e->getMessage(),
        'code' => $e->getCode()
    ]);
}

log_msg("================== FIM DA REQUISIÇÃO ==================\n");
?>
