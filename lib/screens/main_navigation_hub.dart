import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'analytics_page.dart';
import 'Alerts.dart';
import 'settings_screen.dart';
import 'solar_dashboard_page.dart';

import '../utils/responsive.dart';

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  /// Shared index notifier — any screen can change the tab by writing to this.
  static final pageIndex = ValueNotifier<int>(0);

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  @override
  void initState() {
    super.initState();
    MainNavigationHub.pageIndex.addListener(_onPageChanged);
    _loadUserProfilePhoto();
  }

  @override
  void dispose() {
    MainNavigationHub.pageIndex.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {});
  }

  Future<void> _loadUserProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ProfileAvatar.userProfilePhotoUrl.value = user.photoURL;
      try {
        final profile = await DatabaseService().getUserProfile(user.uid);
        if (profile != null && profile.photoUrl != null && profile.photoUrl!.isNotEmpty) {
          ProfileAvatar.userProfilePhotoUrl.value = profile.photoUrl;
        }
      } catch (e) {
        // Non-fatal
        debugPrint('Error loading user profile photo in MainNavigationHub: $e');
      }
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const SolarDashboardPage();
      case 1:
        return const AnalyticsPage();
      case 2:
        return const AlertsCenterPage();
      case 3:
        return const SettingsScreen();
      default:
        return const SolarDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final int activeIndex = MainNavigationHub.pageIndex.value;

    if (isMobile) {
      return Scaffold(
        body: IndexedStack(
          index: activeIndex,
          children: List.generate(4, (index) => _buildPage(index)),
        ),
      );
    }

    // Tablet & Desktop Layout with Side Navigation Rail
    return Scaffold(
      body: Row(
        children: [
          _SharedSideNavRail(
            activeIndex: activeIndex,
            onDestinationSelected: (index) {
              MainNavigationHub.pageIndex.value = index;
            },
          ),
          Expanded(
            child: IndexedStack(
              index: activeIndex,
              children: List.generate(4, (index) => _buildPage(index)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Side Navigation Rail for Tablet / Desktop screens
// ---------------------------------------------------------------------------
class _SharedSideNavRail extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onDestinationSelected;

  const _SharedSideNavRail({
    required this.activeIndex,
    required this.onDestinationSelected,
  });

  static const _items = [
    {'icon': Icons.grid_view_rounded, 'label': 'Dashboard'},
    {'icon': Icons.insights_rounded, 'label': 'Analytics'},
    {'icon': Icons.notifications_active, 'label': 'Alerts'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.sizeOf(context).width >= 900;
    final double railWidth = isWide ? 220 : 88;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: railWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header Logo / Brand Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 20 : 12),
              child: Row(
                mainAxisAlignment:
                    isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066CC), Color(0xFF1D4E89)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066CC).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.amber,
                      size: 26,
                    ),
                  ),
                  if (isWide) ...[
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOLARX',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'AlphaSquad',
                          style: TextStyle(
                            color: Color(0xFF85C1E9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 24),

            // Navigation Items
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                padding: EdgeInsets.symmetric(horizontal: isWide ? 14 : 12),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  final selected = i == activeIndex;

                  return InkWell(
                    onTap: () => onDestinationSelected(i),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: isWide ? 16 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue.shade600.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: selected
                            ? Border.all(color: Colors.blue.shade400, width: 1.5)
                            : Border.all(color: Colors.transparent, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: isWide
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: selected ? Colors.white : Colors.white54,
                            size: 24,
                          ),
                          if (isWide) ...[
                            const SizedBox(width: 14),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.white60,
                                fontSize: 14,
                                fontWeight:
                                    selected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer User Profile
            Padding(
              padding: EdgeInsets.all(isWide ? 16 : 12),
              child: InkWell(
                onTap: () => onDestinationSelected(3), // Navigate to Settings
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(isWide ? 10 : 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: isWide
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      const ProfileAvatar(size: 38),
                      if (isWide) ...[
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Solar System',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bottom navigation bar used by all pages.
// Writing to MainNavigationHub.pageIndex switches the tab in the hub.
// ---------------------------------------------------------------------------
class SharedBottomNav extends StatelessWidget {
  /// The tab index this page represents (highlighted tab).
  final int activeIndex;

  const SharedBottomNav({super.key, required this.activeIndex});

  static const _items = [
    {'icon': Icons.grid_view_rounded, 'label': 'Dashboard'},
    {'icon': Icons.insights_rounded, 'label': 'Analytics'},
    {'icon': Icons.notifications_active, 'label': 'Alerts'},
    {'icon': Icons.settings_outlined, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    // Hide bottom navigation bar on tablet / desktop screens (side rail active)
    if (!Responsive.isMobile(context)) {
      return const SizedBox.shrink();
    }

    // Account for the Android system navigation bar (gesture or 3-button).
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final double navBarHeight = 85 + bottomInset;

    return Container(
      width: double.infinity,
      height: navBarHeight,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: 20 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final selected = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => MainNavigationHub.pageIndex.value = i,
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: selected ? 1.0 : 0.5,
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 32,
                      height: 4,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Profile Avatar component ensuring 1:1 aspect ratio, custom sizes,
// clean circular borders, and soft shadows.
// ---------------------------------------------------------------------------
class ProfileAvatar extends StatelessWidget {
  static final userProfilePhotoUrl = ValueNotifier<String?>(null);

  final double size;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final bool showShadow;
  final String? imageUrl;

  const ProfileAvatar({
    super.key,
    this.size = 40,
    this.showBorder = true,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.showShadow = true,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userProfilePhotoUrl,
      builder: (context, globalUrl, _) {
        final displayUrl = imageUrl ?? globalUrl;
        final avatarUrl = (displayUrl != null && displayUrl.isNotEmpty)
            ? displayUrl
            : 'https://lh3.googleusercontent.com/aida-public/AB6AXuDMUGiQIxp9zxsRgYH3b0d8dsHvgiTm58zGjxx1aKruFIxzx-EeEWs1b4_d1eFNYCvMKWW9RTkSP9xHMITR4m5QBeP-USiiDlCYavmrzdrHE_JJmjpdyp_Ak5BSb3ApbN1AUFteD-BJsjzODu7cm5wWch__cRBdh4Nk-0sDWtMY1SJtpKCe9pqJoDRizKO4ftsO-UWsQi9qpTF2LcxBk66XKvqJdl19DXJ1D6RV03gc5LZFLMfY8ug0J-bU9nK9puQIyZBsHl7Xbsqo';

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF4A7FA7),
                  child: Icon(Icons.person, color: Colors.white, size: size * 0.55),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
