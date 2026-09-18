# Autenticación con Roble — entregables

## 1. Arquitectura encontrada

El proyecto ya seguía Clean Architecture/MVVM con GetX:
`UI -> Controller (GetX) -> Repository -> DataSource -> servicio externo/local`.
La rama de auth ya tenía `AuthenticationController`, `IAuthRepository` /
`AuthRepository`, `IAuthenticationSource` / `AuthenticationSourceService`,
y `Central` decidiendo Login vs Home según el estado del controlador. Esa
estructura se conservó tal cual; no se reemplazó nada de la arquitectura.

Antes de esta tarea (commit previo, hecho por otro agente) esas piezas ya
habían sido migradas de un login 100% local/simulado a llamadas HTTP
manuales contra endpoints de Roble adivinados (`/login`, `/refresh-token`,
`/auth/google/start`, etc.), sin poder verificar el formato real de Roble.

## 2. Qué cambió en esta pasada: de HTTP manual al SDK oficial

Roble publica un paquete Flutter oficial (`roble` en pub.dev, v1.12.0) que
ya implementa login, registro con verificación por correo, Google/Microsoft
SSO, renovación de tokens y almacenamiento seguro de sesión. Se reemplazó
todo el cliente HTTP hecho a mano por este SDK, porque:

- Elimina la necesidad de adivinar endpoints/formatos JSON de Roble.
- Resuelve el problema que tenía el código anterior: `startGoogleLogin()`
  abría el navegador pero no había nada para recibir el callback OAuth.
  `signInWithGoogle()` del SDK maneja todo el flujo (selector nativo en
  móvil, ventana en web) y devuelve el perfil ya autenticado.
- El SDK persiste la sesión con `flutter_secure_storage` internamente, así
  que ya no hace falta serializar tokens a mano en `ILocalPreferences`.

## 3. Archivos modificados

**Auth (lógica reescrita):**
- `lib/central.dart`, `lib/main.dart`
- `lib/core/error_message.dart`
- `lib/features/auth/auth_dependencies.dart`
- `lib/features/auth/data/datasources/remote/{authentication_source_service,i_authentication_source}.dart`
- `lib/features/auth/data/repositories/auth_repository.dart`
- `lib/features/auth/domain/models/authentication_user.dart`
- `lib/features/auth/domain/repositories/i_auth_repository.dart`
- `lib/features/auth/ui/viewmodels/authentication_controller.dart`
- `lib/features/auth/ui/views/{login_page,signup_page}.dart`

**Integración del usuario autenticado con el resto de la app:**
- `lib/features/create_project/ui/viewmodels/create_project_controller.dart`
  (usa `userId` como `createdBy` de un proyecto)
- `lib/features/shared_projects/ui/viewmodels/project_application_controller.dart`
  (usa `userId` como `applicantUserId`)
- `lib/features/home/domain/models/project.dart`,
  `lib/features/shared_projects/domain/models/participation_request.dart`
  (campos de ownership, sin cambio de lógica en esta pasada)

**Config/build:**
- `pubspec.yaml` (agrega `roble: ^1.12.0`, quita `url_launcher`)
- `android/app/src/main/AndroidManifest.xml` (permiso INTERNET, faltaba)
- `.gitignore` (excluye `.env*`)

**Resto de archivos con diff:** solo `dart format` (whitespace), verificado
con `git diff -w` = vacío. No cambian lógica.

## 4. Archivos nuevos

- `lib/features/auth/data/roble_auth_config.dart` — config vía `--dart-define`
- `lib/features/auth/domain/auth_exceptions.dart` — `AuthConfigurationException`, `NonInstitutionalEmailException`
- `lib/features/auth/ui/auth_guard.dart` — `GetMiddleware` para rutas protegidas
- `test/features/auth/{authentication_source_service,authentication_user,authentication_controller,roble_auth_config}_test.dart`
- `.env.example`
- Este archivo (`AUTH_DELIVERABLES.md`)

## 5. Flujo de autenticación

```
main() -> registerAuth() (registra AuthenticationSourceService, AuthRepository,
          AuthenticationController con Get.put permanent)
       -> runApp -> initialRoute '/' -> Central

Central (Obx sobre AuthenticationController):
  isRestoring == true  -> spinner
  isLogged   == true   -> HomePage
  isLogged   == false  -> LoginPage

AuthenticationController.onInit() -> restoreSession():
  roble.restoreSession() valida el token guardado en flutter_secure_storage
  (el SDK renueva internamente si hace falta) -> true/false.
```

- **Login tradicional**: `LoginPage` -> `controller.login(email, password)`
  -> `roble.login(...)` -> perfil -> estado autenticado.
- **Login con Google**: botón en `LoginPage` -> `controller.signInWithGoogle()`
  -> `roble.signInWithGoogle()` (nativo en móvil, ventana en web) -> mismo
  perfil que el login tradicional. Roble vincula automáticamente por correo
  verificado, así que no hay usuarios duplicados entre Google y contraseña.
- **Registro institucional**: `SignUpPage` ahora es un formulario real
  (antes solo mostraba un mensaje). Llama a
  `registerWithVerification(email, password, name, extra: {career})`,
  valida que el correo sea del dominio institucional configurado, y pide el
  código enviado por correo (`verifyEmail`). Solo después de verificar se
  puede hacer login — el registro nunca autentica directamente.
- **Logout**: `controller.logOut()` -> `roble.logout()` revoca la sesión en
  el dispositivo; el estado local se limpia igual aunque la llamada de red
  falle (no deja al usuario "atascado" logueado).
- **Protección de rutas**: `AuthGuard` (GetMiddleware) en `/home` y
  `/mis-proyectos`. El resto de pantallas (crear proyecto, detalle,
  unirse, comentar, seguir) solo son alcanzables navegando *desde* Home,
  que ya está detrás del guard — no existen como rutas nombradas
  independientes, así que no hay una URL que las exponga sin pasar por
  login primero.
- **Usuario en las operaciones**: `AuthenticationUser.userId` (no `.id`,
  que es la fila de perfil) es el identificador que se guarda en
  `Project.createdBy` y `ParticipationRequest.applicantUserId` — es el
  mismo que Roble usa para la columna `_owner` al validar permisos `own`.

## 6. Configuración de Roble

| Dato | Valor |
|---|---|
| Base URL | `https://roble-api.test-openlab.uninorte.edu.co` |
| Contract ID | `movil_flutter_dcaabc5f4e` |
| Login social | Google (Microsoft/GitHub disponibles si se habilitan en el proyecto) |

**Pendiente de configurar en la consola de Roble** (Usuarios → Proveedores):
registrar un "destino de retorno" por entorno — es un **nombre**, no una URL:

| Nombre sugerido | URL que debe apuntar | Uso |
|---|---|---|
| `innovation-hub-web-dev` | `http://localhost:5001` | `flutter run -d chrome --web-port=5001` |
| `innovation-hub-web` | dominio real de producción | build web publicado |
| `innovation-hub-mobile` | `com.<paquete-real>.app://sso-done` (o el que se defina) | Android/iOS |

El `applicationId`/bundle id actuales (`com.example.f_clean_template`) son
placeholders del template — **antes de publicar** hay que decidir el id
real y luego: (a) actualizarlo en `android/app/build.gradle.kts` e
`ios/Runner.xcodeproj`, (b) registrar el esquema de deep link
correspondiente en `AndroidManifest.xml`/`Info.plist`, y (c) usar ese mismo
esquema como destino de retorno móvil en Roble.

## 7. Configuración de Google

Ya está en la consola de Roble según lo compartido (Client ID/Secret de la
app web, redirect URI apuntando a Roble). Del lado de la app **solo falta**
si se compila para iOS: el `ROBLE_GOOGLE_IOS_CLIENT_ID` (Client ID de tipo
iOS creado en Google Cloud Console, distinto al web). Android y web no
necesitan ningún client id en la app — Roble ya tiene el suyo.

## 8. Variables de entorno (`--dart-define`)

Ver `.env.example`. Ninguna se commiteó con valor real; `.gitignore` ya
excluye `.env*`.

```
ROBLE_BASE_URL=https://roble-api.test-openlab.uninorte.edu.co
ROBLE_CONTRACT_ID=movil_flutter_dcaabc5f4e
ROBLE_SSO_REDIRECT=innovation-hub-web-dev        # nombre, no URL
ROBLE_GOOGLE_IOS_CLIENT_ID=                       # solo si se compila iOS
INSTITUTIONAL_EMAIL_DOMAIN=uninorte.edu.co
```

## 9. Base de datos / tablas

Roble no usa un esquema relacional que esta app deba migrar a mano: los
usuarios, sesiones, roles y permisos ya viven en la infraestructura de
autenticación de Roble (consola → Autenticación → Usuarios/Roles). No se
crearon tablas `users`/`user_sessions` — serían redundantes con lo que
Roble ya administra, y el propio SDK expone `currentUser()`/`restoreSession()`
sobre eso.

Lo que sí depende del dueño del proyecto, en la consola de Roble:
- Activar **propiedad por fila** (`_owner`) en las tablas de proyectos,
  comentarios y seguimientos, para que los permisos `own` (`editor_own`,
  o permisos granulares `<tabla>·update·own` / `<tabla>·delete·own`)
  realmente limiten a cada usuario a sus propios registros. Sin esto,
  `_owner` no se aplica y cualquier usuario con el rol adecuado podría
  editar/borrar filas ajenas.
- Confirmar el rol por defecto de un usuario nuevo (`user` vs `editor_own`)
  según si los estudiantes deben poder borrar sus propios comentarios/
  proyectos directamente o no.

Esto no se pudo ejecutar desde aquí porque requiere acceso a la consola del
proyecto, no al SDK cliente.

## 10. Cómo correr el proyecto

```bash
flutter pub get
flutter run -d chrome --web-port=5001 --dart-define-from-file=.env
# o, en Android/iOS con emulador/dispositivo conectado:
flutter run --dart-define-from-file=.env
```

(Copia `.env.example` a `.env` y complétalo primero.)

## 11. Cómo correr las pruebas

```bash
flutter test
```

23 pruebas, todas en verde: mapeo de perfil de Roble, validación de dominio
institucional, y el ciclo completo del controlador (estado inicial no
autenticado, carga, restauración exitosa/fallida, login éxito/fallo,
validación de formulario, Google éxito/cancelado, registro → verificación,
logout que limpia sesión aunque falle la red).

### Pruebas que requieren credenciales reales (no incluidas)

`AuthenticationSourceService` ahora es un adaptador delgado sobre
`RobleApiDataBase` — la lógica de red vive en el SDK de Roble, no en este
repo, así que no hay HTTP que simular aquí. Lo que sí queda pendiente y
requiere un usuario de prueba real (se puede crear con
`POST /movil_flutter_dcaabc5f4e/signup-direct`, como indicaste, sin código
de verificación):

- Login real contra Roble (credenciales válidas e inválidas).
- Flujo completo de Google en un dispositivo/navegador real (requiere el
  destino de retorno ya registrado en la consola).
- Registro + verificación por correo con un correo real.
- Expiración/renovación de token en un escenario de sesión larga.

## 12. Validación ejecutada

- `dart format lib test` — 33 archivos reformateados (solo whitespace,
  verificado con `git diff -w` vacío en los archivos ajenos a auth).
- `flutter analyze` — **0 issues nuevos**. Quedan 4 `info` preexistentes
  sin relación con auth (`unnecessary_overrides`/`unnecessary_underscores`
  en create_project/home/shared_projects, ya presentes antes de esta tarea).
- `flutter test` — **23/23 passing**.
- `flutter build web --dart-define=ROBLE_CONTRACT_ID=...` — **build exitoso**.
- `flutter build apk --debug --dart-define=ROBLE_CONTRACT_ID=...` — ver
  resultado más abajo/en el mensaje de cierre.
- Verificación manual de que no hay secretos: `git diff` de todos los
  archivos modificados no contiene ningún token, contraseña ni client
  secret — solo nombres de variables `--dart-define` y el contract id del
  proyecto (que no es secreto, es un identificador público del proyecto
  en Roble, igual que una URL).

## 13. Limitaciones conocidas

1. **Nadie ha iniciado sesión de verdad todavía.** Todo lo anterior está
   probado con mocks/fakes o compilación; el login/registro/Google reales
   necesitan que se registre el destino de retorno en la consola de Roble
   y (para probar en un dispositivo) un `applicationId`/bundle id
   definitivos en vez de los placeholders `com.example.*`.
2. **Sin propiedad por fila activada en Roble**, los permisos `own` no
   limitan nada — es una configuración de consola, no de código.
3. **Roles/permisos de Roble** (`user`, `editor_own`, etc.) no se están
   usando todavía para decidir qué puede hacer cada quien en la UI (por
   ejemplo, ocultar "eliminar" si el usuario no tiene permiso) — hoy la UI
   asume que cualquier autenticado puede intentar la acción y deja que el
   403 de Roble (si llega) se muestre como error genérico.
4. La navegación de la app no usa rutas nombradas para project-detail/
   crear-proyecto/comentarios (usa `Get.to(() => Widget())`), así que no
   hay URLs web para deep-linkear directo a esas pantallas — lo cual hoy
   las protege indirectamente, pero significa que si en el futuro se
   agregan rutas nombradas para esas pantallas, habrá que añadirles
   `AuthGuard` explícitamente en `main.dart`.

## 14. Información que aún debe confirmar el dueño del proyecto

- Nombre(s) definitivo(s) de "destino de retorno" a registrar en Roble
  (¿uno para dev, otro para producción, como se sugiere arriba?).
- `applicationId` (Android) y bundle id (iOS) reales del proyecto — hoy
  son el placeholder `com.example.f_clean_template`.
- Si se va a compilar para iOS: el Client ID de Google de tipo iOS.
- Si se debe restringir el auto-registro a `@uninorte.edu.co` (ya
  implementado con ese valor por defecto) o permitir otros dominios.
- Confirmación de qué rol por defecto deben tener los usuarios nuevos y si
  se activa propiedad por fila en `projects`, `project_comments`,
  `project_follows` — esa parte es 100% consola de Roble, no requiere
  cambios de código adicionales una vez decidida.
