import 'package:cpgrams_ui_kit/components/custom_header.dart';
import 'package:flutter/material.dart';

class LandingLayout extends StatelessWidget {
  final Widget child;
  const LandingLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        variant: HeaderVariant.landing,
        onLoginPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: child,
    );
  }
}
