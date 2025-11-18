<?php
// login.php
ob_start();
error_reporting(E_ERROR | E_PARSE);
include 'cors.php';
include 'db.php';

// Lê body JSON ou form-data
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
    echo json_encode(["status" => false, "message" => "E-mail e senha são obrigatórios"]);
    exit;
}

// Buscar usuário
$stmt = $conn->prepare("SELECT id, name, email, password_hash, role FROM users WHERE email = ? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["status" => false, "message" => "Usuário ou senha incorretos"]);
    exit;
}

$user = $result->fetch_assoc();

if (!password_verify($password, $user['password_hash'])) {
    echo json_encode(["status" => false, "message" => "Usuário ou senha incorretos"]);
    exit;
}

// Monta objeto de resposta base
$responseUser = [
    "id"    => (int)$user['id'],
    "name"  => $user['name'],
    "email" => $user['email'],
    "role"  => $user['role']
];

$extraId = null;

// Dados do médico
if ($user['role'] === 'doctor') {
    $stmt2 = $conn->prepare("
        SELECT id, crm, telefone AS phone, especialidade AS specialty, hospital_afiliado AS hospital, data_nascimento, cep
        FROM doctors 
        WHERE user_id = ? LIMIT 1
    ");
    $stmt2->bind_param("i", $user['id']);
    $stmt2->execute();
    $r2 = $stmt2->get_result();

    if ($r2->num_rows > 0) {
        $d = $r2->fetch_assoc();
        $responseUser["crm"] = $d["crm"];
        $responseUser["phone"] = $d["phone"];
        $responseUser["specialty"] = $d["specialty"];
        $responseUser["hospital"] = $d["hospital"];
        $responseUser["data_nascimento"] = $d["data_nascimento"];
        $responseUser["cep"] = $d["cep"];
        $extraId = (int)$d["id"];
    }
}

// Dados do paciente
if ($user['role'] === 'patient') {
    $stmt3 = $conn->prepare("
        SELECT id, telefone AS phone, idade AS age, genero AS gender,
               endereco AS address, tipo_sanguineo AS blood_type,
               alergias AS allergies, medicacoes AS medications,
               altura AS height, peso_inicial AS weight
        FROM patients
        WHERE user_id = ? LIMIT 1
    ");
    $stmt3->bind_param("i", $user['id']);
    $stmt3->execute();
    $r3 = $stmt3->get_result();

    if ($r3->num_rows > 0) {
        $p = $r3->fetch_assoc();
        $responseUser += [
            "phone" => $p["phone"],
            "age" => $p["age"],
            "gender" => $p["gender"],
            "address" => $p["address"],
            "blood_type" => $p["blood_type"],
            "allergies" => $p["allergies"],
            "medications" => $p["medications"],
            "height" => $p["height"],
            "weight" => $p["weight"]
        ];
        $extraId = (int)$p["id"];
    }
}

$response = [
    "status" => true,
    "message" => "Login bem-sucedido",
    "user" => $responseUser
];

if ($extraId !== null) {
    $response[$user["role"] . "_id"] = $extraId;
}

ob_clean();
echo json_encode($response, JSON_UNESCAPED_UNICODE);
ob_end_flush();
?>
