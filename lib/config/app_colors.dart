import 'package:flutter/material.dart';

/// App-wide colour constants.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF6B35);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF6B6B6B);

  // Status colours
  static const Color ready = Color(0xFF1565C0);
  static const Color outForDelivery = Color(0xFFE65100);
  static const Color delivered = Color(0xFF2E7D32);

  // Aliases used in action buttons
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
}
