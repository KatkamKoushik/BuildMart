import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildmart/core/theme/app_theme.dart';
import 'package:buildmart/core/constants/app_colors.dart';

void main() {
  group('AppTheme Configuration Tests', () {
    testWidgets('Light theme has correct primary color and brightness',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: Center(child: Text('Light Mode'))),
        ),
      );

      final theme = Theme.of(tester.element(find.text('Light Mode')));
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
    });

    testWidgets('Dark theme has correct dark brightness and dark background',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: Center(child: Text('Dark Mode'))),
        ),
      );

      final theme = Theme.of(tester.element(find.text('Dark Mode')));
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.darkBackground));
    });

    test('AppColors brand constants match defined design tokens', () {
      expect(AppColors.primary, equals(const Color(0xFFFFC107)));
      expect(AppColors.darkBackground, equals(const Color(0xFF121212)));
      expect(AppColors.background, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.error, equals(const Color(0xFFDC2626)));
    });
  });
}
