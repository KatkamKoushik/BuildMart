import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Make status bar transparent over the background
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // ─── Full-screen construction background ───────────────────────
          SizedBox.expand(
            child: Image.asset(
              'assets/images/construction_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // ─── Gradient overlays ─────────────────────────────────────────
          // Top dark fade (covers ~55% from top)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Color(0xCC0D0D0D),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Bottom dark fade (covers ~60% from bottom)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                stops: [0.0, 0.65],
                colors: [
                  Color(0xFF0D0D0D),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Subtle full-screen overlay for uniform darkness
          Container(color: const Color(0x55000000)),

          // ─── Content ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Logo + tagline block (upper ~half of screen) ───────
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // BuildMart logo icon (image asset)
                        Image.asset(
                          'assets/images/buildmart_logo-removebg-preview.png',
                          width: size.width * 0.28,
                          height: size.width * 0.28,
                          fit: BoxFit.contain,
                        )
                            .animate()
                            .fade(duration: 600.ms)
                            .scale(begin: const Offset(0.7, 0.7)),

                        const SizedBox(height: 16),

                        // "BuildMart" wordmark
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Build',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 42,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Mart',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 42,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fade(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOut),

                        const SizedBox(height: 8),

                        // Tagline
                        const Text(
                          'BUILD BETTER TOGETHER',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.white70,
                            letterSpacing: 3.5,
                          ),
                        )
                            .animate()
                            .fade(delay: 350.ms, duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ),

                // ── Headline + buttons (lower half) ─────────────────────
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Headline
                        const Text(
                          'All Your Construction\nNeeds in One Place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        )
                            .animate()
                            .fade(delay: 450.ms, duration: 500.ms)
                            .slideY(begin: 0.25, curve: Curves.easeOut),

                        const SizedBox(height: 12),

                        // Sub-headline
                        const Text(
                          'Quality materials. Best prices.\nOn-time delivery.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.white60,
                            height: 1.6,
                          ),
                        )
                            .animate()
                            .fade(delay: 550.ms, duration: 500.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOut),

                        const SizedBox(height: 36),

                        // ── Get Started button ──────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => context.go('/home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fade(delay: 700.ms, duration: 400.ms)
                            .slideY(begin: 0.3, curve: Curves.easeOut),

                        const SizedBox(height: 14),

                        // ── Login / Sign Up outlined button ────────────
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton(
                            onPressed: () => context.push('/login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white54,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Login / Sign Up',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fade(delay: 800.ms, duration: 400.ms)
                            .slideY(begin: 0.3, curve: Curves.easeOut),

                        SizedBox(height: bottomPadding > 0 ? bottomPadding + 8 : 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


