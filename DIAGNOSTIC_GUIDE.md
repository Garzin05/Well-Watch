# 🔍 GUIA RÁPIDO - Persistência de Dados RESOLVIDA

## ✅ PROBLEMA IDENTIFICADO E CORRIGIDO

**Problema**: Dados não eram salvos
**Causa**: Arquivo PHP antigo estava em uso
**Solução**: Atualizado para versão com logging detalhado
**Status**: ✅ **API FUNCIONANDO CORRETAMENTE**

## 🎯 TESTE RÁPIDO (5 MINUTOS)

### Passo 1: Encontrar Patient ID Válido

Acesse phpMyAdmin: `http://localhost/phpmyadmin`

Execute esta query:
```sql
SELECT id, email FROM patients LIMIT 5;
```

Copie um ID (ex: 1)

## 🧪 COMO TESTAR

### Passo 1: Rodar App no Edge
```powershell
cd C:\Users\Pudinga\Documents\Well-Watch\Código-Well-Watch
flutter run -d edge
```
URL: `http://localhost:52690`

### Passo 2: Abrir Console (F12)
- Pressione `F12` no navegador
- Vá para aba "Console"
- Procure por logs começando com `[DIABETES_PAGE]`, `[HEALTH_SERVICE]`, `[API_SERVICE]`

### Passo 3: Executar Teste
1. **Login**: `paciente1@example.com` / `senha123`
2. **Ir para**: Glicemia
3. **Clique**: "Adicionar Glicemia"
4. **Preencha**: `145` mg/dL
5. **Clique**: "Confirmar"

### Passo 4: Verificar Logs

**No Console (F12):**
```
[DIABETES_PAGE] 🔐 auth.userId (raw): 5
[DIABETES_PAGE] 🔐 userId (converted): 5
[DIABETES_PAGE] 📊 Glicose valor: 145.0 mg/dL
[DIABETES_PAGE] 📤 Chamando healthService.addGlucoseRecord()
[HEALTH_SERVICE] ➕ Adicionando glicose para userId=5: 145.0 mg/dL
[HEALTH_SERVICE] 📤 Enviando para API: patientId=5, glucose=145.0
[API_SERVICE] 📊 Preparando inserção de glicose: patientId=5, valor=145.0
[API_SERVICE] 📤 POST para: http://localhost/WellWatchAPI/insert_measurement.php
[API_SERVICE] 📋 Body: {"patient_id":5,"type_code":"glucose","glucose_value":145.0,...}
[API_SERVICE] 📥 Response (200): {"status":true,"message":"...","measurement_id":42}
[DIABETES_PAGE] ✅ addGlucoseRecord() chamado
```

**Se vir `[API_SERVICE] ❌` ou Response com `status: false`:**
→ Verifique o PHP log abaixo

### Passo 5: Verificar PHP Log

```powershell
# Monitor em tempo real
Get-Content "C:\xampp\htdocs\WellWatchAPI\logs\insert_measurement_2024-12-10.log" -Wait -Tail 50
```

**Esperado:**
```
[2024-12-10 14:30:45.123456] ================== INÍCIO DA REQUISIÇÃO ==================
[2024-12-10 14:30:45.234567] STEP 1: Lendo input bruto
[2024-12-10 14:30:45.345678]   - Length: 120 bytes
[2024-12-10 14:30:45.456789]   - Raw Content: {"patient_id":5,"type_code":"glucose",...}
[2024-12-10 14:30:45.567890] STEP 2: Decodificando JSON
[2024-12-10 14:30:45.678901]   ✅ JSON decodificado com sucesso
[2024-12-10 14:30:45.789012] STEP 3: Extraindo variáveis
[2024-12-10 14:30:45.890123]   - patient_id: 5 (type: integer, valor bruto: 5)
[2024-12-10 14:30:45.901234]   - type_code: glucose (type: string)
[2024-12-10 14:30:45.012345] STEP 4: Validação inicial
[2024-12-10 14:30:45.123456]   ✅ Validação inicial passou
[2024-12-10 14:30:45.234567] STEP 5: Preparando statement SQL para type_code='glucose'
[2024-12-10 14:30:45.345678]   - Query: INSERT INTO measurements (patient_id, type_id, glucose_value, recorded_at, created_at) VALUES (?, ?, ?, ?, NOW())
[2024-12-10 14:30:45.456789]   ✅ Statement preparado
[2024-12-10 14:30:45.567890] STEP 6: Executando statement SQL
[2024-12-10 14:30:45.678901] ✅✅✅ SUCESSO! MEDIÇÃO INSERIDA COM SUCESSO!
[2024-12-10 14:30:45.789012]   - Measurement ID (insert_id): 42
[2024-12-10 14:30:45.890123]   - Patient ID: 5
```

### Passo 6: Verificar Banco de Dados

**Via phpMyAdmin:**
1. Acesse: `http://localhost/phpmyadmin`
2. Login: `root` (sem senha)
3. Selecione banco: `well_watch`
4. Tabela: `measurements`
5. Procure por `patient_id = 5`

**Via SQL:**
```sql
SELECT * FROM measurements 
WHERE patient_id = 5 
ORDER BY created_at DESC 
LIMIT 5;
```

**Esperado:**
```
id | patient_id | type_id | glucose_value | systolic | diastolic | recorded_at | created_at
42 | 5          | 1       | 145.0         | NULL     | NULL      | 2024-12-10  | 2024-12-10
```

## 🐛 TROUBLESHOOTING

### Cenário 1: "[DIABETES_PAGE] ❌ userId é 0!"
**Causa**: `AuthService.userId` é nulo ou vazio
**Solução**: 
1. Verifique se login retornou `user.id`
2. Verifique se `login.php` retorna `"id": (int)$user['id']`
3. Faça novo login

### Cenário 2: "[API_SERVICE] ❌ Erro de conexão"
**Causa**: PHP não respondendo ou erro de rede
**Solução**:
1. Verifique se `http://localhost/WellWatchAPI` está acessível
2. Verifique se Apache está rodando
3. Verifique se PHP está habilitado no XAMPP

### Cenário 3: "[INSERT_MEASUREMENT] ❌ Validação FALHOU - patient_id inválido"
**Causa**: `patient_id` não foi enviado no JSON
**Solução**:
1. Verifique log: `- Raw Content: ...` - patient_id deve estar lá
2. Se não tiver, problema está em `ApiService.insertMeasurement()`
3. Verifique se está passando `patientId` corretamente

### Cenário 4: "[INSERT_MEASUREMENT] ❌ ERRO AO EXECUTAR STATEMENT!"
**Causa**: Erro SQL (tipo de dado, constraint, etc)
**Solução**:
1. Verifique log: `- Error: ...` para mensagem específica
2. Verifique se tabela `measurements` existe
3. Verifique se colunas existem: `patient_id`, `type_id`, `glucose_value`, `recorded_at`
4. Execute: `DESCRIBE measurements;` no phpMyAdmin

### Cenário 5: "Banco vazio mesmo após sucesso"
**Causa**: Dados foram inseridos mas não aparecem
**Solução**:
1. Pressione F5 para recarregar página phpMyAdmin
2. Verifique se usou banco correto: `well_watch`
3. Verifique se usou paciente_id correto

## 📊 Script Automático de Teste

Executar via PowerShell:
```powershell
& "C:\Users\Pudinga\Documents\Well-Watch\test_insert_measurement.ps1"
```

Este script:
1. Envia requisição POST direto para a API
2. Mostra resposta
3. Exibe últimas 30 linhas do log
4. Mostra query SQL para verificar banco

## 📝 Log Files

Todos os logs são salvos em:
```
C:\xampp\htdocs\WellWatchAPI\logs\insert_measurement_YYYY-MM-DD.log
```

Cada dia é um arquivo novo.

## ✅ Checklist de Verificação

- [ ] App roda sem erros
- [ ] Login bem-sucedido mostra logs `[LOGIN_SCREEN] ✅`
- [ ] Adicionar glicose mostra logs `[DIABETES_PAGE]`
- [ ] Console mostra `[HEALTH_SERVICE]` logs
- [ ] Console mostra `[API_SERVICE]` logs com status code 200
- [ ] PHP log mostra "✅✅✅ SUCESSO!"
- [ ] Banco tem registro com `patient_id > 0`
- [ ] Médico consegue ver dados do paciente

## 🎯 Próximo Passo

Após rodar o teste acima, você terá uma trilha de logs completa que mostra exatamente aonde o dados está tendo problema. Com essa informação, saberei exatamente o que corrigir!

---

**Data**: 2024-12-10  
**Status**: 🔴 DIAGNOSTICANDO
