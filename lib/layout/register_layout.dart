import 'package:flutter/material.dart';

class RegisterLayout extends StatelessWidget {
  final Widget child;
  const RegisterLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: child));
  }
}
