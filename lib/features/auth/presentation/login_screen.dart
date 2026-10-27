import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import '../data/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMethod { phone, email }

enum AuthMode { login, signup }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  AuthMethod _authMethod = AuthMethod.phone;
  AuthMode _authMode = AuthMode.login;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _onLogin() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.loginWithPhone('+91${_phoneController.text}');

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result == null) {
      if (!mounted) return;
      context.push('/otp', extra: _phoneController.text);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onEmailAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (_authMode == AuthMode.signup && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(authRepositoryProvider);
    String? error;

    if (_authMode == AuthMode.login) {
      error = await repo.loginWithEmail(
          _emailController.text, _passwordController.text);
    } else {
      error = await repo.signUpWithEmail(_emailController.text,
          _passwordController.text, _nameController.text);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0D0D0D),
      resizeToAvoidBottomInset: true,
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

          // ─── Top dark gradient (logo area) ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xCC0D0D0D), Colors.transparent],
              ),
            ),
          ),

          // ─── Bottom dark gradient (form area) ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                stops: [0.0, 0.55],
                colors: [Color(0xFF0D0D0D), Colors.transparent],
              ),
            ),
          ),

          // ─── Subtle full-screen overlay ────────────────────────────────
          Container(color: const Color(0x55000000)),

          // ─── Content ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Logo block (upper ~40% of screen) ─────────────────
                SizedBox(
                  height: size.height * 0.42,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 4),
                              child: IconButton(
                                onPressed: () => context.canPop()
                                    ? context.pop()
                                    : context.go('/welcome'),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final current =
                                          ref.read(themeModeProvider);
                                      if (current == ThemeMode.dark) {
                                        ref
                                            .read(themeModeProvider.notifier)
                                            .setThemeMode(ThemeMode.light);
                                      } else if (current == ThemeMode.light) {
                                        ref
                                            .read(themeModeProvider.notifier)
                                            .setThemeMode(ThemeMode.system);
                                      } else {
                                        ref
                                            .read(themeModeProvider.notifier)
                                            .setThemeMode(ThemeMode.dark);
                                      }
                                    },
                                    icon: Icon(
                                      ref.watch(themeModeProvider) ==
                                              ThemeMode.dark
                                          ? Icons.dark_mode
                                          : ref.watch(themeModeProvider) ==
                                                  ThemeMode.light
                                              ? Icons.light_mode
                                              : Icons.brightness_auto,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.language,
                                        color: Colors.white70, size: 20),
                                    onSelected: (val) {
                                      ref
                                          .read(localeProvider.notifier)
                                          .setLocale(Locale(val));
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                          value: 'en', child: Text('English')),
                                      const PopupMenuItem(
                                          value: 'hi', child: Text('हिंदी')),
                                      const PopupMenuItem(
                                          value: 'te', child: Text('తెలుగు')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Logo icon (image asset)
                        Image.asset(
                          'assets/images/buildmart_logo-removebg-preview.png',
                          width: size.width * 0.24,
                          height: size.width * 0.24,
                          fit: BoxFit.contain,
                        )
                            .animate()
                            .fade(duration: 500.ms)
                            .scale(begin: const Offset(0.7, 0.7)),

                        const SizedBox(height: 14),

                        // BuildMart wordmark
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Build',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 38,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextSpan(
                                text: 'Mart',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 38,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fade(delay: 150.ms, duration: 400.ms)
                            .slideY(begin: 0.2, curve: Curves.easeOut),

                        const SizedBox(height: 6),

                        // Tagline
                        const Text(
                          'BUILD BETTER TOGETHER',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 11.5,
                            color: Colors.white60,
                            letterSpacing: 3.5,
                          ),
                        ).animate().fade(delay: 250.ms, duration: 400.ms),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // ── Login form (lower ~60% of screen) ─────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Section headline
                          Text(
                            _authMode == AuthMode.login
                                ? 'Sign In to Your Account'
                                : 'Create an Account',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          )
                              .animate(key: ValueKey(_authMode))
                              .fade(duration: 300.ms)
                              .slideY(begin: 0.2, curve: Curves.easeOut),

                          const SizedBox(height: 4),

                          Text(
                            _authMethod == AuthMethod.phone
                                ? 'Enter your mobile number to continue'
                                : _authMode == AuthMode.login
                                    ? 'Enter your email and password to sign in'
                                    : 'Fill in your details to create an account',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          )
                              .animate(
                                  key: ValueKey(
                                      'subtitle_$_authMethod$_authMode'))
                              .fade(duration: 300.ms),

                          const SizedBox(height: 24),

                          // ── Auth Method Toggle ────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _authMethod = AuthMethod.phone),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _authMethod == AuthMethod.phone
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Phone',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _authMethod == AuthMethod.phone
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _authMethod = AuthMethod.email),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _authMethod == AuthMethod.email
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _authMethod == AuthMethod.email
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(delay: 400.ms, duration: 400.ms),

                          const SizedBox(height: 18),

                          // ── Input Fields ──────────────────────────────
                          if (_authMethod == AuthMethod.phone) ...[
                            _DarkTextField(
                              controller: _phoneController,
                              hintText: 'Phone Number',
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              prefix: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.white24, width: 1),
                                  ),
                                ),
                                child: const Text(
                                  '+91',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fade(duration: 400.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOut),
                          ] else ...[
                            if (_authMode == AuthMode.signup) ...[
                              _DarkTextField(
                                controller: _nameController,
                                hintText: 'Full Name',
                                keyboardType: TextInputType.name,
                              )
                                  .animate()
                                  .fade(duration: 400.ms)
                                  .slideY(begin: 0.2, curve: Curves.easeOut),
                              const SizedBox(height: 12),
                            ],
                            _DarkTextField(
                              controller: _emailController,
                              hintText: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                            )
                                .animate()
                                .fade(duration: 400.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOut),
                            const SizedBox(height: 12),
                            _DarkTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: true,
                            )
                                .animate()
                                .fade(duration: 400.ms)
                                .slideY(begin: 0.2, curve: Curves.easeOut),
                          ],

                          const SizedBox(height: 18),

                          // ── Continue / Login button ─────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_authMethod == AuthMethod.phone
                                      ? _onLogin
                                      : _onEmailAuth),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor:
                                    AppColors.primary.withValues(alpha: 0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      _authMethod == AuthMethod.phone
                                          ? 'Continue'
                                          : _authMode == AuthMode.login
                                              ? 'Sign In'
                                              : 'Create Account',
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          )
                              .animate(
                                  key: ValueKey('btn_$_authMethod$_authMode'))
                              .fade(duration: 400.ms)
                              .slideY(begin: 0.2, curve: Curves.easeOut),

                          if (_authMethod == AuthMethod.email) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _authMode = _authMode == AuthMode.login
                                        ? AuthMode.signup
                                        : AuthMode.login;
                                  });
                                },
                                child: Text(
                                  _authMode == AuthMode.login
                                      ? "Don't have an account? Sign Up"
                                      : 'Already have an account? Sign In',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // ── OR divider ────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                    color:
                                        Colors.white.withValues(alpha: 0.15)),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.0),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                    color:
                                        Colors.white.withValues(alpha: 0.15)),
                              ),
                            ],
                          ).animate().fade(delay: 580.ms, duration: 400.ms),

                          const SizedBox(height: 20),

                          // ── Google sign-in button ─────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() => _isLoading = true);
                                      final repo =
                                          ref.read(authRepositoryProvider);
                                      final success =
                                          await repo.loginWithGoogle();
                                      if (!context.mounted) return;
                                      setState(() => _isLoading = false);
                                      if (success) {
                                        context.go('/home');
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Google Sign-In failed')),
                                        );
                                      }
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.g_mobiledata,
                                  size: 26, color: Colors.white70),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fade(delay: 640.ms, duration: 400.ms)
                              .slideY(begin: 0.2, curve: Curves.easeOut),

                          const SizedBox(height: 28),

                          // ── Terms ─────────────────────────────────────
                          Center(
                            child: Text(
                              'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 11.5,
                                color: Colors.white.withValues(alpha: 0.3),
                                height: 1.6,
                              ),
                            ),
                          ).animate().fade(delay: 700.ms, duration: 400.ms),

                          const SizedBox(height: 48),
                        ],
                      ),
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

// ─── Dark-themed text field matching construction dark UI ─────────────────────
class _DarkTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final int? maxLength;
  final Widget? prefix;
  final bool obscureText;

  const _DarkTextField({
    this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.prefix,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
        counterText: '',
        prefix: prefix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
    );
  }
}
