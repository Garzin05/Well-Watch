<?php

$url = "http://localhost/WellWatchAPI/login.php";

$data = [
    "identifier" => "victor@teste.com",
    "password"   => "123456",
    "role"       => "patient"
];

$options = [
    "http" => [
        "header"  => "Content-Type: application/json",
        "method"  => "POST",
        "content" => json_encode($data),
    ],
];

$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);

echo $result;