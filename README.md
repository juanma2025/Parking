# Parking App

Plataforma de parqueaderos.

## Configuración y Ejecución

1. Crea el archivo `env.json` basándote en `env.example.json` y coloca tus credenciales:
```json
{
  "SUPABASE_URL": "...",
  "SUPABASE_ANON_KEY": "..."
}
```

2. Ejecuta la aplicación usando el archivo de configuración:
```bash
flutter run --dart-define-from-file=env.json
```

## Pruebas

Para ejecutar las pruebas:
```bash
flutter test
```

## Análisis Estático

Para verificar el código:
```bash
flutter analyze
```
