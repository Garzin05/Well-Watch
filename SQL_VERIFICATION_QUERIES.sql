-- ============================================
-- Verificação de Integridade de Dados
-- ============================================

-- 1. Verificar se o paciente de teste existe
SELECT id, name, email, role FROM users 
WHERE email LIKE 'pacient%' OR email LIKE 'test_%' 
ORDER BY id DESC LIMIT 5;

-- 2. Verificar todas as medições registradas
SELECT 
    m.id,
    m.patient_id,
    mt.code as type_code,
    m.glucose_value,
    m.systolic,
    m.diastolic,
    m.heart_rate,
    m.weight_value,
    m.recorded_at,
    m.created_at
FROM measurements m
LEFT JOIN measurement_types mt ON m.type_id = mt.id
ORDER BY m.created_at DESC
LIMIT 20;

-- 3. Verificar medições de um paciente específico (substitua X pelo patient_id)
SELECT 
    m.id,
    m.patient_id,
    mt.code as type_code,
    m.glucose_value,
    m.systolic,
    m.diastolic,
    m.heart_rate,
    m.weight_value,
    m.recorded_at
FROM measurements m
LEFT JOIN measurement_types mt ON m.type_id = mt.id
WHERE m.patient_id = X
ORDER BY m.recorded_at DESC;

-- 4. Verificar medições COM patient_id = 0 (BUG!)
SELECT 
    m.id,
    m.patient_id,
    mt.code as type_code,
    m.recorded_at,
    m.created_at
FROM measurements m
LEFT JOIN measurement_types mt ON m.type_id = mt.id
WHERE m.patient_id = 0 OR m.patient_id IS NULL
ORDER BY m.created_at DESC;

-- 5. Contar medições por paciente
SELECT 
    patient_id,
    COUNT(*) as total_measurements,
    MAX(recorded_at) as last_recorded
FROM measurements
GROUP BY patient_id
ORDER BY total_measurements DESC;

-- 6. Ver estrutura da tabela measurements
DESCRIBE measurements;

-- 7. Ver estrutura da tabela users
DESCRIBE users;

-- 8. Ver estrutura da tabela patients
DESCRIBE patients;

-- 9. Listar todos os tipos de medição
SELECT * FROM measurement_types;

-- 10. Associações de médico-paciente (if exists)
-- Uncomment se houver tabela doctor_patients
-- SELECT * FROM doctor_patients;
