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
`/auth/.../start`, etc.), sin poder verificar el formato real de Roble.

## 2. Qué cambió en esta pasada: de HTTP manual al SDK oficial

Roble publica un paquete Flutter oficial (`roble` en pub.dev, v1.12.0) que
ya implementa login, registro con verificación por correo, SSO con Microsoft, renovación de tokens y almacenamiento seguro de sesión. Se reemplazó
todo el cliente HTTP hecho a mano por este SDK, porque:

- Elimina la necesidad de adivinar endpoints/formatos JSON de Roble.
- Resuelve el problema del código anterior, que abría el navegador para el
  login social pero no tenía nada que recibiera el callback OAuth.
  `signInWithProvider(RobleSocialProvider.microsoft)` maneja el flujo
  completo (con PKCE) y devuelve el perfil ya autenticado.
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
- `lib/features/auth/data/retry_policy.dart` — reintentos acotados con backoff
- `lib/features/auth/data/retry_after_client.dart` — captura `Retry-After` de un 429
- `lib/features/auth/domain/auth_exceptions.dart` — `AuthConfigurationException`,
  `NonInstitutionalEmailException`, `AuthRateLimitedException`,
  `AuthProviderUnavailableException`
- `lib/features/auth/domain/password_policy.dart` — la regla de contraseña de Roble
- `lib/features/auth/ui/auth_guard.dart` — `GetMiddleware` para rutas protegidas
- `test/features/auth/*_test.dart` (source, user, controller, config,
  password_policy, retry_policy)
- `.env.example`, este archivo

También modificado en esta pasada: `web/index.html` (página de retorno del
popup de Microsoft).

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
- **Login con Microsoft**: botón en `LoginPage` -> `controller.signInWithMicrosoft()`
  -> `roble.signInWithProvider(RobleSocialProvider.microsoft)`. Roble es el
  intermediario: la app nunca habla con Microsoft ni guarda su Client Secret.
  En web abre un popup; el popup vuelve a `web/index.html`, que entrega la URL
  de retorno a la ventana principal (contrato del SDK: `postMessage` con el
  prefijo `roble-sso:` y respaldo en `localStorage["roble-sso"]`) y se cierra
  sin arrancar Flutter. En Roble el login social también es registro: un
  correo nuevo crea un usuario verificado y uno existente se vincula
  (automáticamente si el proveedor certifica el correo; si no, responde 409 y
  la app pide iniciar sesión con el método original).
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
| Login social | Microsoft (solo funciona cuando se habilita, ver §7) |

Rutas reales verificadas por HTTP: `/auth/{contrato}/login`, `/signup`,
`/signup-direct`, `/auth/providers`. Roble usa tokens JWT (`accessToken` con
`expires_in: 900`, es decir 15 min, y `refreshToken`); el SDK los renueva solo.

**Límites del servidor observados** (cabeceras `X-Ratelimit-*`):
registro y `signup-direct`: **5 por hora**; login: **10 por 15 min**; resto de
endpoints: 100 por minuto. Los rechazos de validación también cuentan.

**Pendiente de configurar en la consola de Roble** (Usuarios → Proveedores):
registrar un "destino de retorno" por entorno — es un **nombre**, no una URL:

| Nombre sugerido | URL que debe apuntar | Uso |
|---|---|---|
| `innovation-hub-web-dev` | `http://localhost:5001` | `flutter run -d chrome --web-port=5001` |
| `innovation-hub-web` | dominio real de producción | build web publicado |
| `innovation-hub-mobile` | `<esquema>://sso-done` | Android/iOS |

El `applicationId`/bundle id actuales (`com.example.f_clean_template`) son
placeholders del template — **antes de publicar** hay que decidir el id
real y luego: (a) actualizarlo en `android/app/build.gradle.kts` e
`ios/Runner.xcodeproj`, (b) declarar el esquema de deep link en
`AndroidManifest.xml`/`Info.plist` (lo usa `flutter_web_auth_2`), y (c) pasar
ese mismo esquema en `ROBLE_NATIVE_CALLBACK_SCHEME` y registrarlo en Roble.

## 7. Configuración de Microsoft

Verificado con `GET /auth/movil_flutter_dcaabc5f4e/auth/providers`: hoy
devuelve `[]`, o sea que **ningún proveedor está habilitado** en el proyecto.
Hasta que el dueño lo configure, el botón "Continuar con Microsoft" muestra
"Microsoft aún no está habilitado en Roble" y no lanza ninguna petición de
login. Todo esto se hace **solo en la consola de Roble / Azure, nunca en la app**:

1. Azure (Microsoft Entra ID → Registros de aplicaciones): crear un registro,
   plataforma **Web**, con el Redirect URI que muestra Roble en
   Usuarios → Proveedores → Microsoft (debe coincidir carácter por carácter).
2. Crear un secreto de cliente y copiar su valor de inmediato.
3. Copiar el *Application (client) ID* y, opcionalmente, el *Directory
   (tenant) ID* (sin él se usa el endpoint común, que admite cualquier
   organización).
4. En Roble: pegar Client ID, Client Secret y Tenant ID, y activar el proveedor.
5. Registrar los destinos de retorno de la tabla anterior.

Endpoints de autorización/token/userinfo, scopes y renovación los gestiona
Roble; el SDK solo llama a `POST /auth/{contrato}/auth/microsoft/start` y
canjea el `code` recibido. La app no necesita Tenant ID, Client ID ni Secret.
Nota de Roble: si Entra no emite `email_verified` (frecuente en registros de
un solo inquilino) la vinculación automática no aplica y hay que vincular a mano.

## 8. Variables de entorno (`--dart-define`)

Ver `.env.example`. Ninguna se commiteó con valor real; `.gitignore` ya
excluye `.env*`.

```
ROBLE_BASE_URL=https://roble-api.test-openlab.uninorte.edu.co
ROBLE_CONTRACT_ID=movil_flutter_dcaabc5f4e
ROBLE_SSO_REDIRECT=innovation-hub-web-dev        # nombre, no URL
ROBLE_NATIVE_CALLBACK_SCHEME=                     # solo Microsoft en Android/iOS
INSTITUTIONAL_EMAIL_DOMAIN=uninorte.edu.co
```

## 8b. Google eliminado, y `google_sign_in` sigue en `pubspec.lock`

Se quitó todo lo propio de Google: botón, `signInWithGoogle`, la variable
`ROBLE_GOOGLE_IOS_CLIENT_ID`, el parámetro `googleIosClientId`, tests y
documentación. Los paquetes `google_sign_in*` que siguen apareciendo en
`pubspec.lock` (y en `GeneratedPluginRegistrant`) llegan como dependencia
**transitiva de `roble`**, no de este proyecto; no se pueden quitar sin
quitar el SDK, y no se ejecutan porque la app nunca llama a `signInWithGoogle`.
El repositorio Maven `google()` de `android/*.gradle.kts` es el de Android
(AndroidX), no de Google Sign-In, y se conserva.

## 8c. Corrección de "Too Many Requests"

**Causa raíz encontrada:** Roble limita el **registro a 5 por hora** (y el
login a 10 cada 15 min), y cuenta también los intentos rechazados. La app
enviaba peticiones que el servidor iba a rechazar de todos modos: aceptaba
contraseñas de 7+ caracteres cuando Roble exige 8+ con mayúscula, minúscula,
número y un símbolo de `! @ # $ _ -`; no había candado contra doble envío
(Enter en el teclado esquivaba el botón deshabilitado); y el reenvío de código
no tenía freno. Cada intento fallido gastaba cupo hasta el 429. (Además, las
pruebas con `curl` hechas durante el desarrollo desde la misma IP consumieron
parte de ese cupo; se libera solo en 1 h como máximo.)

**Qué se cambió:**
- `PasswordPolicy` valida en cliente la misma regla que Roble (registro y
  reset). El login **no** aplica esa regla: solo exige que haya contraseña.
- `AuthenticationController._guarded`: una sola petición de auth a la vez;
  las demás se ignoran. El estado se restablece en `finally` (éxito y error).
- Ante un 429: se lee `Retry-After` (envolviendo el `http.Client` del SDK, que
  no lo expone) o, si no viene, 60 s duplicando en cada 429 consecutivo hasta
  15 min. Durante el bloqueo todos los botones se deshabilitan, se muestra la
  cuenta regresiva y no se envía nada a la red. Un éxito reinicia el backoff.
- Reintentos automáticos **solo** para lecturas seguras (restaurar sesión /
  perfil) ante red, timeout o 502/503/504: máximo 2, con backoff 1 s y 2 s,
  uno a la vez. Nunca en 401/403/4xx ni 429.
- Reenvío de código con freno local de 30 s; `loadProviders` una sola vez.
- Revisado y descartado como causa: múltiples instancias del cliente (solo
  hay una, creada de forma perezosa), `onInit` duplicado (una vez por
  controlador), bucles de refresh (el SDK reintenta una sola vez tras un 401).

**Limitación:** en web el navegador solo deja leer `Retry-After` si el
servidor lo expone en `Access-Control-Expose-Headers`; si no, se usa el valor
por defecto. Solo se interpreta la forma en segundos, no la fecha HTTP.

## 8d. Cuentas duplicadas

La unicidad la impone **Roble en el servidor**: verificado que registrar un
correo existente responde `400 "El correo ya está registrado"`, también con
otras mayúsculas (`Prueba@Uninorte.edu.co`), y que el login social vincula por
correo verificado en vez de crear otro usuario. En la app se añadió: correo
normalizado (recortado y en minúsculas) en login/registro/verificación/reset,
candado contra doble envío, y mensajes claros ("ya está registrado", "ya
existe una cuenta con ese correo, inicia sesión con el método con el que la
creaste"). El identificador estable es `userId` de Roble; el correo es solo un
dato complementario. El ID propio del proveedor Microsoft no forma parte del
perfil que devuelve el SDK, por lo que no se puede guardar en la app.

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

70 pruebas en verde: mapeo/normalización del perfil, dominio institucional,
política de contraseña, `RetryPolicy` (backoff, máximo, sin reintento en
4xx/429), `RetryAfterClient`, el servicio contra un `RobleApiDataBase` real con
`MockClient` (429, duplicados, proveedores), el controlador (restauración,
login éxito/fallo, una sola petición en vuelo, cooldown por 429 con y sin
`Retry-After`, sin reintentos en 401/403, Microsoft éxito/cancelado/
deshabilitado/conflicto, registro, verificación, logout) y la pantalla de login
(botón de Microsoft presente, Google ausente).

### Pruebas que requieren credenciales reales (no incluidas)

- Login/registro reales contra Roble (se pueden crear usuarios con
  `POST /auth/movil_flutter_dcaabc5f4e/signup-direct`).
- El flujo completo de Microsoft en navegador/dispositivo: requiere que el
  proveedor esté habilitado en Roble y los destinos de retorno registrados.
- Expiración/renovación de token en una sesión larga (el access token dura 15 min).

## 12. Validación ejecutada

- `dart format lib test` — aplicado.
- `flutter analyze` — **0 issues nuevos**; 4 `info` preexistentes ajenos a auth.
- `flutter test` — **70/70**.
- `flutter build web --dart-define-from-file=.env` — **exitoso**.
- Android/iOS: **no compilado** en este entorno (Android SDK 35 en vez de 36 y
  licencias sin aceptar). Sin probar en dispositivo.
- Sin secretos en lo modificado: solo nombres de `--dart-define` y el contract id
  (un identificador público del proyecto, como una URL).

## 13. Limitaciones conocidas

1. **Microsoft no se ha probado de punta a punta**: el proveedor no está
   habilitado en Roble (`providers` devuelve `[]`). El flujo está
   implementado siguiendo el contrato del SDK, pero solo probado con mocks.
   En Android/iOS además faltan el esquema de deep link y un
   `applicationId`/bundle id definitivos.
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
- Habilitar Microsoft en la consola de Roble (Client ID, Client Secret y,
  opcionalmente, Tenant ID de Azure) y registrar los destinos de retorno.
- Para Android/iOS: el esquema de deep link a usar en `ROBLE_NATIVE_CALLBACK_SCHEME`.
- Si se debe restringir el auto-registro a `@uninorte.edu.co` (ya
  implementado con ese valor por defecto) o permitir otros dominios.
- Confirmación de qué rol por defecto deben tener los usuarios nuevos y si
  se activa propiedad por fila en `projects`, `project_comments`,
  `project_follows` — esa parte es 100% consola de Roble, no requiere
  cambios de código adicionales una vez decidida.
