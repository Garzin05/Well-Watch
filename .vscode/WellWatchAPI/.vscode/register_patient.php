<?php
include 'db.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// -----------------------------
// Recebe JSON de forma segura
// -----------------------------
$raw = file_get_contents('php://input');
$data = json_decode($raw, true);

// Depuração
file_put_contents('debug_register_patient.txt', $raw);

// Caso não consiga decodificar JSON
if (!is_array($data)) {
    echo json_encode([
        'status' => false,
        'message' => 'JSON inválido ou corpo vazio',
        'received_raw' => $raw
    ]);
    exit;
}

// -----------------------------
// Captura os dados
// -----------------------------
$name     = trim($data['name'] ?? '');
$email    = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

// Verificação básica
if ($name === '' || $email === '' || $password === '') {
    echo json_encode([
        'status' => false,
        'message' => 'Campos obrigatórios: name, email, password',
        'received' => $data
    ]);
    exit;
}

// -----------------------------
// Verifica se email já existe
// -----------------------------
$stmt = $conn->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$res = $stmt->get_result();
if ($res->num_rows > 0) {
    echo json_encode([
        'status'=>false,
        'message'=>'Email já cadastrado'
    ]);
    exit;
}

// -----------------------------
// Insere usuário
// -----------------------------
$password_hash = password_hash($password, PASSWORD_DEFAULT);
$stmt = $conn->prepare("INSERT INTO users (name,email,password_hash,role,created_at) VALUES (?,?,?, 'patient', NOW())");
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
// Campos opcionais do paciente
// -----------------------------
$telefone         = $data['telefone'] ?? null;
$idade            = $data['idade'] ?? null;
$genero           = $data['genero'] ?? null;
$endereco         = $data['endereco'] ?? null;
$tipo_sanguineo   = $data['tipo_sanguineo'] ?? null;
$alergias         = $data['alergias'] ?? null;
$medicacoes_atuais= $data['medicacoes_atuais'] ?? null;
$altura           = $data['altura'] ?? null;
$peso_inicial     = $data['peso_inicial'] ?? null;

// Inserir no patients
$stmt2 = $conn->prepare("INSERT INTO patients (user_id, telefone, idade, genero, endereco, tipo_sanguineo, alergias, medicacoes_atuais, altura, peso_inicial) VALUES (?,?,?,?,?,?,?,?,?,?)");
$stmt2->bind_param(
    "isissssdds",
    $user_id,
    $telefone,
    $idade,
    $genero,
    $endereco,
    $tipo_sanguineo,
    $alergias,
    $medicacoes_atuais,
    $altura,
    $peso_inicial
);
$stmt2->execute();
$patient_id = $stmt2->insert_id;

// -----------------------------
// Retorna sucesso
// -----------------------------
echo json_encode([
    'status'=>true,
    'message'=>'Paciente criado com sucesso',
    'user_id'=>$user_id,
    'patient_id'=>$patient_id
]);
?>

