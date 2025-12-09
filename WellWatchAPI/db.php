<?php
$host = "localhost"; // MySQL local
$user = "root";      // ou seu usuário
$pass = "";          // senha do XAMPP normalmente é vazia
$db   = "well_watch"; // corrigido underline

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "status" => false,
        "message" => "Erro ao conectar ao banco",
        "error" => $conn->connect_error
    ]));
}

$conn->set_charset("utf8mb4");
?>
