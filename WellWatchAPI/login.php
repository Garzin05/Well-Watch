<?php
// ===========================================
// login.php — versão FINAL, 100% funcional para novos cadastros
// ===========================================

ob_start();
error_reporting(E_ERROR | E_PARSE);

header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    echo json_encode(["status" => true]);
    exit;
}

include 'db.php';

// ===========================================
// 1️⃣ LER BODY (JSON ou form-data)
// ===========================================
$raw = file_get_contents("php://input");
$raw = trim($raw);
$raw = preg_replace('/^\xEF\xBB\xBF/', '', $raw);

$data = json_decode($raw, true);

if (is_array($data)) {
    $email = trim($data['email'] ?? '');
    $password = $data['password'] ?? '';
} else {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
}

if (!$email || !$password) {
    echo json_encode([
        "status" => false,
        "message" => "E-mail ou senha inválidos"
    ]);
    exit;
}

// ===========================================
// 2️⃣ BUSCAR USUÁRIO
// ===========================================
$stmt = $conn->prepare("
    SELECT id, name, email, password_hash, role 
    FROM users 
    WHERE email = ? LIMIT 1
");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "status" => false,
        "message" => "Usuário ou senha inválidos"
    ]);
    exit;
}

$user = $result->fetch_assoc();

// ===========================================
// 3️⃣ VALIDAR SENHA
// ===========================================
if (!password_verify($password, $user['password_hash'])) {
    echo json_encode([
        "status" => false,
        "message" => "Usuário ou senha inválidos"
    ]);
    exit;
}

// ===========================================
// 4️⃣ MONTAR RESPONSE
// ===========================================
$responseUser = [
    "id" => (int)$user['id'],
    "name" => $user['name'],
    "email" => $user['email'],
    "role" => $user['role']
];

$extraId = null;

// ===========================================
// 5️⃣ DADOS DE DOCTOR
// ===========================================
if ($user['role'] === 'doctor') {
    $stmt2 = $conn->prepare("
        SELECT id, crm, phone, specialty 
        FROM doctors 
        WHERE user_id = ? LIMIT 1
    ");
    $stmt2->bind_param("i", $user['id']);
    $stmt2->execute();
    $r2 = $stmt2->get_result();

    if ($r2->num_rows > 0) {
        $doctor = $r2->fetch_assoc();
        // Substitui todos os dados com valores do banco
        $responseUser['id'] = (int)$user['id'];
        $responseUser['name'] = $user['name'];
        $responseUser['email'] = $user['email'];
        $responseUser['role'] = $user['role'];
        $responseUser['crm'] = $doctor['crm'];
        $responseUser['phone'] = $doctor['phone'];
        $responseUser['specialty'] = $doctor['specialty'];
        $extraId = (int)$doctor['id'];
    }
}

// ===========================================
// 6️⃣ DADOS DE PACIENTE
// ===========================================
else {
    $stmt3 = $conn->prepare("
        SELECT id, telefone, idade, genero, endereco, 
               tipo_sanguineo, alergias, medicacoes, altura, peso 
        FROM patients 
        WHERE user_id = ? LIMIT 1
    ");
    $stmt3->bind_param("i", $user['id']);
    $stmt3->execute();
    $r3 = $stmt3->get_result();

    if ($r3->num_rows > 0) {
        $p = $r3->fetch_assoc();
        $responseUser += [
            "phone" => $p['telefone'],
            "age" => $p['idade'],
            "gender" => $p['genero'],
            "address" => $p['endereco'],
            "blood_type" => $p['tipo_sanguineo'],
            "allergies" => $p['alergias'],
            "medications" => $p['medicacoes'],
            "height" => $p['altura'],
            "weight" => $p['peso']
        ];
        $extraId = (int)$p['id'];
    }
}

// ===========================================
// 7️⃣ RESPOSTA FINAL
// ===========================================
$response = [
    "status" => true,
    "message" => "Login bem-sucedido",
    "user" => $responseUser
];

if ($extraId !== null) {
    $response[$user['role'] . "_id"] = $extraId;
}

ob_clean();
echo json_encode($response, JSON_UNESCAPED_UNICODE);
ob_end_flush();
?>
