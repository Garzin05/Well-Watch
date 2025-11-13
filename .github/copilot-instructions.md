# Well Watch - AI Coding Agent Instructions

## Project Overview
**Well Watch** is a Flutter health monitoring application with dual-user architecture (patients and doctors). It tracks vital health metrics (glucose, weight, blood pressure, medication) and provides doctor-patient interactions via shared appointment scheduling and medical records.

**Key Stack**: Flutter 3.x, Dart, Provider (state management), SharedPreferences (local storage), Material Design 3

---

## Architecture Overview

### Dual-User Pattern
The app serves two user roles with distinct UI flows:
- **Patient**: Health tracking screens (vitals dashboard, nutrition, activity, appointments) via `lib/screens/main/`
- **Doctor**: Patient management, appointment scheduling, medical records via `lib/screens/doctor/`

The `AuthService` enforces role-based routing—set `role: 'patient'` or `role: 'doctor'` to control which screens are accessible.

### State Management with Provider
- **AuthService** (`lib/services/auth_service.dart`): Manages user session, role, and login state
  - Persists to SharedPreferences with keys: `auth_username`, `auth_user_id`, `auth_role`
  - Simulated login: admin/123456 returns true; all others return false
- **HealthService** (`lib/services/health_service.dart`): Manages 4 health record types
  - `_glucoseRecords`, `_weightRecords`, `_bpRecords`, `_medicationRecords`
  - Auto-generates mock data on first load if no stored data exists
  - Persists all records to SharedPreferences as JSON StringLists

Both services extend `ChangeNotifier` and are registered in `main.dart` via `MultiProvider`.

### Screen & Route Organization
- **Central router**: `lib/router.dart` defines `AppRoutes` constants and `appRoutes()` factory
  - Auth flows: `login`, `welcome`, `patientRegistration`, `doctorRegistration`, `passwordRecovery`
  - Patient screens: `home`, `agenda`, `atividade`, `alimentacao`, `perfil`, `mensagem`, `inicio`
  - Doctor screens: `doctorMenu`, `doctorPatients`, `doctorProfile`, `notifications`
- Always use `AppRoutes.constantName` for navigation (not hardcoded strings)
- Patient screens in `lib/screens/main/`, doctor screens in `lib/screens/doctor/pages/`

### Data Models
Located in `lib/models/`:
- **HealthData**: Abstract `HealthRecord` base class with concrete subclasses:
  - `GlucoseRecord(glucoseLevel)`, `WeightRecord(weight)`, `BloodPressureRecord(systolic, diastolic, heartRate)`, `MedicationRecord(medicationName, dosage, scheduledTimes, taken)`
  - All implement `toJson()` and `fromJson()` for persistence
- **Patient**: Full patient profile with allergies, medications, vital signs, appointments, medical history
- **Doctor**: Doctor profile (implied in patient context)
- **PatientRegistration**: Registration form model

---

## Development Workflows

### Running the App
```powershell
# Web (Edge browser - primary dev target)
flutter run -d edge

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### Static Analysis & Testing
```powershell
# Run linter
flutter analyze

# Run unit/widget tests
flutter test

# Run specific test file
flutter test test/auth_service_test.dart
```

### Key Files for Quick Navigation
- **Entry point**: `lib/main.dart` - Provider setup, theme configuration
- **Theming**: `lib/theme.dart` - Material Design 3 light/dark themes with custom Poppins font
- **Constants**: `lib/constansts.dart` (AppStrings, AppColors) and `lib/utils/constants.dart` (extended color palette)
- **Widgets**: Reusable components in `lib/widgets/` including `CustomScaffold`, `CustomTextField`, `CustomButton`, `SocialLoginButton`

---

## Project-Specific Patterns

### Theme System
- Uses `google_fonts` with Poppins font family
- Dark theme is default (`themeMode: ThemeMode.dark` in main.dart)
- Color scheme: primary blue (#0066CC light, #66D6D2 dark), secondary teal (#00B8A9), accent pink (#E94E77)
- Gradient backgrounds leveraged for health/wellness aesthetic
- **Action**: When building new screens, use theme colors via `Theme.of(context).colorScheme` rather than hardcoding

### Form Validation
- `lib/utils/validators.dart` provides reusable validators (implied existence)
- TextFields wrapped with `CustomTextField` for consistent styling
- Use `TextFormField` in forms with global `_formKey` for validation

### Health Data Flow
1. **Input**: Patient enters glucose/weight/BP via forms
2. **Storage**: HealthService receives data, serializes to JSON, persists to SharedPreferences
3. **Display**: Charts (using `fl_chart` 0.68.0) and widgets render stored data
4. **Update**: Mock data auto-populates on first run; user can add/edit records

### UI Pattern: Lottie Animations
- App includes 7 Lottie JSON animations (heart, activity, diabetes, doctor, agenda, nutrition, weight)
- Animations registered in `pubspec.yaml` under flutter assets
- Used for onboarding/welcome screens and status indicators
- Import: `import 'package:lottie/lottie.dart'`

### Navigation with Role Checking
- After login, check `AuthService.role` before pushing doctor/patient routes
- Use context.read<AuthService>() in Provider context to access current role
- Example: `if (authService.role == 'doctor') { Navigator.pushNamed(context, AppRoutes.doctorMenu); }`

---

## Critical Integration Points

### SharedPreferences Storage Keys
Document all keys used to avoid collisions:
- Auth: `auth_username`, `auth_user_id`, `auth_role`
- Health: `glucose_records`, `weight_records`, `bp_records`, `medication_records` (stored as StringLists of JSON)

### HTTP & Backend (Prepared but Not Integrated)
- `http: ^1.0.0` is a dependency; no API calls currently implemented
- When integrating backend: create `lib/services/api_service.dart` and inject via Provider
- Replace mock data generation in HealthService with API calls

### Testing Conventions
- Unit tests in `test/auth_service_test.dart` follow standard test group pattern
- Widget tests in `test/login_navigation_test.dart` use `tester.pumpAndSettle()` with 2-second delays (accounts for animations)
- Always add 2-second delay after navigation for Lottie animations to complete
- Mock data for tests is auto-generated by HealthService; no fixtures needed

---

## Common Tasks & Examples

### Add a New Health Metric Type
1. Create new class extending `HealthRecord` in `lib/models/health_data.dart`
2. Add storage key and list to `HealthService`
3. Implement getter and persistence methods in `HealthService`
4. Add mock data in `HealthService.createMockData()`
5. Create display widget in `lib/widgets/health_widgets.dart`

### Add a New Patient Screen
1. Create file in `lib/screens/main/`
2. Add route constant in `AppRoutes` and route builder in `appRoutes()`
3. Add menu item in bottom nav (typically in `HomePage` or `InicioPage`)
4. Use `CustomScaffold` for consistent header/back button

### Add Doctor-Specific Feature
1. Create screen in `lib/screens/doctor/pages/`
2. Add route in `AppRoutes.doctorXxx` and `appRoutes()`
3. Implement role check: `if (authService.role != 'doctor') return ErrorScreen()`
4. Register in doctor menu (implied in `DoctorMenuPage`)

### Display Health Data in Chart
- Import `fl_chart` and create `LineChart` or `BarChart` widget
- Bind chart data to `HealthService.get{Glucose|Weight|Bp}Records`
- Use `Consumer<HealthService>` to rebuild on data changes
- Example color mapping: `GlucoseRecord` → green (normal), orange (high), red (low)

---

## Notable Implementation Details

### AuthService Login Behavior
- **Hardcoded test credentials**: username='admin', password='123456' returns true
- Real backend integration will replace this logic
- `socialLogin()` is stubbed and returns immediately (no OAuth implemented)

### Health Data Auto-Population
- On app startup, `HealthService.loadData()` checks SharedPreferences
- If empty, `createMockData()` generates sample records with today's date and yesterday's date
- Always sorts records by date (most recent first) before notifying listeners

### Screen Navigation Pattern
- Login → WelcomeScreen (manual role selection) → RoleBasedHome (patient/doctor)
- Patient home: InicioPage or HomePage (check both references in router)
- Doctor home: DoctorMenuPage
- Use named routes consistently; avoid direct Widget navigation

---

## Tips for Productivity

1. **Always use `context.read<AuthService>()` and `context.watch<HealthService>()`** to access providers
2. **Add assets to `pubspec.yaml`** before using them; hot reload won't pick up new assets
3. **Use Flutter DevTools** to inspect Provider state: `dart devtools`
4. **Test animations locally** before committing; 2-second delays are not overkill given Lottie complexity
5. **Check both `lib/constansts.dart` and `lib/utils/constants.dart`** when looking for color/string constants (both exist)
6. **SharedPreferences keys are simple strings**; prefix with domain (e.g., `auth_`, `glucose_`) to avoid collisions
7. **Dark theme is default**; ensure light theme is tested too (`themeMode: ThemeMode.light` for testing)

---

## Known Gaps & Future Work

- No backend API integration (HTTP client imported but unused)
- Social login methods stubbed but not connected to providers
- Doctor appointment scheduling forms prepared but display logic incomplete
- Medical records upload/storage not implemented
- Real-time notifications framework present but not wired to notification service
