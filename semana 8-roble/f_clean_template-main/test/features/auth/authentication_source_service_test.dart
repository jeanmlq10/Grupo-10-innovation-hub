import 'package:f_clean_template/features/auth/data/datasources/remote/authentication_source_service.dart';
import 'package:f_clean_template/features/auth/data/roble_auth_config.dart';
import 'package:f_clean_template/features/auth/domain/auth_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

/// AuthenticationSourceService is now a thin adapter over the official
/// `roble` SDK (RobleApiDataBase) rather than a hand-rolled HTTP client, so
/// there is no request/response shape left here to unit-test in isolation:
/// that behavior is the SDK's own contract, tested by the `roble` package
/// itself. What this suite covers is the piece that *is* this app's
/// responsibility — failing clearly, before any network call, when the
/// project isn't configured — plus the institutional-email business rule.
///
/// Exercising real login/Google/logout flows requires a configured
/// ROBLE_CONTRACT_ID and either real or Roble-provided test credentials;
/// see the "Pruebas que requieren credenciales reales" section of
/// AUTH_DELIVERABLES.md.
void main() {
  group('AuthenticationSourceService configuration', () {
    test(
      'throws AuthConfigurationException before any call when unconfigured',
      () async {
        final source = AuthenticationSourceService(
          config: const RobleAuthConfig(
            baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
            contractId: '',
            ssoRedirect: '',
            googleIosClientId: '',
            institutionalEmailDomain: 'uninorte.edu.co',
          ),
        );

        await expectLater(
          source.login('ana@uninorte.edu.co', 'Password1!'),
          throwsA(isA<AuthConfigurationException>()),
        );
        await expectLater(
          source.signInWithGoogle(),
          throwsA(isA<AuthConfigurationException>()),
        );
      },
    );

    test(
      'does not throw at construction time (login screen must still render)',
      () {
        expect(
          () => AuthenticationSourceService(
            config: const RobleAuthConfig(
              baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
              contractId: '',
              ssoRedirect: '',
              googleIosClientId: '',
              institutionalEmailDomain: 'uninorte.edu.co',
            ),
          ),
          returnsNormally,
        );
      },
    );

    test(
      'rejects registration with a non-institutional email before calling Roble',
      () async {
        final source = AuthenticationSourceService(
          config: const RobleAuthConfig(
            baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
            contractId: 'movil_flutter_dcaabc5f4e',
            ssoRedirect: 'innovation-hub-web-dev',
            googleIosClientId: '',
            institutionalEmailDomain: 'uninorte.edu.co',
          ),
        );

        await expectLater(
          source.registerWithVerification(
            email: 'ana@gmail.com',
            password: 'Password1!',
            name: 'Ana',
          ),
          throwsA(isA<NonInstitutionalEmailException>()),
        );
      },
    );
  });
}
