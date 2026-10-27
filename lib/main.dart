import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'l10n/app_localizations.dart';
import 'features/products/data/product_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (API keys) with graceful degradation
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('.env loaded successfully.');
  } catch (e) {
    debugPrint(
        'Notice: .env file not found or failed to load ($e). Using default environment configuration.');
  }

  // Initialize Firebase (graceful degradation if not configured)
  try {
    // If you have run `flutterfire configure`, you should use options: DefaultFirebaseOptions.currentPlatform
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully.');
  } catch (e) {
    debugPrint(
        'Firebase initialization failed (Have you run flutterfire configure?): $e');
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BuildMartApp(),
    ),
  );
}

class BuildMartApp extends ConsumerWidget {
  const BuildMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
