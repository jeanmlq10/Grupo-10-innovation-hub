import 'package:f_clean_template/features/auth/domain/models/authentication_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticationUser.fromProfile', () {
    test(
      'maps every field of the profile Roble returns from login/currentUser',
      () {
        final user = AuthenticationUser.fromProfile({
          'id': 'us-3f2a',
          'userId': '9c1e',
          'email': 'ana@uninorte.edu.co',
          'name': 'Ana Garcia',
          'role': 'admin',
          'extra': {
            'career': 'Sistemas',
            'photo_url': 'https://example.com/a.png',
          },
          'createdAt': '2026-08-27T12:00:00.000Z',
          'updatedAt': null,
        });

        expect(user.id, 'us-3f2a');
        expect(user.userId, '9c1e');
        expect(user.email, 'ana@uninorte.edu.co');
        expect(user.name, 'Ana Garcia');
        expect(user.role, 'admin');
        expect(user.career, 'Sistemas');
        expect(user.photoUrl, 'https://example.com/a.png');
        expect(user.createdAt, DateTime.parse('2026-08-27T12:00:00.000Z'));
        expect(user.updatedAt, isNull);
      },
    );

    test('role is null, not a crash, when Roble has not assigned one', () {
      final user = AuthenticationUser.fromProfile({
        'id': 'us-1',
        'userId': 'u-1',
        'email': 'ana@uninorte.edu.co',
        'name': 'Ana',
        'role': null,
        'extra': {},
      });

      expect(user.role, isNull);
      expect(user.career, isNull);
      expect(user.photoUrl, isNull);
    });

    test(
      'falls back userId to id when Roble omits it (defensive, not expected)',
      () {
        final user = AuthenticationUser.fromProfile({
          'id': 'us-1',
          'email': 'ana@uninorte.edu.co',
          'name': 'Ana',
        });

        expect(user.userId, 'us-1');
      },
    );
  });
}
