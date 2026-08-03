// ignore_for_file: deprecated_member_use, unnecessary_underscores, unused_import

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Splash Screen ───────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Fade + scale animation for the logo section (1.2s, ease-out)
  late final AnimationController _logoController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  // Loading bar animation (3.5s, ease-in-out, repeating)
  late final AnimationController _loadingController;
  late final Animation<double> _loadingWidth;

  // Sunlight glow pulse animation
  late final AnimationController _glowController;
  late final Animation<double> _glowScale;

  @override
  void initState() {
    super.initState();

    // ── Logo fade-in + scale ──────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoScale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoController.forward();

    // ── Loading bar (0% → 70% → 100%, 3.5 s, repeating) ─────────────────
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
    _loadingWidth = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_loadingController);

    // ── Glow pulse (scale 0.8 ↔ 1.2, slow, repeating) ────────────────────
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Background gradient: #F6FAFD → #B3CFE5 (top to bottom)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FAFD), Color(0xFFB3CFE5)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Footer: solar panel image ─────────────────────────────────
            Positioned(bottom: 0, left: 0, right: 0, child: _FooterImage()),

            // ── Sunlight glow (pulsing) ───────────────────────────────────
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.40 - 50,
              child: AnimatedBuilder(
                animation: _glowScale,
                builder: (_, __) => Transform.scale(
                  scale: _glowScale.value,
                  child: _SunlightGlow(),
                ),
              ),
            ),

            // ── Logo + tagline + loading bar ──────────────────────────────
            AnimatedBuilder(
              animation: _logoController,
              builder: (_, child) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(scale: _logoScale.value, child: child),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo image
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA-vMvAfdd-f9vyIcODYxoOxhU8apG0eS1EQ0028olEBxFiXDtTILFm7z1evUniADRjs2PHZL1WSNciSs6gW0_qizSUzXrIu5OWoQ4W6NT3C65-MPcPaWRvKhTWEU_6AGInUBA9_Djlud5MqbCCD063AbHKuniw_GXRcOSsRwmzlzoS2-gkBLKBlxTNAI2-69TckLYRjlqwiJOCHKs4SH4YBMUP3N4CU0L3J7U5weXe-BIljI4blZ2DVHq6Kh6eMH7UpX0oBU-7zxgn',
                    width: 288,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 288,
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4A7FA7),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 288,
                        height: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: Color(0xFF4A7FA7), size: 72),
                            SizedBox(height: 8),
                            Text(
                              'AlphaSquad',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A7FA7),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Loading bar
                  AnimatedBuilder(
                    animation: _loadingWidth,
                    builder: (_, __) =>
                        _LoadingBar(progress: _loadingWidth.value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading Bar ─────────────────────────────────────────────────────────────

class _LoadingBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0

  const _LoadingBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        width: 200,
        height: 4,
        // Track: white 30% opacity + backdrop blur simulation
        color: Colors.white.withOpacity(0.3),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A7FA7),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A7FA7).withOpacity(0.8),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sunlight Glow ───────────────────────────────────────────────────────────

class _SunlightGlow extends StatelessWidget {
  const _SunlightGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 200,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}

// ─── Footer Image ────────────────────────────────────────────────────────────

class _FooterImage extends StatelessWidget {
  const _FooterImage();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.40, // 40vh
      width: double.infinity,
      child: ShaderMask(
        // Fade-in from bottom (mask: solid at bottom → transparent at top)
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.70, 1.0],
            colors: [Colors.black, Colors.transparent],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Image.network(
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD8FeiDL_StFS8Y7DengOnMr_inJEuUNROiWoPq-6ghcfr-sSK98ZsSSghGLn-Jx_5UQhxz_WerF_G9RgptLJenIOay-YwldmB6s72WsvQ2wrc3raTbJyamhMSjMY3UGxBL7ib0VteEIQW_2och-MuvKPaJjJCfrM6yiVDuFy7ZzHhGL2Za-LmNHb33ziJQc6Nw5eoephV4FHqa5mp8lAp44K78p5H1UgMUdKC-fh7tvLPslb7P6NPuHZMuwMfCbU9FnwnmVGZ0nvdW',
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox.shrink();
          },
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
