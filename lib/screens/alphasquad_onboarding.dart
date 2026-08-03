// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AlphaSquadOnboardingScreen extends StatelessWidget {
  const AlphaSquadOnboardingScreen({super.key});

  // ----- Colors (copied 1:1 from the HTML) -----
  static const Color colorTitle = Color(0xFF0A1931); // text-[#0A1931]
  static const Color colorSubtitle = Color(0xFF1A3D63); // text-[#1A3D63]
  static const Color colorBgTop = Color(0xFFF6FAFD);
  static const Color colorBgStop2 = Color(0xFFE6F2F9);
  static const Color colorBgStop3 = Color(0xFFB3CFE5);
  static const Color colorBgStop4 = Color(0xFF4A7FA7);
  static const Color colorBgBottom = Color(0xFF1A3D63);

  // ----- Image URLs (same assets as the HTML) -----
  static const String logoUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDOdmPanobVdiNNVKKWhk8vIvjXmrSOCGan1IsFaJCYxhzhGHLP_ho9vBBmaY8d7OWKGscTh5HY3A-DaJ_HOozjjc_Xbykors1cPDogGm_EOortGilME0agOR5gBUVtUMO3RMgZtA6cxNIg-tdF1-F8NppfBjDe4C4dGBPGIu1WXMY_pTqkpWneVD34uCs55lN945PiH8JTDmm5leHuZdWMF2ecZGbHDoQCdqwSM5KSWUW3tOOLVAVIK4e6rrxtX8173imk0QfhIGS8RDM';

  static const String waveUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDlG8lVEILYRZL5e2XUrwn9iKM0Q1x_h0XZ_UqAneD9bYxcLFxKtaaNmNtfXnbK1zSDEV90EVa0AEvFFnWOa0JqLLcX_rH8GZyQDt4qHBR3A7gz1P749hV5QTqmZu_WgttU-A3HiMJDYVGmhW1NxVUhODhGbKbz1pgl0UolNgjqizs7LwN3bwhIESChNQqUmBeSVMp2HjewPwAu3mpnmDU4WJ7c7KFj9y-vW1LQySMjBlZXGa-8ZSDkUeu88X3pRwiJDayMOew5tkHV';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: Responsive.value(
              context: context,
              mobile: 450,
              tablet: 620,
              desktop: 620,
            ),
            maxHeight: Responsive.value(
              context: context,
              mobile: 800,
              tablet: 900,
              desktop: 900,
            ),
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: _MainContainer(logoUrl: logoUrl, waveUrl: waveUrl),
        ),
      ),
    );
  }
}

class _MainContainer extends StatelessWidget {
  final String logoUrl;
  final String waveUrl;

  const _MainContainer({required this.logoUrl, required this.waveUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          // ----- bg-gradient-overlay -----
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AlphaSquadOnboardingScreen.colorBgTop,
                    AlphaSquadOnboardingScreen.colorBgStop2,
                    AlphaSquadOnboardingScreen.colorBgStop3,
                    AlphaSquadOnboardingScreen.colorBgStop4,
                    AlphaSquadOnboardingScreen.colorBgBottom,
                  ],
                  stops: [0.0, 0.3, 0.6, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // ----- wave-layer (bottom 60% height, cover, bottom aligned, opacity 0.9) -----
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.6,
                widthFactor: 1.0,
                child: Opacity(
                  opacity: 0.9,
                  child: Image.network(
                    waveUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              // padding: 40px 32px 24px 32px
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- HeaderSection -----
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 48, bottom: 64),
                        child: Column(
                          children: [
                            Image.network(
                              logoUrl,
                              width: 96,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
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
                                fontSize: 30,
                                letterSpacing: -0.5,
                                color: AlphaSquadOnboardingScreen.colorTitle,
                              ),
                            ),
                            const Text(
                              'Smart Solar Energy',
                              style: TextStyle(
                                fontFamily: 'Times New Roman',
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: AlphaSquadOnboardingScreen.colorSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
  
                    // ----- HeroSection -----
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Powering a Smarter Tomorrow',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            height: 1.15,
                            color: AlphaSquadOnboardingScreen.colorTitle,
                          ),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Text(
                          'Sustainable, reliable, and intelligent solar solutions for a brighter future.',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            height: 1.6,
                            color: AlphaSquadOnboardingScreen.colorSubtitle
                                .withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
  
                    // ----- CTASection (mb-auto pushes footer down) -----
                    _GetStartedButton(),
  
                    const SizedBox(height: 48),
  
                    // ----- FooterFeatures -----
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Row(
                        children: const [
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.bolt,
                              label: 'CLEAN ENERGY',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.favorite_border,
                              label: 'ECO FRIENDLY',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _FeatureCard(
                              icon: Icons.shield_outlined,
                              label: 'RELIABLE',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          // Hook navigation/action here.
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: AlphaSquadOnboardingScreen.colorTitle, // #0A1931
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Get Started',
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    // .glass-card: rgba(255,255,255,0.1) + blur(8px) + border rgba(255,255,255,0.2) + radius 16
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
