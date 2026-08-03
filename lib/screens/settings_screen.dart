// ignore_for_file: use_build_context_synchronously, unused_element, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'main_navigation_hub.dart'
    show SharedBottomNav, ProfileAvatar, MainNavigationHub;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../models/system_settings_model.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/responsive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();

  // Profile State
  String _userName = 'Ahmed Alaa';
  String _userEmail = 'ahmed@alphasquad.com';
  String _userPhone = '+966 50 123 4567';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSystemSettings();
  }

  Future<void> _loadUserProfile() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      setState(() {
        _userName = firebaseUser.displayName ?? 'AlphaSquad User';
        _userEmail = firebaseUser.email ?? '';
        _profileImageUrl = firebaseUser.photoURL;
      });
      ProfileAvatar.userProfilePhotoUrl.value = firebaseUser.photoURL;

      try {
        final profile = await _dbService.getUserProfile(firebaseUser.uid);
        if (profile != null && mounted) {
          setState(() {
            _userName = profile.name;
            _userEmail = profile.email;
            _profileImageUrl = profile.photoUrl;
          });
          ProfileAvatar.userProfilePhotoUrl.value = profile.photoUrl;
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }

  Future<void> _loadSystemSettings() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      try {
        final settings = await _dbService.getSystemSettings(firebaseUser.uid);
        if (settings != null && mounted) {
          setState(() {
            _backupReserve = settings.backupReserve;
            _fastCharging = settings.fastCharging;
            _chargingSource = settings.chargingSource;
            _overchargeProtection = settings.overchargeProtection;
            _temperatureProtection = settings.tempProtection;
            _surgeProtection = settings.surgeProtection;
            _smartScheduling = settings.smartScheduling;
            _criticalAlerts = settings.criticalAlerts;
            _dailyEnergySummary = settings.dailyEnergySummary;
            _deviceOfflineAlerts = settings.deviceOfflineAlerts;
            _language = settings.language;
            _tempUnit = settings.tempUnit;
          });
        }
      } catch (e) {
        print('Error loading system settings: $e');
      }
    }
  }

  Future<void> _saveSettingsToFirestore() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      try {
        final settings = SystemSettingsModel(
          backupReserve: _backupReserve,
          fastCharging: _fastCharging,
          chargingSource: _chargingSource,
          overchargeProtection: _overchargeProtection,
          tempProtection: _temperatureProtection,
          surgeProtection: _surgeProtection,
          smartScheduling: _smartScheduling,
          criticalAlerts: _criticalAlerts,
          dailyEnergySummary: _dailyEnergySummary,
          deviceOfflineAlerts: _deviceOfflineAlerts,
          language: _language,
          tempUnit: _tempUnit,
        );
        await _dbService.saveSystemSettings(firebaseUser.uid, settings);
      } catch (e) {
        print('Error saving settings to Firestore: $e');
      }
    }
  }

  void _updateSetting(VoidCallback action) {
    setState(action);
    _saveSettingsToFirestore();
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        final firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading profile image...')),
          );

          final downloadUrl = await _storageService.uploadProfileImage(
            uid: firebaseUser.uid,
            filePath: image.path,
          );

          await _dbService.updateUserProfile(firebaseUser.uid, {
            'photoUrl': downloadUrl,
          });
          await firebaseUser.updatePhotoURL(downloadUrl);

          setState(() {
            _profileImageUrl = downloadUrl;
          });
          ProfileAvatar.userProfilePhotoUrl.value = downloadUrl;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile image updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Energy Management State
  double _backupReserve = 20.0;
  bool _fastCharging = true;
  String _chargingSource = 'Solar Only';

  // System Preferences State
  bool _overchargeProtection = true;
  bool _temperatureProtection = true;
  bool _surgeProtection = false;
  bool _smartScheduling = true;

  // Smart Devices State
  final List<Map<String, dynamic>> _devices = [
    {'name': 'Solar Inverter A1', 'connected': true, 'type': 'Inverter'},
    {'name': 'Lithium Battery Pack B2', 'connected': true, 'type': 'Battery'},
    {'name': 'Smart Solar Streetlight C3', 'connected': false, 'type': 'Light'},
  ];

  // Notifications State
  bool _criticalAlerts = true;
  bool _dailyEnergySummary = false;
  bool _deviceOfflineAlerts = true;

  // General State
  String _language = 'English';
  String _tempUnit = 'Celsius (°C)';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double maxW = Responsive.maxContentWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: (isMobile ? 120 : 30) + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),
                      _buildProfileCard(),
                      _buildSettingsList(),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SharedBottomNav(activeIndex: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BEGIN: MainHeader
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              MainNavigationHub.pageIndex.value = 0; // Return to Dashboard
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFAFAFA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF374151),
              ),
            ),
          ),
          // Title
          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Libre Baskerville',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          // Top Right Avatar removed to prevent duplication inside the Settings screen
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
  // END: MainHeader

  // BEGIN: ProfileCard
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x1AB3D4FF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'solar_panel.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.solar_power,
                      size: 80,
                      color: Color(0xFFBBDEFB),
                    ),
                  ),
                ),
              ),
              // Soft gradient overlay to blend white card background into the solar panel illustration on the right
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              // Profile Info Row
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileAvatar(
                          size: 80,
                          showBorder: true,
                          borderWidth: 3,
                          borderColor: Colors.white,
                          imageUrl: _profileImageUrl,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _showProfilePhotoSheet,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFF3F4F6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // User Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _userName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Libre Baskerville',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userEmail,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Active Account',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showEditProfileSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // END: ProfileCard

  // BEGIN: SettingsList
  Widget _buildSettingsList() {
    final items = [
      _SettingItemData(
        icon: Icons.bolt,
        title: 'Energy Management',
        subtitle: 'Battery, charging, and energy optimization settings',
      ),
      _SettingItemData(
        icon: Icons.settings_outlined,
        title: 'System Preferences',
        subtitle: 'System behavior, protection, and smart scheduling',
      ),
      _SettingItemData(
        icon: Icons.desktop_windows_outlined,
        title: 'Smart Devices',
        subtitle: 'Manage and connect your smart devices',
      ),
      _SettingItemData(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        subtitle: 'Alerts, reminders, and system notifications',
      ),
      _SettingItemData(
        icon: Icons.shield_outlined,
        title: 'Account & Security',
        subtitle: 'Account settings, password, and security options',
      ),
      _SettingItemData(
        icon: Icons.public,
        title: 'General',
        subtitle: 'Language, units, and other general preferences',
      ),
      _SettingItemData(
        icon: Icons.support_agent_outlined,
        title: 'Support',
        subtitle: 'Help center, guides, and contact support',
      ),
    ];

    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 24),
        child: Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSettingItem(item),
                ),
              )
              .toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 96,
        ),
        itemBuilder: (context, index) => _buildSettingItem(items[index]),
      ),
    );
  }

  Widget _buildSettingItem(_SettingItemData data) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleSettingItemTap(data),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFAFAFA)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.icon,
                  size: 28,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // END: SettingsList

  // BEGIN: Logout Dialog and Button
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          elevation: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Beautiful warning icon container
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFEF4444),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Logout Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message
                  const Text(
                    'Are you sure you want to log out? You will need to enter your email and password to log back in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Action buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm Logout Button
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () async {
                            await _authService.signOut();
                            ProfileAvatar.userProfilePhotoUrl.value = null;
                            if (context.mounted) {
                              Navigator.of(context).pop(); // Close dialog
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ).copyWith(top: 32, bottom: 16),
      child: Material(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLogoutConfirmationDialog(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFECACA).withOpacity(0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // END: Logout Button

  // ---------------------------------------------------------------------------
  // Action Handlers
  // ---------------------------------------------------------------------------
  void _handleSettingItemTap(_SettingItemData data) {
    switch (data.title) {
      case 'Energy Management':
        _showEnergyManagementSheet();
        break;
      case 'System Preferences':
        _showSystemPreferencesSheet();
        break;
      case 'Smart Devices':
        _showSmartDevicesSheet();
        break;
      case 'Notifications':
        _showNotificationsSheet();
        break;
      case 'Account & Security':
        _showAccountSecuritySheet();
        break;
      case 'General':
        _showGeneralSettingsSheet();
        break;
      case 'Support':
        _showSupportSheet();
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Bottom Sheet UI Builders
  // ---------------------------------------------------------------------------

  void _showEnergyManagementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Energy Management',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Configure battery reserve limits and charging priorities.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Backup Reserve Limit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${_backupReserve.round()}%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _backupReserve,
                    min: 0.0,
                    max: 100.0,
                    activeColor: const Color(0xFF2563EB),
                    inactiveColor: const Color(0xFFEEF2FF),
                    onChanged: (val) {
                      setModalState(() => _backupReserve = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      'Fast Charging Mode',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: const Text(
                      'Charges the battery faster using maximum available power',
                    ),
                    value: _fastCharging,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _fastCharging = val);
                      setState(() {});
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const Text(
                    'Preferred Charging Source',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Solar Only', 'Grid Priority', 'Hybrid'].map((
                      source,
                    ) {
                      final isSelected = _chargingSource == source;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => _chargingSource = source);
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              source,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Energy settings updated successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSystemPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'System Preferences',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Configure system safety limit protections and features.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text(
                      'Overcharge Protection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Prevents battery wear by stopping charge at 100%',
                    ),
                    value: _overchargeProtection,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _overchargeProtection = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Temperature Protection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Safeguards system under extreme hot/cold conditions',
                    ),
                    value: _temperatureProtection,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _temperatureProtection = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Surge Protection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Protects smart solar systems from electric surges',
                    ),
                    value: _surgeProtection,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _surgeProtection = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Smart Scheduling',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Enable automated on/off scheduling based on sunlight levels',
                    ),
                    value: _smartScheduling,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _smartScheduling = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preferences saved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Save Preferences',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSmartDevicesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        bool isScanning = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Smart Devices',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage solar system components and connected hardware.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  if (isScanning) ...[
                    const SizedBox(height: 20),
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Scanning for nearby smart solar devices...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ] else ...[
                    ..._devices.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final dev = entry.value;
                      final bool connected = dev['connected'] as bool;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: connected
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                dev['type'] == 'Inverter'
                                    ? Icons.bolt
                                    : dev['type'] == 'Battery'
                                    ? Icons.battery_charging_full
                                    : Icons.lightbulb_outline,
                                color: connected
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dev['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    connected
                                        ? 'Connected & Active'
                                        : 'Disconnected',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: connected
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: connected,
                              activeColor: const Color(0xFF2563EB),
                              onChanged: (val) {
                                setModalState(() {
                                  _devices[idx]['connected'] = val;
                                });
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setModalState(() => isScanning = true);
                        Future.delayed(const Duration(seconds: 3), () {
                          if (context.mounted) {
                            setModalState(() {
                              isScanning = false;
                              _devices.add({
                                'name': 'Smart Solar Sensor D4',
                                'connected': true,
                                'type': 'Light',
                              });
                            });
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Found and connected: Smart Solar Sensor D4!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        });
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                      label: const Text(
                        'Pair New Device',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose what system events trigger notifications on your phone.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text(
                      'Critical Alerts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'High battery temp, surge events, or hardware failures',
                    ),
                    value: _criticalAlerts,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _criticalAlerts = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Daily Energy Summary',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Daily generation and consumption insights report',
                    ),
                    value: _dailyEnergySummary,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _dailyEnergySummary = val);
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text(
                      'Device Status Alerts',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Alert when a smart component connects or goes offline',
                    ),
                    value: _deviceOfflineAlerts,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => _deviceOfflineAlerts = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications settings updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Save Choices',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAccountSecuritySheet() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool faceIdEnabled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Account & Security',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Update account security options and setup biometrics.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text(
                      'Biometric Authentication',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Use Face ID / Fingerprint to unlock app settings',
                    ),
                    value: faceIdEnabled,
                    activeColor: const Color(0xFF2563EB),
                    onChanged: (val) {
                      setModalState(() => faceIdEnabled = val);
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Current Password',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (oldPasswordController.text.isNotEmpty &&
                          newPasswordController.text.isNotEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill out password fields to change password',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Update Credentials',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGeneralSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'General Preferences',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Configure localization preferences and physical units.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'App Language',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['English', 'Arabic'].map((lang) {
                      final isSelected = _language == lang;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => _language = lang);
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lang,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Temperature Display Unit',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Celsius (°C)', 'Fahrenheit (°F)'].map((unit) {
                      final isSelected = _tempUnit == unit;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => _tempUnit = unit);
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unit,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('General preferences saved!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSupportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Help & Support Center',
                style: TextStyle(
                  fontFamily: 'Libre Baskerville',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Browse FAQs or chat directly with our technical support team.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              const ExpansionTile(
                title: Text(
                  'Why is my battery charging slow?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Solar charging speed is dependent on panel cleanliness, sun angle, and fast charging settings in your Energy Management panel.',
                    ),
                  ),
                ],
              ),
              const ExpansionTile(
                title: Text(
                  'How often should I clean the solar panels?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'We recommend washing dust and pollen off panels once every 3-6 months to maintain peak solar panel efficiency.',
                    ),
                  ),
                ],
              ),
              const ExpansionTile(
                title: Text(
                  'How do I reset my solar inverter?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'You can power cycle the inverter by switching off the breaker, waiting 30 seconds, and switching it back on.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Connecting to a live solar specialist... Chat initialized!',
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
                label: const Text(
                  'Start Live Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Edit Profile Details',
                style: TextStyle(
                  fontFamily: 'Libre Baskerville',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Change your display name, email contact, and phone number.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty) {
                    final firebaseUser = _authService.currentUser;
                    if (firebaseUser != null) {
                      try {
                        await _dbService.updateUserProfile(firebaseUser.uid, {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                        });
                        await firebaseUser.updateDisplayName(
                          nameController.text.trim(),
                        );
                      } catch (e) {
                        print('Error updating profile details: $e');
                      }
                    }
                    setState(() {
                      _userName = nameController.text;
                      _userEmail = emailController.text;
                      _userPhone = phoneController.text;
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile details updated!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Name and Email cannot be empty!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Save Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfilePhotoSheet() {
    const avatar1 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDR42WmS43VcJYil68u6CX7UF59vBqd8jokpyXsCzUNHNCpQHi1ibTzJXyLLmIS3doIdXoMVKNhKTL_rd4HRXvePB223kKcfrVTFLYNLOM7tiVdIuONr1PXPWEBLpCntqcA9BIbhRvDdMDKYCmyOH-CcMVKAkRDSNGpYYxrMwj3nmoZM1Q1dC5N-v1gkMGOM849Q9GECDDOCsF87YkSFuyCjYz2SH3qn5Ugs926apU4AjIbp0RDU5RPgg9nPjwOhs6gQ1ySmIqfhjXG';
    const avatar2 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDMUGiQIxp9zxsRgYH3b0d8dsHvgiTm58zGjxx1aKruFIxzx-EeEWs1b4_d1eFNYCvMKWW9RTkSP9xHMITR4m5QBeP-USiiDlCYavmrzdrHE_JJmjpdyp_Ak5BSb3ApbN1AUFteD-BJsjzODu7cm5wWch__cRBdh4Nk-0sDWtMY1SJtpKCe9pqJoDRizKO4ftsO-UWsQi9qpTF2LcxBk66XKvqJdl19DXJ1D6RV03gc5LZFLMfY8ug0J-bU9nK9puQIyZBsHl7Xbsqo';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontFamily: 'Libre Baskerville',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose a new picture for your profile avatar.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: Color(0xFF2563EB),
                ),
                title: const Text('Upload Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadProfileImage();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF2563EB),
                ),
                title: const Text('Use Avatar Option A'),
                onTap: () {
                  setState(() {
                    _profileImageUrl = avatar1;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar updated to Option A!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_outlined,
                  color: Color(0xFF2563EB),
                ),
                title: const Text('Use Avatar Option B'),
                onTap: () {
                  setState(() {
                    _profileImageUrl = avatar2;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar updated to Option B!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Reset to Default Avatar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  setState(() {
                    _profileImageUrl = null;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Default avatar restored!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingItemData {
  final IconData icon;
  final String title;
  final String subtitle;

  _SettingItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
