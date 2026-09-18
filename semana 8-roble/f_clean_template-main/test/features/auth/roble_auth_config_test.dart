import 'package:f_clean_template/features/auth/data/roble_auth_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RobleAuthConfig', () {
    const config = RobleAuthConfig(
      baseUrl: 'https://roble-api.test-openlab.uninorte.edu.co',
      contractId: 'movil_flutter_dcaabc5f4e',
      ssoRedirect: 'innovation-hub-web-dev',
      googleIosClientId: '',
      institutionalEmailDomain: 'uninorte.edu.co',
    );

    test('isConfigured is false without a contract id', () {
      expect(config.isConfigured, isTrue);
      expect(config.copyWithContractId('').isConfigured, isFalse);
    });

    test('accepts an institutional email regardless of case', () {
      expect(config.isInstitutionalEmail('Ana@Uninorte.Edu.Co'), isTrue);
    });

    test('rejects a non-institutional email', () {
      expect(config.isInstitutionalEmail('ana@gmail.com'), isFalse);
    });

    test('accepts any domain when institutionalEmailDomain is empty', () {
      final open = config.copyWithDomain('');
      expect(open.isInstitutionalEmail('ana@gmail.com'), isTrue);
    });
  });
}

extension on RobleAuthConfig {
  RobleAuthConfig copyWithContractId(String contractId) => RobleAuthConfig(
    baseUrl: baseUrl,
    contractId: contractId,
    ssoRedirect: ssoRedirect,
    googleIosClientId: googleIosClientId,
    institutionalEmailDomain: institutionalEmailDomain,
  );

  RobleAuthConfig copyWithDomain(String domain) => RobleAuthConfig(
    baseUrl: baseUrl,
    contractId: contractId,
    ssoRedirect: ssoRedirect,
    googleIosClientId: googleIosClientId,
    institutionalEmailDomain: domain,
  );
}
