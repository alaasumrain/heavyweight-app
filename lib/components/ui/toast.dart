import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

enum ToastVariant { info, success, warn, error }

class HeavyweightToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastVariant variant = ToastVariant.info,
  }) {
    final bg = _bg(variant);
    final fg = variant == ToastVariant.info ? HeavyweightTheme.primary : HeavyweightTheme.onPrimary;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          content: Text(
            message,
            style: TextStyle(color: fg, fontSize: 12, letterSpacing: 0.5),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static Color _bg(ToastVariant v) {
    switch (v) {
      case ToastVariant.success:
        return Colors.green.shade600;
      case ToastVariant.warn:
        return Colors.amber.shade700;
      case ToastVariant.error:
        return HeavyweightTheme.danger;
      case ToastVariant.info:
        return HeavyweightTheme.secondary;
    }
  }
}

