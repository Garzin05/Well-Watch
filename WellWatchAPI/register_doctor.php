<?php
// register_doctor.php
include 'db.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// -----------------------------
// Recebe JSON
// -----------------------------
$data_raw = file_get_contents('php://input');

// Debug opcional
file_put_contents('debug_register_doctor.txt', $data_raw);

// Decodifica JSON
$data = json_decode($data_raw, true);

// -----------------------------
// Campos obrigatórios
// -----------------------------
$name     = $data['name'] ?? null;
$email    = $data['email'] ?? null;
$password = $data['password'] ?? null;
$crm      = $data['crm'] ?? null;

if (!$name || !$email || !$password || !$crm) {
    echo json_encode([
        'status'=>false,
        'message'=>'Campos obrigatórios: name, email, password, crm'
    ]);
    exit;
}

// -----------------------------
// Verifica duplicidade de email ou CRM
// -----------------------------
$stmt = $conn->prepare("SELECT u.id FROM users u JOIN doctors d ON d.user_id = u.id WHERE u.email = ? OR d.crm = ? LIMIT 1");
$stmt->bind_param("ss", $email, $crm);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows > 0) {
    echo json_encode([
        'status'=>false,
        'message'=>'Email ou CRM já cadastrado'
    ]);
    exit;
}

// -----------------------------
// Insere usuário
// -----------------------------
$password_hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $conn->prepare("INSERT INTO users (name,email,password_hash,role,created_at) VALUES (?,?,?,'doctor', NOW())");
$stmt->bind_param("sss", $name, $email, $password_hash);
if (!$stmt->execute()) {
    echo json_encode([
        'status'=>false,
        'message'=>'Erro ao criar usuário',
        'error'=>$stmt->error
    ]);
    exit;
}
$user_id = $stmt->insert_id;

// -----------------------------
// Campos opcionais do médico
// -----------------------------
$telefone        = $data['telefone'] ?? null;
$especialidade   = $data['especialidade'] ?? null;
$data_nascimento = $data['data_nascimento'] ?? null;
$cep             = $data['cep'] ?? null;
$hospital        = $data['hospital'] ?? null;

// Inserir no doctors
$stmt2 = $conn->prepare("INSERT INTO doctors (user_id, crm, telefone, especialidade, data_nascimento, cep, hospital_afiliado) VALUES (?,?,?,?,?,?,?)");
$stmt2->bind_param(
    "issssss",
    $user_id,
    $crm,
    $telefone,
    $especialidade,
    $data_nascimento,
    $cep,
    $hospital
);
$stmt2->execute();
$doctor_id = $stmt2->insert_id;

// -----------------------------
// Retorna sucesso
// -----------------------------
echo json_encode([
    'status'=>true,
    'message'=>'Médico criado com sucesso',
    'user_id'=>$user_id,
    'doctor_id'=>$doctor_id
]);
?>
