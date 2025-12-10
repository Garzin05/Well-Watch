# 🔍 DIAGNÓSTICO E LOGGING COMPLETO IMPLEMENTADO

## ✅ O QUE FOI FEITO

### 1. **Flutter Side - Logging Adicionado**

#### `lib/services/health_service.dart`
```dart
[HEALTH_SERVICE] ➕ Adicionando glicose para userId=X: 145.0 mg/dL
[HEALTH_SERVICE] 📤 Enviando para API: patientId=X, glucose=145.0
[HEALTH_SERVICE] 📥 Resposta da API: {status: true, ...}
```

#### `lib/services/api_service.dart`
```dart
[API_SERVICE] 📊 Preparando inserção de glicose: patientId=X, valor=145.0
[API_SERVICE] 📤 POST para: http://localhost/WellWatchAPI/insert_measurement.php
[API_SERVICE] 📋 Body: {"patient_id":X,"type_code":"glucose",...}
[API_SERVICE] 📥 Response (200): {status: true, ...}
```

### 2. **PHP Side - Logging Adicionado**

#### `WellWatchAPI/insert_measurement.php`
```php
[INSERT_MEASUREMENT] Raw input: {"patient_id":X,"type_code":"glucose",...}
[INSERT_MEASUREMENT] Decoded input: array(patient_id => X, ...)
[INSERT_MEASUREMENT] patient_id=X, type_code=glucose, recorded_at=...
[INSERT_MEASUREMENT] ✅ Sucesso! Medição inserida. ID: Y, patient_id: X
```

## 🧪 TESTE RÁPIDO (3 MINUTOS)

### Passo 1: Monitor do PHP (Terminal 1)
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Pudinga\Documents\Well-Watch\monitor_php_logs.ps1"
```

### Passo 2: Abra o App no Browser (Terminal 2)
```powershell
# App está em: http://localhost:52690
# Console do navegador: F12 → Console
```

### Passo 3: Execute o Teste
1. **Login como Paciente**
   - Email: `paciente1@example.com` (ou crie novo)
   - Senha: `senha123`

2. **Adicione 1 Medição**
   - Clique em "Glicemia"
   - Botão "Adicionar Glicemia"
   - Valor: `145` mg/dL
   - Clique "Confirmar"

3. **Observe os Logs**
   - Browser Console (F12):
     - Veja logs `[HEALTH_SERVICE]` e `[API_SERVICE]`
   - PowerShell (monitor_php_logs.ps1):
     - Veja logs `[INSERT_MEASUREMENT]`
   - Check Database:
     - Veja se `patient_id` foi salvo

### Passo 4: Verificar Banco de Dados
```sql
SELECT * FROM measurements 
WHERE patient_id > 0 
ORDER BY created_at DESC 
LIMIT 5;
```

**Esperado:**
- `patient_id`: NÃO DEVE SER 0 ✅
- `glucose_value`: 145.0 ✅
- `created_at`: Data/hora atual ✅

### Passo 5: Teste como Médico
1. Logout (sair)
2. Login como médico: `doctor1@example.com` / `senha123`
3. Vá para "Pacientes" → Pesquise e adicione o paciente de teste
4. Clique no paciente → "Glicemia"
5. **Verá a medição de 145 mg/dL? ✅ SUCESSO!**

## 🐛 POSSÍVEIS PROBLEMAS E SOLUÇÕES

### Problema 1: Logs vazios no Flutter
**Causa**: App precisa recompilar  
**Solução**:
```powershell
cd C:\Users\Pudinga\Documents\Well-Watch\Código-Well-Watch
flutter clean
flutter pub get
flutter run -d edge
```

### Problema 2: Logs vazios no PHP
**Causa**: php_errors.log não existe ou erro_log desabilitado  
**Solução**: Criar arquivo manualmente
```powershell
New-Item -Path "C:\php-8.2.0\php_errors.log" -Type File -Force
```

### Problema 3: patient_id = 0 no banco
**Causa**: `AuthService.userId` é nulo  
**Solução**:
- Verificar se login retorna `user.id` corretamente
- Check `login.php` retorna `"id": (int)$user['id']`
- Verificar se `auth_service.dart` recebe corretamente

### Problema 4: Medição não aparece no médico
**Causa**: Dois possíveis:
1. patient_id não foi salvo (vide Problema 3)
2. get_measurements.php não filtra corretamente

**Solução**:
```sql
-- Verificar se medição tem patient_id correto
SELECT * FROM measurements WHERE patient_id = 5;

-- Verificar se é problema de filtro
SELECT * FROM measurements LIMIT 5;
```

## 📋 CHECKLIST DE VERIFICAÇÃO

- [ ] App Flutter compila sem erros
- [ ] App roda em `http://localhost:52690`
- [ ] Consegue fazer login como paciente
- [ ] Consegue adicionar medição de glicose
- [ ] Browser console mostra `[HEALTH_SERVICE]` logs
- [ ] Browser console mostra `[API_SERVICE]` logs (status: true)
- [ ] PHP error_log mostra `[INSERT_MEASUREMENT]` logs
- [ ] `measurement_id` retornou (não null)
- [ ] Banco de dados tem registro COM patient_id > 0
- [ ] Consegue fazer login como médico
- [ ] Médico consegue encontrar e adicionar paciente
- [ ] Médico vê a medição na aba "Glicemia"

## 📞 PRÓXIMAS AÇÕES

Se todos os testes passarem:
- ✅ Data flow está correto
- ✅ patient_id está sendo salvo
- ✅ Médico consegue recuperar dados do paciente

Se algum teste falhar:
1. Anote qual etapa falhou
2. Verifique o log correspondente
3. Siga o troubleshooting acima
4. Se não resolver, compartilhe os logs

---

**Status**: 🟢 Pronto para Teste  
**Última Atualização**: 2024  
**Versão**: 1.0.0
