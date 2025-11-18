<?php
// register_doctor.php
include 'cors.php';
include 'db.php';

$raw = file_get_contents('php://input');
$raw = trim($raw);
$raw = preg_replace('/^\xEF\xBB\xBF/', '', $raw);
$data = json_decode($raw, true);

if (!is_array($data)) {
    echo json_encode(['status' => false, 'message' => 'JSON inválido']);
    exit;
}

$name     = trim($data['name'] ?? '');
$email    = trim($data['email'] ?? '');
$password = $data['password'] ?? '';
$crm      = trim($data['crm'] ?? '');

if ($name === '' || $email === '' || $password === '' || $crm === '') {
    echo json_encode(['status' => false, 'message' => 'Campos obrigatórios: name, email, password, crm']);
    exit;
}

// Verifica duplicidade de email ou CRM
$stmt = $conn->prepare("SELECT u.id FROM users u JOIN doctors d ON d.user_id = u.id WHERE u.email = ? OR d.crm = ? LIMIT 1");
$stmt->bind_param("ss", $email, $crm);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows > 0) {
    echo json_encode(['status'=>false, 'message'=>'Email ou CRM já cadastrado']);
    exit;
}

// Insere usuário
$password_hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $conn->prepare("INSERT INTO users (name,email,password_hash,role,created_at) VALUES (?,?,?, 'doctor', NOW())");
$stmt->bind_param("sss", $name, $email, $password_hash);
if (!$stmt->execute()) {
    echo json_encode(['status'=>false, 'message'=>'Erro ao criar usuário', 'error'=>$stmt->error]);
    exit;
}
$user_id = $stmt->insert_id;

// Campos opcionais do médico
$telefone        = trim($data['telefone'] ?? '');
$especialidade   = trim($data['especialidade'] ?? '');
$data_nascimento = trim($data['data_nascimento'] ?? '');
$cep             = trim($data['cep'] ?? '');
$hospital        = trim($data['hospital'] ?? '');

// Inserir no doctors
$stmt2 = $conn->prepare("INSERT INTO doctors (user_id, crm, telefone, especialidade, data_nascimento, cep, hospital_afiliado) VALUES (?,?,?,?,?,?,?)");
$stmt2->bind_param("issssss", $user_id, $crm, $telefone, $especialidade, $data_nascimento, $cep, $hospital);

if (!$stmt2->execute()) {
    echo json_encode(['status'=>false, 'message'=>'Erro ao criar registro do médico', 'error'=>$stmt2->error]);
    exit;
}
$doctor_id = $stmt2->insert_id;

echo json_encode([
    'status'=>true,
    'message'=>'Médico criado com sucesso',
    'user_id'=>$user_id,
    'doctor_id'=>$doctor_id
], JSON_UNESCAPED_UNICODE);
?>
