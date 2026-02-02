import 'dart:math';

class ApiHeaders {
  final String sourceId;
  final String clientId;

  ApiHeaders({required this.sourceId, required this.clientId});

  static Map<String, String> build({
    required String sourceId,
    required String clientId,
  }) {
    return {
      'x-source-id': sourceId,
      'x-client-id': clientId,
      'x-api-client-version': '1.0.1',
      'x-transaction-id': _uuid(),
      'x-request-timestamp': DateTime.now().toIso8601String(),
    };
  }

  static String _uuid() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(9999).toString();
  }
}
