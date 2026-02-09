import 'dart:math';

class ApiHeaders {
  static Map<String, String> build({
    required String sourceId,
    required String clientId,
    bool enableAuth = false,
    bool enableProtectedAuth = false,
    String? accessToken,
    String? guestId,
  }) {
    final headers = <String, String>{
      'x-source-id': sourceId,
      'x-client-id': clientId,
      'x-api-client-version': '1.0.1',
      'x-transaction-id': _uuid(),
      'x-request-timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    if (enableAuth) {
      headers.addAll({
        'x-guest-token': 'Bearer $accessToken',
        'x-guest-id': guestId!,
      });
    }

    if (enableProtectedAuth) {
      headers.addAll({'x-auth-token': 'Bearer $accessToken'});
    }
    return headers;
  }

  static String _uuid() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();
  }
}
