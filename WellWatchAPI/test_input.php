<?php
header("Content-Type: application/json");

$raw = file_get_contents("php://input");

echo json_encode([
    "received_raw" => $raw,
    "decoded" => json_decode($raw, true)
]);