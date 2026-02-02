import 'package:cpgrams_ui_kit/components/custom_header.dart';
import 'package:flutter/material.dart';

class LoginLayout extends StatelessWidget {
  final Widget child;
  const LoginLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        onLoginPressed: () => Navigator.pushNamed(context, '/login'),
      ),
      body: child,
    );
  }
}
