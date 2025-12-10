# 🔗 FLUXO TÉCNICO COMPLETO - Patient ID Data Flow

## 1. FLUXO DE DADOS - ALTO NÍVEL

```
┌─────────────────────────────────────────────────────────────┐
│ 1. PACIENTE REGISTRA MEDIÇÃO                                │
├─────────────────────────────────────────────────────────────┤
│ Tela: lib/screens/main/diabetes_page.dart (linha 84)        │
│ Ação: Clique em "Confirmar" na dialog                       │
│ Dados: glucoseLevel=145, date=now()                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. OBTÉM USER ID DO AUTHSERVICE                             │
├─────────────────────────────────────────────────────────────┤
│ Arquivo: lib/services/auth_service.dart (linha 130)         │
│ Código: userId = user["id"]?.toString() ?? ''               │
│ Tipo: String (armazenado em SharedPreferences)              │
│ Valor Esperado: "5" (convertido para Int depois)            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. HEALTHSERVICE.ADDGLUCOSERECORD()                         │
├─────────────────────────────────────────────────────────────┤
│ Arquivo: lib/services/health_service.dart (linha 123)       │
│ Função: addGlucoseRecord(int userId, GlucoseRecord record)  │
│ Log: [HEALTH_SERVICE] ➕ Adicionando glicose userId=5       │
│ Ação: Salva localmente + chama insertMeasurement()          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. APISERVICE.INSERTMEASUREMENT()                           │
├─────────────────────────────────────────────────────────────┤
│ Arquivo: lib/services/api_service.dart (linha 205)          │
│ Função: insertMeasurement({required int patientId, ...})    │
│ Log: [API_SERVICE] 📋 Body: {"patient_id":5,"type":...}    │
│ Ação: POST para /insert_measurement.php com JSON            │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┴───────────────┐
           │ NETWORK REQUEST (HTTP)        │
           │ Content-Type: application/json│
           │ Body: JSON com patient_id=5   │
           ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. PHP RECEBE REQUEST                                       │
├─────────────────────────────────────────────────────────────┤
│ Arquivo: WellWatchAPI/insert_measurement.php (linha 6)      │
│ Ação: Lê arquivo de input (raw JSON)                        │
│ Log: [INSERT_MEASUREMENT] Raw input: {...patient_id:5...}  │
│ Decodifica JSON e extrai: patient_id = 5 (int)             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. VALIDA DADOS                                             │
├─────────────────────────────────────────────────────────────┤
│ Verifica: patient_id != null && patient_id > 0 ✅           │
│ Verifica: type_code não vazio ✅                             │
│ Verifica: recorded_at não vazio ✅                           │
│ Log: patient_id=5, type_code=glucose, recorded_at=...      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. INSERE NO BANCO DE DADOS                                 │
├─────────────────────────────────────────────────────────────┤
│ Query: INSERT INTO measurements (patient_id, type_id, ...)  │
│        VALUES (5, 1, 145.0, NOW())                          │
│ Bind: patient_id=5 (int), type_id=1 (glucose), glucose_value=145.0
│ Log: ✅ Sucesso! Medição inserida. ID: 42, patient_id: 5   │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┴───────────────┐
           │ JSON RESPONSE (HTTP 200)      │
           │ {"status":true,"message":"OK"}│
           ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. FLUTTER RECEBE RESPOSTA                                  │
├─────────────────────────────────────────────────────────────┤
│ Arquivo: lib/services/api_service.dart (linha 235)          │
│ Código: final result = jsonDecode(response.body);           │
│ Log: 📥 Response (200): {status: true, ...}                 │
│ Resultado: Medição salva com patient_id=5 ✅                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
                  ✅ FIM DO FLUXO
              (Dados gravados no banco)
```

## 2. ESTRUTURA DE DADOS

### JSON Enviado pelo Flutter → PHP

```json
{
  "patient_id": 5,
  "type_code": "glucose",
  "glucose_value": 145.0,
  "recorded_at": "2024-01-15T14:30:00.000Z"
}
```

**Notas:**
- `patient_id`: Int (vindo de AuthService.userId como String, convertido)
- `type_code`: "glucose" | "weight" | "pressure"
- `recorded_at`: ISO 8601 DateTime string
- Valores adicionais conforme tipo

### Banco de Dados - Tabela measurements

```
+----+------------+---------+---------------+-----------+----------+----------+-----...
| id | patient_id | type_id | glucose_value | systolic  | diastolic| heart_rate...
+----+------------+---------+---------------+-----------+----------+----------+-----...
| 42 |      5     |    1    |     145.0     |   NULL    |   NULL   |   NULL  ...
+----+------------+---------+---------------+-----------+----------+----------+-----...
```

**Importante:**
- `patient_id` DEVE ser > 0 (não 0, não NULL)
- `type_id`: 1=glucose, 2=pressure, 3=weight
- Cada tipo tem seus campos específicos preenchidos

## 3. LOGGING EM TEMPO REAL

### Sequência de Logs Esperada

```
[HEALTH_SERVICE] ➕ Adicionando glicose para userId=5: 145.0 mg/dL
↓
[HEALTH_SERVICE] 📤 Enviando para API: patientId=5, glucose=145.0
↓
[API_SERVICE] 📊 Preparando inserção de glicose: patientId=5, valor=145.0
↓
[API_SERVICE] 📤 POST para: http://localhost/WellWatchAPI/insert_measurement.php
↓
[API_SERVICE] 📋 Body: {"patient_id":5,"type_code":"glucose","glucose_value":145.0,"recorded_at":"2024..."}
↓
[INSERT_MEASUREMENT] Raw input: {"patient_id":5,"type_code":"glucose",...}
↓
[INSERT_MEASUREMENT] Decoded input: array(patient_id => 5, type_code => "glucose", ...)
↓
[INSERT_MEASUREMENT] patient_id=5, type_code=glucose, recorded_at=...
↓
[INSERT_MEASUREMENT] ✅ Sucesso! Medição inserida. ID: 42, patient_id: 5, type_code: glucose
↓
[API_SERVICE] 📥 Response (200): {"status":true,"message":"Medição inserida com sucesso","measurement_id":42}
↓
[HEALTH_SERVICE] 📥 Resposta da API: {status: true, message: "Medição inserida com sucesso", measurement_id: 42}
```

## 4. VERIFICAÇÃO DE DADOS - SQL

### Depois de registrar 145 mg/dL como paciente 5

```sql
-- Ver todas as medições do paciente 5
SELECT * FROM measurements 
WHERE patient_id = 5 
ORDER BY recorded_at DESC;

-- Resultado esperado:
+----+------------+---------+---------------+----+--+-----...---+----+
| id | patient_id | type_id | glucose_value | ... | recorded_at    | ...
+----+------------+---------+---------------+----+--+-----...---+----+
| 42 |      5     |    1    |     145.0     | ... | 2024-01-15 14:30| ...
+----+------------+---------+---------------+----+--+-----...---+----+
```

### Se patient_id = 0 (BUG!)

```sql
-- Não deve retornar registros com patient_id = 0
SELECT * FROM measurements WHERE patient_id = 0;

-- Se retornar algo, é um BUG indicando:
-- 1. AuthService.userId é nulo
-- 2. int.tryParse(null) retorna 0
-- 3. Precisa verificar login.php returnando user.id
```

## 5. PONTOS CRÍTICOS VERIFICADOS

### ✅ AuthService (lib/services/auth_service.dart:130)
```dart
userId = user["id"]?.toString() ?? '';
```
- Converte int para String
- Armazenado em SharedPreferences

### ✅ DiabetesPage (lib/screens/main/diabetes_page.dart:74)
```dart
final userId = int.tryParse(auth.userId ?? '') ?? 0;
```
- Converte String de volta para int
- Se null, usa 0 (problemático)
- **CRÍTICO**: Se auth.userId é nulo, userId fica 0!

### ✅ HealthService (lib/services/health_service.dart:123)
```dart
Future<void> addGlucoseRecord(int userId, GlucoseRecord record) async {
    // ...
    await ApiService.insertMeasurement(patientId: userId, glucose: record);
}
```
- Passa userId diretamente como patientId
- userId deve ser > 0 aqui!

### ✅ ApiService (lib/services/api_service.dart:211)
```dart
Map<String, dynamic> data = {"patient_id": patientId};
```
- Coloca patientId no JSON
- Envia via POST com Content-Type: application/json

### ✅ PHP (WellWatchAPI/insert_measurement.php:6)
```php
$patient_id = isset($input['patient_id']) ? (int)$input['patient_id'] : null;
// ...
if (!$patient_id || !$type_code || !$recorded_at) {
    // Rejeita se vazio
}
```
- Valida patient_id é integer > 0
- Se null ou 0, rejeita com erro "Dados incompletos"

## 6. POSSÍVEIS FALHAS E CAUSAS

| Falha | Causa | Verificação |
|-------|-------|------------|
| patient_id = 0 no banco | AuthService.userId é nulo | Logs: Veja se é "0" ou vazio |
| "Dados incompletos" (erro) | patient_id null ao chegar em PHP | Log: [INSERT_MEASUREMENT] Erro |
| Medição local mas não na API | Network error ou timeout | Log: [API_SERVICE] ❌ Erro |
| Banco em branco (sem registros) | Endpoint nunca foi chamado | Log: Não há [INSERT_MEASUREMENT] |
| Response error 500 | SQL syntax error ou patient_id inválido | Check PHP error_log |

## 7. PRÓXIMO PASSO: VERIFICAÇÃO DO MÉDICO

Após confirmar que patient_id=5 foi salvo, testar lado do médico:

```
[MÉDICO] Seleciona paciente ID=5
         ↓
[API] GET /get_measurements.php?patient_id=5&type_code=glucose
         ↓
[PHP] SELECT * FROM measurements 
      WHERE patient_id = 5 AND type_id = 1
         ↓
[API] Retorna: {"measurements": [{"patient_id":5,"glucose_value":145,...}]}
         ↓
[FLUTTER] Renderiza tabela com 1 registro ✅
```

Se médico NÃO vê a medição:
1. Verifique se patient_id foi salvo (SQL acima)
2. Verifique se paciente foi associado ao médico
3. Verifique get_measurements.php retorna dados

---

**Versão**: 1.0  
**Última Atualização**: 2024  
**Status**: 🟢 Implementação Completa
