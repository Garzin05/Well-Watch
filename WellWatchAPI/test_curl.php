<?php
// Test_curl.php - Testa os endpoints diretamente via cURL

$baseUrl = "http://localhost/WellWatchAPI";

echo "=== Testando Endpoints PHP ===\n\n";

// Teste 1: getAllPatientEmails
echo "1. Testando getAllPatientEmails...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "$baseUrl/get_all_patient_emails.php");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response:\n";
$data = json_decode($response, true);
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

// Teste 2: getPatientByEmail
echo "2. Testando getPatientByEmail com 'paciente1@gmail.com'...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "$baseUrl/get_patient_by_email.php?email=paciente1@gmail.com");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response:\n";
$data = json_decode($response, true);
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

// Teste 3: getPatientByEmail com email inválido
echo "3. Testando getPatientByEmail com 'naoexiste@test.com'...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, "$baseUrl/get_patient_by_email.php?email=naoexiste@test.com");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response:\n";
$data = json_decode($response, true);
echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
?>
