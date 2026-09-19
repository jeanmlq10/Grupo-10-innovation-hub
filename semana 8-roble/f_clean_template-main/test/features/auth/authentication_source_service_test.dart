import 'dart:convert';

import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service.dart';
import 'package:f_clean_template/features/auth/data/roble_auth_config.dart';
import 'package:f_clean_template/features/auth/domain/auth_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:roble/roble.dart';

/// AuthenticationSourceService is a thin adapter over the official `roble`
/// SDK. These tests inject a real [RobleApiDataBase] backed by a [MockClient]
/// and in-memory storage, so no network or credentials are needed. Flows that
/// need a real Roble project (an actual Microsoft popup, real tokens) can only
/// be exercised by hand; see AUTH_DELIVERABLES.md.
const _config = RobleAuthConfig(
  baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
  contractId: 'movil_flutter_dcaabc5f4e',
  ssoRedirect: 'innovation-hub-web-dev',
  nativeCallbackScheme: '',
  institutionalEmailDomain: 'uninorte.edu.co',
);

AuthenticationSourceService _source(
  Future<http.Response> Function(http.Request) handler,
  List<http.Request> log,
) {
  final client = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: _config.baseUrl,
      contractId: _config.contractId,
    ),
    client: MockClient((request) async {
      log.add(request);
      return handler(request);
    }),
    storage: RobleMemoryStorage(),
  );
  return AuthenticationSourceService(client: client, config: _config);
}

http.Response _json(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('configuration', () {
    test('throws AuthConfigurationException when unconfigured', () async {
      final source = AuthenticationSourceService(
        config: const RobleAuthConfig(
          baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
          contractId: '',
          ssoRedirect: '',
          nativeCallbackScheme: '',
          institutionalEmailDomain: 'uninorte.edu.co',
        ),
      );

      await expectLater(
        source.login('ana@uninorte.edu.co', 'Password1!'),
        throwsA(isA<AuthConfigurationException>()),
      );
      await expectLater(
        source.signInWithMicrosoft(),
        throwsA(isA<AuthConfigurationException>()),
      );
    });

    test('does not throw at construction time', () {
      expect(
        () => AuthenticationSourceService(
          config: const RobleAuthConfig(
            baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
            contractId: '',
            ssoRedirect: '',
            nativeCallbackScheme: '',
            institutionalEmailDomain: 'uninorte.edu.co',
          ),
        ),
        returnsNormally,
      );
    });
  });

  group('registration', () {
    test('rejects a non-institutional email before calling Roble', () async {
      final log = <http.Request>[];
      final source = _source((_) async => _json({}), log);

      await expectLater(
        source.registerWithVerification(
          email: 'ana@gmail.com',
          password: 'Password1!',
          name: 'Ana',
        ),
        throwsA(isA<NonInstitutionalEmailException>()),
      );
      expect(log, isEmpty);
    });

    test('sends the email trimmed and lowercase', () async {
      final log = <http.Request>[];
      final source = _source((_) async => _json({'message': 'ok'}, 201), log);

      await source.registerWithVerification(
        email: '  Ana@Uninorte.EDU.co ',
        password: 'Password1!',
        name: ' Ana ',
      );

      final body = jsonDecode(log.single.body) as Map<String, dynamic>;
      expect(body['email'], 'ana@uninorte.edu.co');
      expect(body['name'], 'Ana');
    });

    test('an already registered email surfaces as a 4xx exception', () async {
      final source = _source(
        (_) async => _json({
          'statusCode': 400,
          'message': 'El correo ya está registrado',
        }, 400),
        [],
      );

      await expectLater(
        source.registerWithVerification(
          email: 'ana@uninorte.edu.co',
          password: 'Password1!',
          name: 'Ana',
        ),
        throwsA(
          isA<RobleApiHttpException>().having(
            (e) => e.message,
            'message',
            contains('ya está registrado'),
          ),
        ),
      );
    });
  });

  group('rate limiting', () {
    test('a 429 becomes AuthRateLimitedException', () async {
      final source = _source(
        (_) async => _json({'statusCode': 429, 'message': 'slow down'}, 429),
        [],
      );

      await expectLater(
        source.login('ana@uninorte.edu.co', 'Password1!'),
        throwsA(isA<AuthRateLimitedException>()),
      );
    });

    test('a 401 is not treated as rate limiting', () async {
      final source = _source(
        (_) async => _json({'statusCode': 401, 'message': 'no'}, 401),
        [],
      );

      await expectLater(
        source.login('ana@uninorte.edu.co', 'Password1!'),
        throwsA(isNot(isA<AuthRateLimitedException>())),
      );
    });
  });

  group('microsoft', () {
    test('is reported disabled when Roble lists no providers', () async {
      final source = _source((_) async => _json([]), []);

      expect(await source.isMicrosoftEnabled(), isFalse);
    });

    test('is reported enabled when Roble lists it', () async {
      final source = _source(
        (_) async => _json([
          {
            'name': 'microsoft',
            'displayName': 'Microsoft',
            'autoLinkSupported': true,
            'clientId': 'abc',
          },
        ]),
        [],
      );

      expect(await source.isMicrosoftEnabled(), isTrue);
    });

    test('sign-in fails clearly, without a popup, when disabled', () async {
      final source = _source((_) async => _json([]), []);
      await source.isMicrosoftEnabled();

      await expectLater(
        source.signInWithMicrosoft(),
        throwsA(isA<AuthProviderUnavailableException>()),
      );
    });
  });
}
