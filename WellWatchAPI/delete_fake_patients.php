<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "well_watch";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["status" => false, "message" => "Conexão falhou: " . $conn->connect_error]));
}

// Delete fake patient profiles
$sql = "DELETE FROM users WHERE name IN ('Joao Silva', 'Mario Barros', 'Pedro Oliveira') AND role = 'patient'";

if ($conn->query($sql) === TRUE) {
    $deletedRows = $conn->affected_rows;
    echo json_encode([
        "status" => true, 
        "message" => "Perfis fake removidos com sucesso!",
        "deleted_rows" => $deletedRows
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Erro ao deletar: " . $conn->error
    ]);
}

// Verify remaining patients
$result = $conn->query("SELECT id, name, email, role FROM users WHERE role = 'patient' ORDER BY name");
$patients = [];
while ($row = $result->fetch_assoc()) {
    $patients[] = $row;
}

echo "\n\nPacientes restantes:\n";
echo json_encode($patients, JSON_PRETTY_PRINT);

$conn->close();
?>
