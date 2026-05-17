## 🚀 Instalación

```bash
flutter pub get
flutter run
```

## 🧪 Tests

```bash
flutter test
```

17 unit tests + 2 widget tests.

## 🔗 Conexión con el backend

La URL base se configura en:
`lib/core/constants/app_constants.dart`

```dart
static const String apiBaseUrl = 'https://tu-backend.railway.app/api/v1';
```

## 📦 Dependencias principales

| Paquete | Uso |
|---------|-----|
| `flutter_bloc` | Manejo de estado |
| `http` | Requests HTTP |
| `shared_preferences` | Almacenamiento local |
| `go_router` | Navegación |
