# Modelo de Seguridad y Autenticación (Paso 3)

Este documento detalla la arquitectura de seguridad, control de acceso basado en roles (RBAC), políticas de Row Level Security (RLS) y el flujo de autenticación simple sin confirmación de correo implementado en la plataforma.

---

## 1. Configuración de Autenticación (Supabase Auth)

- **Proveedor:** Email + Password.
- **Confirmación de Correo:** **DESACTIVADA** (`enable_confirmations = false`).
- **Longitud mínima de contraseña:** **8 caracteres** (tanto en el cliente como en Supabase).
- **Registro habilitado:** Sí (`enable_signup = true`).
- **Sesión inmediata:** Al registrarse mediante `signUp()`, Supabase devuelve un objeto de sesión activo inmediatamente, permitiendo al usuario ingresar y comenzar a usar la aplicación sin pasos intermedios de verificación, tokens, SMTP ni deep links.

---

## 2. Promoción del Primer Administrador

El trigger `protect_profile_role` previene que cualquier usuario cliente modifique su propio rol o el de terceros.
Sin embargo, cuando las consultas se ejecutan directamente en el **SQL Editor de Supabase** o mediante el `service_role`, la función `auth.uid()` devuelve `NULL`. El trigger detecta esta condición y permite la modificación directa.

### Sentencia SQL para promover al primer admin:

```sql
UPDATE public.profiles
SET role = 'admin'
WHERE id = (
  SELECT id FROM auth.users WHERE email = 'tu_correo_admin@ejemplo.com'
);
```

Para verificar la asignación:
```sql
SELECT id, full_name, role, created_at 
FROM public.profiles 
WHERE role = 'admin';
```

---

## 3. Inventario Completo de Políticas RLS

Todas las tablas en el esquema `public` tienen Row Level Security activado (`ENABLE ROW LEVEL SECURITY`). Todas las políticas anteriores de la plantilla inicial fueron eliminadas para evitar permisos accidentales permisivos.

| Tabla | Nombre de Política | Comando | Rol | Tipo | Regla / Condición |
|---|---|---|---|---|---|
| `profiles` | `profiles_select_own` | SELECT | authenticated | Permissive | `id = auth.uid()` |
| `profiles` | `profiles_select_admin` | SELECT | authenticated | Permissive | `is_admin()` |
| `profiles` | `profiles_update_own` | UPDATE | authenticated | Permissive | `id = auth.uid()` *(rol protegido por trigger)* |
| `profiles` | `profiles_update_admin` | UPDATE | authenticated | Permissive | `is_admin()` |
| `vehicles` | `vehicles_select_own` | SELECT | authenticated | Permissive | `user_id = auth.uid()` |
| `vehicles` | `vehicles_insert_own` | INSERT | authenticated | Permissive | `user_id = auth.uid()` |
| `vehicles` | `vehicles_update_own` | UPDATE | authenticated | Permissive | `user_id = auth.uid()` |
| `vehicles` | `vehicles_delete_own` | DELETE | authenticated | Permissive | `user_id = auth.uid()` |
| `vehicles` | `vehicles_select_admin` | SELECT | authenticated | Permissive | `is_admin()` |
| `parking_lots` | `parking_lots_select_active` | SELECT | authenticated | Permissive | `status = 'active'` |
| `parking_lots` | `parking_lots_select_own` | SELECT | authenticated | Permissive | `owner_id = auth.uid()` |
| `parking_lots` | `parking_lots_insert_owner` | INSERT | authenticated | Permissive | `owner_id = auth.uid() AND is_parking_owner()` |
| `parking_lots` | `parking_lots_update_owner` | UPDATE | authenticated | Permissive | `owner_id = auth.uid() AND is_parking_owner()` |
| `parking_lots` | `parking_lots_delete_owner` | DELETE | authenticated | Permissive | `owner_id = auth.uid() AND is_parking_owner()` |
| `parking_lots` | `parking_lots_admin_all` | ALL | authenticated | Permissive | `is_admin()` |
| `parking_spaces` | `parking_spaces_select_visible`| SELECT | authenticated | Permissive | Visible si el parqueadero padre es visible |
| `parking_spaces` | `parking_spaces_insert_owner` | INSERT | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `parking_spaces` | `parking_spaces_update_owner` | UPDATE | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `parking_spaces` | `parking_spaces_delete_owner` | DELETE | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `parking_spaces` | `parking_spaces_admin_all` | ALL | authenticated | Permissive | `is_admin()` |
| `parking_schedules` | `parking_schedules_select_visible`| SELECT | authenticated | Permissive | Visible si el parqueadero padre es visible |
| `parking_schedules` | `parking_schedules_insert_owner` | INSERT | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `parking_schedules` | `parking_schedules_update_owner` | UPDATE | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `parking_schedules` | `parking_schedules_delete_owner` | DELETE | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `parking_schedules` | `parking_schedules_admin_all` | ALL | authenticated | Permissive | `is_admin()` |
| `reservations` | `reservations_select_own` | SELECT | authenticated | Permissive | `user_id = auth.uid()` |
| `reservations` | `reservations_select_lot_owner`| SELECT | authenticated | Permissive | `owns_parking_lot(parking_lot_id)` |
| `reservations` | `reservations_select_admin` | SELECT | authenticated | Permissive | `is_admin()` |
| `payments` | `payments_select_own` | SELECT | authenticated | Permissive | Usuario dueño de la reserva asociada |
| `payments` | `payments_select_lot_owner` | SELECT | authenticated | Permissive | Dueño del parqueadero de la reserva |
| `payments` | `payments_select_admin` | SELECT | authenticated | Permissive | `is_admin()` |
| `reviews` | `reviews_select_authenticated` | SELECT | authenticated | Permissive | `true` (lectura para usuarios autenticados) |
| `reviews` | `reviews_insert_own_completed` | INSERT | authenticated | Permissive | Solo si el usuario completó la reserva asociada |
| `reviews` | `reviews_update_admin` | UPDATE | authenticated | Permissive | `is_admin()` |
| `reviews` | `reviews_delete_admin` | DELETE | authenticated | Permissive | `is_admin()` |
| `favorites` | `favorites_select_own` | SELECT | authenticated | Permissive | `user_id = auth.uid()` |
| `favorites` | `favorites_insert_own` | INSERT | authenticated | Permissive | `user_id = auth.uid()` |
| `favorites` | `favorites_delete_own` | DELETE | authenticated | Permissive | `user_id = auth.uid()` |
| `ai_conversations` | `ai_conversations_select_own` | SELECT | authenticated | Permissive | `user_id = auth.uid()` |
| `ai_conversations` | `ai_conversations_insert_own` | INSERT | authenticated | Permissive | `user_id = auth.uid()` |
| `ai_conversations` | `ai_conversations_update_own` | UPDATE | authenticated | Permissive | `user_id = auth.uid()` |
| `ai_conversations` | `ai_conversations_delete_own` | DELETE | authenticated | Permissive | `user_id = auth.uid()` |
| `ai_messages` | `ai_messages_select_own` | SELECT | authenticated | Permissive | Conversación asociada es de `auth.uid()` |
| `ai_messages` | `ai_messages_insert_own` | INSERT | authenticated | Permissive | Conversación asociada es de `auth.uid()` |
| `ai_messages` | `ai_messages_delete_own` | DELETE | authenticated | Permissive | Conversación asociada es de `auth.uid()` |
| `notifications` | `notifications_select_own` | SELECT | authenticated | Permissive | `user_id = auth.uid()` |
| `notifications` | `notifications_update_own` | UPDATE | authenticated | Permissive | `user_id = auth.uid()` *(solo columna is_read)* |
| `recommendation_events` | `recommendation_events_insert_own`| INSERT | authenticated | Permissive | `user_id = auth.uid()` |
| `recommendation_events` | `recommendation_events_select_admin`| SELECT | authenticated | Permissive | `is_admin()` |
| `security_events` | `security_events_select_own` | SELECT | authenticated | Permissive | `user_id = auth.uid()` |
| `security_events` | `security_events_select_admin` | SELECT | authenticated | Permissive | `is_admin()` |
| `storage.objects` (`avatars`) | `avatars_select_authenticated`| SELECT | authenticated | Permissive | `bucket_id = 'avatars'` |
| `storage.objects` (`avatars`) | `avatars_insert_own_folder` | INSERT | authenticated | Permissive | `(storage.foldername(name))[1] = auth.uid()::text` |
| `storage.objects` (`avatars`) | `avatars_update_own_folder` | UPDATE | authenticated | Permissive | `(storage.foldername(name))[1] = auth.uid()::text` |
| `storage.objects` (`avatars`) | `avatars_delete_own_folder` | DELETE | authenticated | Permissive | `(storage.foldername(name))[1] = auth.uid()::text` |

---

## 4. Matriz de Privilegios (GRANTs)

Para aplicar el principio de mínimo privilegio en profundidad, los permisos de base de datos se revocaron antes de aplicar RLS:

- **Rol `anon`:**
  - Revocados todos los privilegios sobre tablas, secuencias y funciones en el esquema `public`.
  - Revocados los privilegios por defecto (`ALTER DEFAULT PRIVILEGES`).
  - No puede leer ni escribir datos en ninguna tabla.
- **Rol `authenticated`:**
  - `profiles`: SELECT, UPDATE. (Sin INSERT directo, creado por trigger).
  - `vehicles`: SELECT, INSERT, UPDATE, DELETE.
  - `parking_lots`: SELECT, INSERT, UPDATE, DELETE.
  - `parking_spaces`: SELECT, INSERT, UPDATE, DELETE.
  - `parking_schedules`: SELECT, INSERT, UPDATE, DELETE.
  - `reservations`: **Solo SELECT**. (Inserciones y actualizaciones deben realizarse mediante RPCs seguras).
  - `payments`: **Solo SELECT**. (Inserciones controladas por el servidor de pagos).
  - `reviews`: SELECT, INSERT, UPDATE, DELETE. (UPDATE y DELETE restringidos a administradores vía RLS).
  - `favorites`: SELECT, INSERT, DELETE.
  - `ai_conversations`: SELECT, INSERT, UPDATE, DELETE.
  - `ai_messages`: SELECT, INSERT, DELETE.
  - `notifications`: SELECT, **UPDATE (is_read)** exclusivamente mediante concesión a nivel de columna (*column-level grant*). Sin permiso de INSERT para clientes.
  - `recommendation_events`: SELECT, INSERT.
  - `security_events`: **Solo SELECT**. (Escritura exclusivamente mediante `log_security_event`).

---

## 5. Funciones y Triggers de Seguridad

1. `public.is_admin()`: `STABLE`, `SECURITY DEFINER`, `SET search_path = ''`. Comprueba de forma segura si `profiles.role = 'admin'` para el usuario actual.
2. `public.is_parking_owner()`: `STABLE`, `SECURITY DEFINER`, `SET search_path = ''`. Comprueba si el rol es `'parking_owner'`.
3. `public.owns_parking_lot(uuid)`: `STABLE`, `SECURITY DEFINER`, `SET search_path = ''`. Valida que el lote pertenezca al usuario que invoca.
4. `public.handle_new_user()`: Trigger `AFTER INSERT` en `auth.users`. Sanitiza metadatos del cliente:
   - Rol permitido: solo `'vehicle_owner'` o `'parking_owner'`. Cualquier otro valor (incluyendo intentos de inyectar `'admin'`) se convierte a `'vehicle_owner'`.
   - Nombre completo: fallback al usuario antes del `@` si no se envía.
   - Longitudes truncadas a límites seguros.
5. `public.protect_profile_role()`: Trigger `BEFORE UPDATE` en `public.profiles`. Bloquea cualquier cambio en la columna `role` a menos que `is_admin()` sea verdadero o `auth.uid() IS NULL` (consola SQL de administración).
6. `public.log_security_event(event_type, device_info)`: Procedimiento RPC `SECURITY DEFINER` que registra eventos de auditoría (`login`, `logout`, etc.) forzando el `user_id` a `auth.uid()`. Solo ejecutable por usuarios autenticados.

---

## 6. Políticas Restrictivas AAL2 (2FA Futuro)

En la migración `20261018140000_006_security.sql`, las políticas restrictivas para requerir doble factor de autenticación (`aal2`) se encuentran documentadas y preparadas como comentarios para cuando se implemente el paso de MFA:

```sql
-- CREATE POLICY reservations_require_aal2 ON public.reservations
--   AS RESTRICTIVE FOR ALL TO authenticated
--   USING ((SELECT auth.jwt() ->> 'aal') = 'aal2');
```

---

## 7. Ejecución de Pruebas de Seguridad

Las pruebas automatizadas de seguridad simulan el comportamiento de distintos usuarios utilizando `SET LOCAL ROLE authenticated` y `request.jwt.claims`.

1. **Pruebas en la Base de Datos:**
   - Script maestro: `tests/security/all_tests_combined.sql`
   - Se ejecuta en una transacción con `ROLLBACK` final, validando:
     - 01: `anon` no puede leer ninguna tabla.
     - 02: Aislamiento completo de vehículos entre usuarios A y B.
     - 03: Aislamiento de reservas y pagos entre usuarios y entre propietarios de diferentes parqueaderos.
     - 04: Restricción de inserción de parqueaderos según rol (`vehicle_owner` denegado).
     - 05: Protección ante escalamiento de rol y modificación autorizada por admin.
     - 06: Denegación de escrituras directas a tablas de reservas, pagos y auditoría.
     - 07: Aislamiento de almacenamiento por carpeta en el bucket `avatars`.
     - 08: Sanitización de rol en el registro (`admin` no admitido desde cliente).

2. **Pruebas en la Aplicación Flutter:**
   - Ejecutar: `flutter test`
   - Pruebas unitarias de casos de uso de autenticación (`test/auth_test.dart`).
   - Pruebas de integración de rutas y redirección por rol (`test/router_test.dart`).
   - Resultado: 26 de 26 pruebas aprobadas (100%).

---

## 8. Escaneo de Secretos

Se ejecutó un escaneo exhaustivo sobre el árbol de trabajo y la historia de Git (`git log -p --all`):
- No se encontraron claves `service_role`, claves privadas (`BEGIN PRIVATE KEY`), ni contraseñas almacenadas.
- El archivo `env.json` está correctamente ignorado por Git (`.gitignore`).
