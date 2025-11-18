<?php
include 'cors.php';
include 'db.php';

// Consulta apenas usuários que são pacientes
$sql = "
    SELECT 
        u.id AS user_id,
        u.name,
        u.email,
        p.id AS patient_id,
        p.telefone,
        p.idade,
        p.genero,
        p.endereco,
        p.tipo_sanguineo,
        p.alergias,
        p.medicacoes,
        p.altura,
        p.peso,
        p.foto_perfil,
        p.created_at
    FROM users u
    INNER JOIN patients p ON p.user_id = u.id
    WHERE u.role = 'patient'
    ORDER BY u.name ASC
";

$result = $conn->query($sql);

$patients = [];

while ($row = $result->fetch_assoc()) {
    $patients[] = $row;
}

echo json_encode([
    "status" => true,
    "total" => count($patients),
    "patients" => $patients
], JSON_UNESCAPED_UNICODE);

?>
