import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFFC107);
  static const Color primaryDark = Color(0xFFE6AC00);
  
  // Neutral Colors
  static const Color text = Color(0xFF222222);
  static const Color textLight = Color(0xFF757575); // Added for secondary text
  static const Color background = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF8F8F8);
  static const Color border = Color(0xFFE5E5E5);
  static const Color accent = Color(0xFF222222); // Reusing black for accent
  
  // Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);

  // Dark Theme Colors (Derived for consistency)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSecondaryBackground = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextLight = Color(0xFFAAAAAA);
  static const Color darkBorder = Color(0xFF333333);
}
