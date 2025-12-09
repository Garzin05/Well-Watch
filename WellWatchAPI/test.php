<?php
$host = "localhost";
$user = "Welluser"; 
$pass = "123456";
$db   = "well-watch";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Erro ao conectar: " . $conn->connect_error);
}

echo "Conexão OK!";
?>