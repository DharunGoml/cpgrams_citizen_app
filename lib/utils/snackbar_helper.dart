import 'package:flutter/material.dart';

/// Helper class for showing consistent SnackBars throughout the app
class SnackBarHelper {
  static const _successGreenColor = Color(0xFF4CAF50);
  static const _errorRedColor = Colors.red;
  static const _warningOrangeColor = Colors.orange;

  /// Show a success message SnackBar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successGreenColor,
        duration: duration,
      ),
    );
  }

  /// Show an error message SnackBar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorRedColor,
        duration: duration,
      ),
    );
  }

  /// Show a warning message SnackBar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _warningOrangeColor,
        duration: duration,
      ),
    );
  }

  /// Show an info message SnackBar with custom background color
  static void showInfo(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: duration,
      ),
    );
  }

  /// Show a custom SnackBar with full control
  static void showCustom(
    BuildContext context, {
    required Widget content,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }
}
