import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:roble/roble.dart';

import 'package:f_clean_template/core/roble/retry_after_client.dart';
import 'package:f_clean_template/core/roble/roble_config.dart';

/// El cliente de Roble, UNO solo para toda la app.
///
/// Se crea una vez en `di/app_bindings.dart` y se inyecta en cada datasource
/// (`RobleXxxDataSource`). Crear uno por feature le daria a cada copia su
/// propia sesion: con uno solo, cada peticion lleva el token del usuario
/// logueado y Roble llena `_owner` con su userId.
///
/// El `RobleApiDataBase` se construye en el primer uso real, no aqui, para
/// que la app (y los tests) puedan pintar el login sin `ROBLE_CONTRACT_ID`.
class RobleClient {
  RobleClient({RobleAuthConfig? config, RobleApiDataBase? database})
    : config = config ?? RobleAuthConfig.fromEnvironment(),
      _database = database;

  final RobleAuthConfig config;

  /// Cliente HTTP que recuerda el `Retry-After` de un 429.
  final RetryAfterClient retryAfterClient = RetryAfterClient();

  RobleApiDataBase? _database;

  /// Hay proyecto de Roble al que hablar.
  bool get isConfigured => _database != null || config.isConfigured;

  RobleApiDataBase get db {
    final injected = _database;
    if (injected != null) return injected;
    if (!config.isConfigured) {
      throw StateError(
        'Falta configurar ROBLE_CONTRACT_ID (dart_defines.json).',
      );
    }
    final callbackScheme = config.nativeCallbackScheme.trim();
    return _database = RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: config.baseUrl,
        contractId: config.contractId,
      ),
      client: retryAfterClient,
      ssoRedirect: config.ssoRedirect.trim().isEmpty ? null : config.ssoRedirect,
      socialOpener: kIsWeb || callbackScheme.isEmpty
          ? null
          : robleNativeOpener(callbackScheme),
    );
  }

  /// userId de la sesion actual (sale del token, sin ir al servidor).
  String? get currentUserId => isConfigured ? db.currentUserId : null;

  // Nombres de las tablas, en un solo sitio: un typo aqui es un 404.
  static const projects = 'projects';
  static const tasks = 'project_tasks';
  static const requests = 'project_requests';
  static const decisions = 'request_decisions';
  static const members = 'project_members';
  static const comments = 'project_comments';
  static const follows = 'project_follows';
  static const notifications = 'app_notifications';
  static const profiles = 'user_profiles';
  static const messages = 'direct_messages';
}
