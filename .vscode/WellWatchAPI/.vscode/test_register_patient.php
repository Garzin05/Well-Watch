<?php

$url = "http://localhost/WellWatchAPI/register_patient.php";

$data = [
    "name" => "Victor Completo",
    "email" => "victor.completo@teste.com",
    "password" => "123456",
    "telefone" => "11999999999",
    "idade" => 25,
    "genero" => "masculino",
    "endereco" => "Rua teste 123",
    "tipo_sanguineo" => "O+",
    "alergias" => "Nenhuma",
    "medicacoes_atuais" => "Nenhuma",
    "altura" => 1.75,
    "peso_inicial" => 70
];

$options = [
    "http" => [
        "header" => "Content-Type: application/json",
        "method" => "POST",
        "content" => json_encode($data)
    ]
];

$context = stream_context_create($options);
$result = file_get_contents($url, false, $context);

echo $result;
