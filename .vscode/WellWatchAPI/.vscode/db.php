<?php
// db.php
$host = "localhost";
$user = "root";
$pass = ""; // ajuste se necessário
$db   = "well_watch";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    header('Content-Type: application/json; charset=UTF-8');
    echo json_encode([
        "status" => false,
        "message" => "Erro ao conectar ao banco",
        "error" => $conn->connect_error
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$conn->set_charset("utf8mb4");
?>
