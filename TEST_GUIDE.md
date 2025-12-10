# Guia de Teste - Integração de Dados de Saúde

## 🎯 Objetivo
Verificar se o `patient_id` está sendo corretamente capturado e salvo no banco de dados quando um paciente registra uma medição.

## 📋 Pré-requisitos
- App Flutter rodando em Edge: `http://localhost:52690`
- PHP server rodando em `http://localhost/WellWatchAPI`
- MySQL rodando com banco `well_watch`

## 🧪 Teste Completo

### 1️⃣ Fazer Login como PACIENTE

**Credenciais de Teste:**
- Email: `paciente1@example.com`
- Senha: `senha123`
- Role: Selecione "Paciente" (Patient)

> Se não funcionar, crie um novo paciente na tela de registro com:
> - Nome: `Test Patient`
> - Email: `test_patient@example.com`
> - Senha: `123456`

**Observação esperada:**
- Você será redirecionado para a tela inicial do paciente
- Verá menu: Glicemia, Pressão, Peso, Atividade, Alimentação, Agenda

### 2️⃣ Ir para a Aba "Glicemia"
- Clique no botão "Adicionar Glicemia"
- Preencha:
  - **Glicose**: `145` mg/dL
  - **Horário**: `14:30` (ou deixe a hora atual)
  - Clique em "Confirmar"

**Monitor de Logs (F12 - Console):**
```
[HEALTH_SERVICE] ➕ Adicionando glicose para userId=X: 145.0 mg/dL
[HEALTH_SERVICE] 📤 Enviando para API: patientId=X, glucose=145.0
[API_SERVICE] 📊 Preparando inserção de glicose: patientId=X, valor=145.0
[API_SERVICE] 📤 POST para: http://localhost/WellWatchAPI/insert_measurement.php
[API_SERVICE] 📋 Body: {"patient_id":X,"type_code":"glucose","glucose_value":145.0,"recorded_at":"..."}
[API_SERVICE] 📥 Response (200): {"status":true,"message":"Medição inserida com sucesso","measurement_id":Y}
[HEALTH_SERVICE] 📥 Resposta da API: {status: true, ...}
```

### 3️⃣ Verificar Logs do PHP (Windows PowerShell)
```powershell
# Acessar o arquivo de log do PHP
Get-Content "C:\php-8.2.0\php_errors.log" -Tail 20
```

**Observação esperada:**
```
[INSERT_MEASUREMENT] Raw input: {"patient_id":X,"type_code":"glucose",...}
[INSERT_MEASUREMENT] Decoded input: array(patient_id => X, type_code => "glucose", ...)
[INSERT_MEASUREMENT] patient_id=X, type_code=glucose, recorded_at=...
[INSERT_MEASUREMENT] ✅ Sucesso! Medição inserida. ID: Y, patient_id: X, type_code: glucose
```

### 4️⃣ Verificar Banco de Dados (MySQL)
```sql
-- Conecte via phpMyAdmin ou mysql CLI
SELECT * FROM measurements 
WHERE patient_id = X 
ORDER BY recorded_at DESC 
LIMIT 5;

-- Esperado:
-- +----+------------+---------+---------------+---
-- | id | patient_id | type_id | glucose_value | 
-- +----+------------+---------+---------------+---
-- | Y  | X          |    1    |     145.0     |
-- +----+------------+---------+---------------+---
```

### 5️⃣ Fazer Login como MÉDICO

**Credenciais:**
- Email: `doctor1@example.com`
- Senha: `senha123`
- Role: Selecione "Médico" (Doctor)

> Se não funcionar, registre um novo médico

### 6️⃣ Na Tela do Médico - Adicionar o Paciente

- Clique em "Pacientes"
- Clique no botão "+" ou "Adicionar Paciente"
- Procure por: `Test Patient` ou `paciente1@example.com`
- Selecione e confirme

**Observação esperada:**
- Paciente aparece na lista de pacientes do médico
- Log: `✅ Paciente adicionado com sucesso`

### 7️⃣ Visualizar Dados do Paciente

- Clique no paciente na lista de "Pacientes"
- Vá para "Diabetes" / "Glicemia"
- Selecione o paciente no topo

**Observação esperada:**
```
[DOCTOR_DIABETES_PAGE] Paciente selecionado: Test Patient (ID: X)
[API_SERVICE] 📤 GET para: http://localhost/WellWatchAPI/get_measurements.php?patient_id=X&type_code=glucose
[API_SERVICE] 📥 Response: { measurements: [ { patient_id: X, glucose_value: 145.0, ... } ] }
[DIABETES_PAGE] ✅ Medições carregadas do servidor: 1 registro(s)
```

### 8️⃣ Resultado Final

**✅ SUCESSO** = Você vê a medição de `145 mg/dL` na tabela/gráfico do médico

**❌ FALHA** = Nenhum registro aparece ou erro de API

## 🔍 Troubleshooting

### Se o patient_id não estiver sendo salvo:
1. Verifique os logs do Flutter (F12)
2. Verifique o arquivo de erros do PHP: `php_errors.log`
3. Verifique o banco direto: `SELECT * FROM measurements WHERE patient_id = 0`
4. Se houver registro com `patient_id = 0`, isso indica que `AuthService.userId` está nulo

### Se a API retorna "Dados incompletos":
- Significa que `patient_id`, `type_code` ou `recorded_at` não foram enviados
- Verifique a estrutura do JSON no log `[API_SERVICE] 📋 Body:`

### Se o médico vê registros de outro paciente:
- Pode ser cache do SharedPreferences
- Limpe o cache: Pressione F5 no navegador
- Ou limpe no console: `localStorage.clear()`

## 📊 Fluxo Esperado Completo

```
[PACIENTE] Registra 145 mg/dL
         ↓
[FLUTTER] HealthService.addGlucoseRecord(userId=5, glucose=145)
         ↓
[FLUTTER] ApiService.insertMeasurement(patientId=5, glucose=...)
         ↓
[HTTP] POST http://localhost/WellWatchAPI/insert_measurement.php
       Body: {"patient_id":5,"type_code":"glucose",...}
         ↓
[PHP] Recebe patient_id=5
      INSERT INTO measurements (patient_id, type_id, ...) VALUES (5, 1, ...)
         ↓
[BANCO] Dado salvo: id=Y, patient_id=5, glucose_value=145
         ↓
[MÉDICO] Login e seleciona paciente ID=5
         ↓
[MÉDICO] Clica em "Glicemia"
         ↓
[FLUTTER] ApiService.getMeasurements(patientId=5, type_code=glucose)
         ↓
[PHP] SELECT * FROM measurements WHERE patient_id=5 AND type_code='glucose'
         ↓
[API] Retorna: {"measurements":[{"patient_id":5,"glucose_value":145,...}]}
         ↓
[MÉDICO] 🎉 Vê "145 mg/dL" na tabela do paciente
```

## 🐛 Debug Logs Esperados (Ordem)

1. **[HEALTH_SERVICE] ➕** - Paciente clicou "Adicionar"
2. **[HEALTH_SERVICE] 📤** - Começou a enviar para API
3. **[API_SERVICE] 📊** - Preparando estrutura JSON
4. **[API_SERVICE] 📋** - Mostra Body completo
5. **[API_SERVICE] 📥** - Resposta da API (deve ser `200` e `status: true`)
6. **[INSERT_MEASUREMENT] ✅** - PHP logou sucesso

Se faltar algum desses passos, siga o troubleshooting acima.

---

**Versão**: 1.0  
**Data**: 2024  
**Status**: Teste Completo Operacional
