import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:roble/roble.dart';

import 'package:f_clean_template/core/roble/retry_after_client.dart';
import 'package:f_clean_template/core/roble/roble_config.dart';

/// El cliente de Roble, UNO solo para toda la app.
class RobleClient {
  RobleClient({RobleAuthConfig? config, RobleApiDataBase? database})
    : config = config ?? RobleAuthConfig.fromEnvironment(),
      _database = database;

  final RobleAuthConfig config;

  final RetryAfterClient retryAfterClient = RetryAfterClient();

  RobleApiDataBase? _database;

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

  String? get currentUserId => isConfigured ? db.currentUserId : null;

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
