// ignore_for_file: use_null_aware_elements, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';

// ----- Tailwind color tokens copied 1:1 from the HTML tailwind.config -----
class AppColors {
  static const Color primaryText = Color(0xFF0A1931); // used across headings/buttons
  static const Color onSurface = Color(0xFF171C1F);
  static const Color background = Color(0xFFF6FAFD);
  static const Color secondary = Color(0xFF2B638A);
  static const Color outline = Color(0xFF75777E);
  static const Color onSurfaceVariant = Color(0xFF44474D);
  static const Color surfaceContainer = Color(0xFFEAEEF1);
  static const Color toggleTrack = Color(0xFFB3CFE5); // bg-[#B3CFE5]/40
}

class AlphaSquadLoginScreen extends StatefulWidget {
  final bool isInitialLogin;
  const AlphaSquadLoginScreen({super.key, this.isInitialLogin = true});

  @override
  State<AlphaSquadLoginScreen> createState() => _AlphaSquadLoginScreenState();
}

class _AlphaSquadLoginScreenState extends State<AlphaSquadLoginScreen> {
  late bool _isLogin;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final AuthService _authService = AuthService();

  // Password visibility states
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  bool _agreedToTerms = false;

  // Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();

  static const String backgroundUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDR42WmS43VcJYil68u6CX7UF59vBqd8jokpyXsCzUNHNCpQHi1ibTzJXyLLmIS3doIdXoMVKNhKTL_rd4HRXvePB223kKcfrVTFLYNLOM7tiVdIuONr1PXPWEBLpCntqcA9BIbhRvDdMDKYCmyOH-CcMVKAkRDSNGpYYxrMwj3nmoZM1Q1dC5N-v1gkMGOM849Q9GECDDOCsF87YkSFuyCjYz2SH3qn5Ugs926apU4AjIbp0RDU5RPgg9nPjwOhs6gQ1ySmIqfhjXG';

  static const String logoUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBPZkwoX08Uws2PO_8Cr7-sprbaqA6UWGWWHIXRROJeiYx6ahNPLvZPwqpFoqF3xe9w1McbqhY01FU5ayKymeVUJOSbDsKxIrXyw8ve2ldiz_m6DMfyRO02_ip54-hC6AqEy-yXOSbdiu3Nt-pl6H8fk4t2cs0CNRcRH9m90_r01zAlnpsAySw7DddFgb3m_mYjSuAR6Zqs8sW2x0eQAy1ncv-ewRmgqULqdLlmAvyiNmazEsRzE7Ug8GYlyzzbAKMEBhPmxqIqIEJJxBM';

  // PNG render of the Google "G" mark
  static const String googleLogoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png';

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isInitialLogin;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ----- Fixed parallax background -----
          Positioned.fill(
            child: Image.network(
              backgroundUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.background),
            ),
          ),

          // ----- Main scrollable content (max-width 430) -----
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.value(
                      context: context,
                      mobile: 430,
                      tablet: 560,
                      desktop: 560,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ----- Header Section (Static) -----
                      _buildLogoSection(),

                      const SizedBox(height: 32),

                      // ----- Segmented Control (Toggle Tab) -----
                      _buildTabToggle(),

                      const SizedBox(height: 32),

                      // ----- Form Container with Switch Transition -----
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _isLogin
                            ? _buildLoginForm(key: const ValueKey('login_form'))
                            : _buildRegisterForm(key: const ValueKey('register_form')),
                      ),

                      const SizedBox(height: 24),

                      // ----- Social Login Section (Static) -----
                      _buildSocialSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ----- Floating Star Accent (fixed bottom-right) -----
          Positioned(
            bottom: 24,
            right: 24,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.3,
                child: Icon(Icons.star, size: 36, color: AppColors.primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Header Logo helper -----
  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.network(
          logoUrl,
          width: 96,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.wb_sunny,
            size: 96,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'AlphaSquad',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            height: 1.0,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Smart Solar Energy',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0.5,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  // ----- Login / Register toggle button -----
  Widget _buildTabToggle() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.toggleTrack.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Sliding active indicator
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: _isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryText,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryText.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tab buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = true),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isLogin ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isLogin = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isLogin ? AppColors.primaryText : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- Login Form builder -----
  Widget _buildLoginForm({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sign in to continue to your account',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),

        // Email or Phone field
        _glassInput(
          controller: _loginEmailController,
          icon: Icons.person_outline,
          hint: 'Email or Phone',
        ),
        const SizedBox(height: 16),

        // Password field
        _glassInput(
          controller: _loginPasswordController,
          icon: Icons.lock_outline,
          hint: 'Password',
          obscureText: _obscureLoginPassword,
          suffix: IconButton(
            icon: Icon(
              _obscureLoginPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.primaryText.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() => _obscureLoginPassword = !_obscureLoginPassword);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Forgot Password link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              _showForgotPasswordDialog(context);
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Login Button
        _buildButton(
          text: 'Login',
          isLoading: _isLoading,
          onTap: () async {
            if (_loginEmailController.text.isEmpty ||
                _loginPasswordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }
            setState(() => _isLoading = true);
            try {
              await _authService.signInWithEmailAndPassword(
                email: _loginEmailController.text.trim(),
                password: _loginPasswordController.text.trim(),
              );
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          },
        ),
      ],
    );
  }

  // ----- Register Form builder -----
  Widget _buildRegisterForm({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Subtitle
        const Text(
          'Create Account',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create a new account to get started',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),

        // Full Name field
        _glassInput(
          controller: _registerNameController,
          icon: Icons.person_outline,
          hint: 'Enter your full name',
        ),
        const SizedBox(height: 16),

        // Email or Phone field
        _glassInput(
          controller: _registerEmailController,
          icon: Icons.contact_mail_outlined,
          hint: 'Enter your email or phone number',
        ),
        const SizedBox(height: 16),

        // Password field
        _glassInput(
          controller: _registerPasswordController,
          icon: Icons.lock_outline,
          hint: 'Create a password',
          obscureText: _obscureRegisterPassword,
          suffix: IconButton(
            icon: Icon(
              _obscureRegisterPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.primaryText.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() => _obscureRegisterPassword = !_obscureRegisterPassword);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Confirm Password field
        _glassInput(
          controller: _registerConfirmPasswordController,
          icon: Icons.lock_outline,
          hint: 'Confirm your password',
          obscureText: _obscureRegisterConfirmPassword,
          suffix: IconButton(
            icon: Icon(
              _obscureRegisterConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.primaryText.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() => _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Terms Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _agreedToTerms = !_agreedToTerms);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 2),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _agreedToTerms
                      ? AppColors.primaryText
                      : Colors.white.withOpacity(0.4),
                  border: Border.all(
                    color: _agreedToTerms
                        ? AppColors.primaryText
                        : AppColors.outline,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _agreedToTerms
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _agreedToTerms = !_agreedToTerms);
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Register Button
        _buildButton(
          text: 'Register',
          isLoading: _isLoading,
          onTap: () async {
            if (_registerNameController.text.isEmpty ||
                _registerEmailController.text.isEmpty ||
                _registerPasswordController.text.isEmpty ||
                _registerConfirmPasswordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }
            if (_registerPasswordController.text != _registerConfirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Passwords do not match')),
              );
              return;
            }
            if (!_agreedToTerms) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You must agree to the Terms & Conditions')),
              );
              return;
            }
            setState(() => _isLoading = true);
            try {
              await _authService.signUpWithEmailAndPassword(
                name: _registerNameController.text.trim(),
                email: _registerEmailController.text.trim(),
                password: _registerPasswordController.text.trim(),
              );
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          },
        ),
      ],
    );
  }

  // ----- Submit buttons helper -----
  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primaryText,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryText.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ----- Glassmorphism input field helper -----
  Widget _glassInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryText),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 18,
                    color: AppColors.primaryText,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 18,
                      color: AppColors.primaryText.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ),
    );
  }

  // ----- Social section helper -----
  Widget _buildSocialSection() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.outline.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.outline.withOpacity(0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Icon-only buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIconButton(
              onTap: _isGoogleLoading
                  ? null
                  : () async {
                      setState(() => _isGoogleLoading = true);
                      try {
                        await _authService.signInWithGoogle();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isGoogleLoading = false);
                      }
                    },
              child: _isGoogleLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                      ),
                    )
                  : Image.network(
                googleLogoUrl,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'G',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            _socialIconButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing in with Apple...')),
                );
              },
              child: const Icon(Icons.apple, size: 28, color: Colors.black),
            ),
            const SizedBox(width: 24),
            _socialIconButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing in with Facebook...')),
                );
              },
              child: const Icon(Icons.facebook, size: 28, color: Color(0xFF1877F2)),
            ),
          ],
        ),

        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: AppColors.onSurfaceVariant.withOpacity(0.7),
              ),
              children: const [
                TextSpan(text: 'By continuing, you agree to our\n'),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ----- Icon-only social button -----
  Widget _socialIconButton({required Widget child, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryText.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to receive a password reset link:'),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;
                try {
                  await _authService.sendPasswordResetEmail(email);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password reset email sent!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                    );
                  }
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }
}
