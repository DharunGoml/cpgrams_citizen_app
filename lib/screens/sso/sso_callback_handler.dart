import 'package:cpgrams_citizen_app/services/auth_service.dart';

class SSOCallbackHandler {
  static Future<void> handle(String callbackUrl) async {
    final uri = Uri.parse(callbackUrl);

    final code = uri.queryParameters['code'];
    final ssoType = uri.queryParameters['ssoType'];

    if (code == null || ssoType == null) return;

    await AuthAPISerivce().exchangeSSOToken(ssoType: ssoType, code: code);

    // TODO: navigate to home
  }
}
