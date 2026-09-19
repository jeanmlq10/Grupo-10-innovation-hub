import 'package:f_clean_template/features/auth/data/retry_after_client.dart';
import 'package:f_clean_template/features/auth/data/retry_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:roble/roble.dart';

void main() {
  group('RetryPolicy', () {
    late List<Duration> sleeps;
    late RetryPolicy policy;

    setUp(() {
      sleeps = [];
      policy = RetryPolicy(
        maxRetries: 2,
        baseDelay: const Duration(seconds: 1),
        sleep: (d) async => sleeps.add(d),
      );
    });

    test('returns immediately on success', () async {
      var calls = 0;
      final value = await policy.run(() async {
        calls++;
        return 'ok';
      });

      expect(value, 'ok');
      expect(calls, 1);
      expect(sleeps, isEmpty);
    });

    test(
      'retries transient errors with progressive backoff, then succeeds',
      () async {
        var calls = 0;
        final value = await policy.run(() async {
          calls++;
          if (calls < 3) throw const RobleApiNetworkException('down');
          return 'ok';
        });

        expect(value, 'ok');
        expect(calls, 3);
        expect(sleeps, [
          const Duration(seconds: 1),
          const Duration(seconds: 2),
        ]);
      },
    );

    test('gives up after the maximum number of retries', () async {
      var calls = 0;
      await expectLater(
        policy.run(() async {
          calls++;
          throw const RobleApiTimeoutException('slow');
        }),
        throwsA(isA<RobleApiTimeoutException>()),
      );
      expect(calls, 3); // first attempt + 2 retries, never more
    });

    for (final status in [400, 401, 403, 404, 409, 429]) {
      test('does not retry HTTP $status', () async {
        var calls = 0;
        await expectLater(
          policy.run(() async {
            calls++;
            throw RobleApiHttpException(status, 'no');
          }),
          throwsA(isA<RobleApiHttpException>()),
        );
        expect(calls, 1);
        expect(sleeps, isEmpty);
      });
    }

    test('retries HTTP 503 up to the maximum', () async {
      var calls = 0;
      await expectLater(
        policy.run(() async {
          calls++;
          throw const RobleApiHttpException(503, 'unavailable');
        }),
        throwsA(isA<RobleApiHttpException>()),
      );
      expect(calls, 3);
    });
  });

  group('RetryAfterClient', () {
    test(
      'captures Retry-After (seconds) from a 429 and clears it once read',
      () async {
        final client = RetryAfterClient(
          MockClient(
            (_) async => http.Response('', 429, headers: {'retry-after': '7'}),
          ),
        );

        await client.get(Uri.parse('https://example.test'));

        expect(client.takeRetryAfter(), const Duration(seconds: 7));
        expect(client.takeRetryAfter(), isNull);
      },
    );

    test('ignores Retry-After on non-429 responses', () async {
      final client = RetryAfterClient(
        MockClient(
          (_) async => http.Response('', 200, headers: {'retry-after': '7'}),
        ),
      );

      await client.get(Uri.parse('https://example.test'));

      expect(client.takeRetryAfter(), isNull);
    });

    test('ignores values it cannot parse', () {
      expect(RetryAfterClient.parse('Wed, 21 Oct 2026 07:28:00 GMT'), isNull);
      expect(RetryAfterClient.parse('0'), isNull);
      expect(RetryAfterClient.parse(null), isNull);
    });
  });
}
