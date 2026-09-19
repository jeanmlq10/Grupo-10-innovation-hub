import 'package:f_clean_template/features/auth/data/roble_auth_config.dart';
import 'package:flutter_test/flutter_test.dart';

RobleAuthConfig _config({
  String contractId = 'movil_flutter_dcaabc5f4e',
  String domain = 'uninorte.edu.co',
}) => RobleAuthConfig(
  baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
  contractId: contractId,
  ssoRedirect: 'innovation-hub-web-dev',
  nativeCallbackScheme: '',
  institutionalEmailDomain: domain,
);

void main() {
  group('RobleAuthConfig', () {
    test('isConfigured is false without a contract id', () {
      expect(_config().isConfigured, isTrue);
      expect(_config(contractId: '').isConfigured, isFalse);
    });

    test('accepts an institutional email regardless of case', () {
      expect(_config().isInstitutionalEmail('Ana@Uninorte.Edu.Co'), isTrue);
    });

    test('rejects a non-institutional email', () {
      expect(_config().isInstitutionalEmail('ana@gmail.com'), isFalse);
    });

    test('accepts any domain when institutionalEmailDomain is empty', () {
      expect(_config(domain: '').isInstitutionalEmail('ana@gmail.com'), isTrue);
    });
  });
}
