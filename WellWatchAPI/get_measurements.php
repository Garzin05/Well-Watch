<?php
// get_measurements.php
include 'db.php';
header('Content-Type: application/json');

// AUDITORIA - Log de entrada
$log_dir = __DIR__ . '/logs';
if (!is_dir($log_dir)) mkdir($log_dir, 0755, true);
$log_file = $log_dir . '/get_measurements_' . date('Y-m-d') . '.log';

function audit_log($msg) {
    global $log_file;
    $timestamp = date('Y-m-d H:i:s.u');
    file_put_contents($log_file, "[$timestamp] $msg\n", FILE_APPEND);
}

audit_log("========== REQUISICAO RECEBIDA ==========");
audit_log("GET params: patient_id=" . ($_GET['patient_id'] ?? 'NULL') . ", type_code=" . ($_GET['type_code'] ?? 'NULL'));

$patient_id = $_GET['patient_id'] ?? null;
$type_code = $_GET['type_code'] ?? null;

audit_log("Validacao: patient_id=$patient_id, type_code=$type_code");

if (!$patient_id) {
    audit_log("ERRO: patient_id nao fornecido");
    http_response_code(400);
    echo json_encode(['status'=>false, 'message'=>'patient_id required']);
    exit;
}

// Validate patient_id is numeric
if (!is_numeric($patient_id)) {
    audit_log("ERRO: patient_id nao e numerico: $patient_id");
    http_response_code(400);
    echo json_encode(['status'=>false, 'message'=>'Invalid patient_id']);
    exit;
}

audit_log("Validacao passou. Construindo SQL...");

$sql = "SELECT m.*, mt.code AS type_code, mt.label AS type_label FROM measurements m JOIN measurement_types mt ON m.type_id = mt.id WHERE m.patient_id = ?";
$params = [$patient_id];

if ($type_code) {
    audit_log("Filtrando por type_code: $type_code");
    $sql .= " AND mt.code = ?";
    $params[] = $type_code;
}

$sql .= " ORDER BY m.recorded_at DESC LIMIT 100";

audit_log("SQL Query: $sql");
audit_log("Parametros: " . json_encode($params));

$stmt = $conn->prepare($sql);

if (!$stmt) {
    audit_log("ERRO ao preparar statement: " . $conn->error);
    http_response_code(500);
    echo json_encode(['status'=>false, 'message'=>'SQL prepare error: ' . $conn->error]);
    exit;
}

if (count($params) === 1) {
    audit_log("Bindando 1 parametro (int): " . $params[0]);
    $stmt->bind_param("i", $params[0]);
} else {
    audit_log("Bindando 2 parametros (int, string): " . $params[0] . ", " . $params[1]);
    $stmt->bind_param("is", $params[0], $params[1]);
}

audit_log("Executando statement...");
if (!$stmt->execute()) {
    audit_log("ERRO ao executar statement: " . $stmt->error);
    http_response_code(500);
    echo json_encode(['status'=>false, 'message'=>'SQL execute error: ' . $stmt->error]);
    exit;
}

$res = $stmt->get_result();
$measurements = $res->fetch_all(MYSQLI_ASSOC);

audit_log("Query executada com sucesso. Linhas encontradas: " . count($measurements));

if (count($measurements) > 0) {
    audit_log("Primeiras 3 medições:");
    for ($i = 0; $i < min(3, count($measurements)); $i++) {
        audit_log("  [$i] " . json_encode($measurements[$i]));
    }
} else {
    audit_log("NENHUMA MEDICAO ENCONTRADA!");
}

// Format response
$result = [
    'status' => true,
    'measurements' => $measurements,
    'total' => count($measurements)
];

audit_log("Resposta JSON sendo enviada:");
audit_log("Status: " . $result['status']);
audit_log("Total de medicoes: " . $result['total']);
audit_log("JSON completo: " . json_encode($result));
audit_log("========== FIM DA REQUISICAO ==========\n");

echo json_encode($result, JSON_PRETTY_PRINT);
$stmt->close();
$conn->close();
?>
