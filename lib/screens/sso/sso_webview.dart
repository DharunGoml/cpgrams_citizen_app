import 'package:cpgrams_citizen_app/screens/sso/sso_callback_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SSOLoginWebView extends StatelessWidget {
  final String initialUrl;

  const SSOLoginWebView({super.key, required this.initialUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
          onLoadStart: (_, url) {
            if (url != null &&
                url.toString().startsWith('cpgrams://auth/callback')) {
              Navigator.pop(context);
              SSOCallbackHandler.handle(url.toString());
            }
          },
        ),
      ),
    );
  }
}
