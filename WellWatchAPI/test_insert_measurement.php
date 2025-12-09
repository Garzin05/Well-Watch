<?php

$url = "http://localhost/WellWatchAPI/insert_measurement.php";

$data = [
    "patient_id" => 1,          // <-- usa o patient_id que você acabou de receber
    "type_code" => "glucose",   // glicose
    "glucose_value" => 110,     // valor de teste
    "recorded_at" => "2025-11-10 15:00:00",
    "notes" => "Teste de glicose automático"
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
