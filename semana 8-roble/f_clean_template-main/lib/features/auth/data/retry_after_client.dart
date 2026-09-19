import 'package:http/http.dart' as http;

/// Wraps the HTTP client handed to the Roble SDK to remember the
/// `Retry-After` of the last `429` response, which the SDK does not expose.
///
/// Only the delta-seconds form is understood. The HTTP-date form is ignored
/// (it needs `dart:io`, which is unavailable on web) and callers fall back to
/// their own default. On web the header is only readable if the server lists
/// it in `Access-Control-Expose-Headers`.
class RetryAfterClient extends http.BaseClient {
  RetryAfterClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;
  Duration? _lastRetryAfter;

  /// Returns the last captured value once, then clears it.
  Duration? takeRetryAfter() {
    final value = _lastRetryAfter;
    _lastRetryAfter = null;
    return value;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 429) {
      _lastRetryAfter = parse(response.headers['retry-after']);
    }
    return response;
  }

  @override
  void close() => _inner.close();

  static Duration? parse(String? header) {
    final seconds = int.tryParse(header?.trim() ?? '');
    if (seconds == null || seconds <= 0) return null;
    return Duration(seconds: seconds);
  }
}
