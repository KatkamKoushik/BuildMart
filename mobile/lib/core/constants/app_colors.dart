import 'package:flutter/material.dart';

/// BuildMart Unified Color Palette Tokens
/// Aligned with `packages/shared/src/theme.ts` & Google Stitch Semantic Design Specification.
/// Guarantees >= 4.5:1 contrast across light mode and mobile OLED dark mode.
class AppColors {
  // Brand Colors (Industrial Safety Amber & Deep Navy)
  static const Color primary = Color(0xFFF59E0B); // Amber 500
  static const Color primaryDark = Color(0xFFD97706); // Amber 600
  static const Color navy = Color(0xFF0B1527); // Industrial Deep Navy
  static const Color navySurface = Color(0xFF111E36);

  // Neutral Colors (Industrial Steel Spectrum)
  static const Color text = Color(0xFF0F172A); // Slate 900 (High-contrast text)
  static const Color textLight =
      Color(0xFF64748B); // Slate 500 (Secondary metadata)
  static const Color background = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF8FAFC); // Slate 50 canvas
  static const Color border = Color(0xFFE2E8F0); // Slate 200 structural border
  static const Color accent = Color(0xFF0B1527); // Contrast navy accent

  // Status & Operational Semantics
  static const Color success =
      Color(0xFF10B981); // Emerald 500 (Verified / In-stock)
  static const Color error =
      Color(0xFFEF4444); // Red 500 (Out-of-stock / Error)
  static const Color warning =
      Color(0xFFF59E0B); // Amber 500 (Low stock / Attention)
  static const Color info =
      Color(0xFF3B82F6); // Blue 500 (Spec sheet / GST details)

  // Dark Theme Tokens (OLED High Contrast)
  static const Color darkBackground =
      Color(0xFF060C17); // True Dark OLED Canvas
  static const Color darkSecondaryBackground =
      Color(0xFF0B1527); // Dark Surface Card
  static const Color darkCard = Color(0xFF0B1527); // Dark Surface Card alias
  static const Color darkText = Color(0xFFF8FAFC); // High legibility white
  static const Color darkTextLight = Color(0xFF94A3B8); // Slate 400
  static const Color darkBorder = Color(0x1FFFFFFF); // 12% subtle white border
}
