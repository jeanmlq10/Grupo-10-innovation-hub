import 'package:roble/roble.dart';

/// Bounded retry with progressive backoff, for *transient* failures only.
///
/// Deliberately does not retry: 401/403 (bad credentials or permissions),
/// any other 4xx (the request itself is wrong) or 429 (retrying is exactly
/// what the server is asking us not to do — see the controller's cooldown).
/// Only used for safe reads such as restoring the session.
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(seconds: 1),
    this.sleep = _defaultSleep,
  });

  /// Retries after the first attempt, so the action runs at most
  /// `maxRetries + 1` times.
  final int maxRetries;
  final Duration baseDelay;
  final Future<void> Function(Duration) sleep;

  static Future<void> _defaultSleep(Duration d) => Future<void>.delayed(d);

  static bool isTransient(Object error) {
    if (error is RobleApiNetworkException) return true;
    if (error is RobleApiTimeoutException) return true;
    if (error is RobleApiHttpException) {
      return error.statusCode == 502 ||
          error.statusCode == 503 ||
          error.statusCode == 504;
    }
    return false;
  }

  Future<T> run<T>(Future<T> Function() action) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (error) {
        if (attempt >= maxRetries || !isTransient(error)) rethrow;
        // 1s, 2s, 4s... one attempt at a time, never concurrent.
        await sleep(baseDelay * (1 << attempt));
        attempt++;
      }
    }
  }
}
