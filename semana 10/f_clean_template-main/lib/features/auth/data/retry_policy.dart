import 'package:roble/roble.dart';

/// Bounded retry with progressive backoff, for *transient* failures only.
class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(seconds: 1),
    this.sleep = _defaultSleep,
  });

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
        await sleep(baseDelay * (1 << attempt));
        attempt++;
      }
    }
  }
}
