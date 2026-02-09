import 'package:cpgrams_citizen_app/utils/double_back_to_close.dart';
import 'package:flutter/material.dart';

class CitizenLayout extends StatelessWidget {
  final Widget child;
  const CitizenLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: DoubleBackToCloseWidget(child: child),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
    );
  }
}
