// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import "package:solarx/screens/solar_dashboard_page.dart";
import 'package:solarx/screens/solar_dashboard_page.dart'
    show SolarisColors;
import 'main_navigation_hub.dart'
    show SharedBottomNav, ProfileAvatar, MainNavigationHub;
import '../services/weather_service.dart';
import '../models/weather_model.dart';

import '../utils/responsive.dart';

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────
const Color kBrandBlue = Color(0xFF1E4BA1);
const Color kBrandDark = Color(0xFF0A1931);
const Color kBackground = Color(0xFFF6FAFD);
const Color kSurface = Color(0xFFFFFFFF);
const Color kContainerLow = Color(0xFFF0F4F7);

// ─────────────────────────────────────────────
//  MAIN PAGE
// ─────────────────────────────────────────────
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedTimeRange = 'Last 24 Hours';

  @override
  void initState() {
    super.initState();
    WeatherService.fetchWeather();
  }

  void _showTimeRangeSheet() {
    final ranges = [
      'Last 6 Hours',
      'Last 24 Hours',
      'Last 7 Days',
      'Last 30 Days',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Select Time Range',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kBrandDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...ranges.map((range) {
                    final isSelected = _selectedTimeRange == range;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedTimeRange = range);
                        setModalState(() {});
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Now showing: $range'),
                            backgroundColor: kBrandBlue,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kBrandDark
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? kBrandDark
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              size: 18,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              range,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : kBrandDark,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double maxW = Responsive.maxContentWidth(context);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Stack(
              children: [
                // Scrollable content
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: (isMobile ? 90 : 30) + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TopHeader(),
                      const _DashboardIntro(),
                      const _SectionLabel('AI Control Center'),
                      const _AIControlCenterRow(),
                      const SizedBox(height: 24),
                      const _SectionLabelPadded('Energy Overview'),
                      const _EnergyOverviewGrid(),
                      const SizedBox(height: 24),
                      _OperationalEnergyAnalysis(
                        selectedTimeRange: _selectedTimeRange,
                        onTimeRangeTap: _showTimeRangeSheet,
                      ),
                      const SizedBox(height: 24),
                      const _PredictionAndAlerts(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Fixed bottom nav
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SharedBottomNav(activeIndex: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  TOP HEADER
// ─────────────────────────────────────────────
class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => MainNavigationHub.pageIndex.value = 3,
            child: const ProfileAvatar(size: 40),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DASHBOARD INTRO
// ─────────────────────────────────────────────
class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'AI Smart Lighting Center',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kBrandDark,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'AI Decision & Performance Analytics',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SECTION LABELS
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 4,
            decoration: BoxDecoration(
              color: kBrandBlue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: kBrandDark,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabelPadded extends StatelessWidget {
  final String title;
  const _SectionLabelPadded(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 4,
            decoration: BoxDecoration(
              color: kBrandBlue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: kBrandDark,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  AI CONTROL CENTER ROW (horizontal scroll)
// ─────────────────────────────────────────────
class _AIControlCenterRow extends StatelessWidget {
  const _AIControlCenterRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: const [
          _AISystemStatusCard(),
          SizedBox(width: 16),
          _AIDecisionCard(),
          SizedBox(width: 16),
          _WeatherCard(),
        ],
      ),
    );
  }
}

// Card 1 – AI System Status
class _AISystemStatusCard extends StatelessWidget {
  const _AISystemStatusCard();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. AI SYSTEM STATUS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Circular progress
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(76, 76),
                      painter: _RingPainter(
                        value: 0.75,
                        trackColor: const Color(0xFFEFF6FF),
                        progressColor: kBrandBlue,
                        strokeWidth: 5,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kBrandBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kBrandBlue.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Mode',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'AI Decision Engine',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Running',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Card 2 – AI Decision
class _AIDecisionCard extends StatelessWidget {
  const _AIDecisionCard();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  text: '5. AI DECISION ',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.8,
                  ),
                  children: [
                    TextSpan(
                      text: '(LATEST)',
                      style: TextStyle(fontSize: 8, color: Color(0xFFD1D5DB)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                color: Color(0xFF4A7FA7),
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'AI reduced brightness to 70% to preserve battery power.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kBrandDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Confidence: 96%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: kBrandBlue,
              ),
            ),
          ),
          const Spacer(),
          const Divider(height: 1, color: Color(0xFFF8FAFC)),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12:30 PM',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Today',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Card 3 – Weather
class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WeatherModel?>(
      valueListenable: WeatherService.weatherNotifier,
      builder: (context, weather, _) {
        final tempStr = weather != null ? '${weather.temp.round()}°C' : '31°C';
        final conditionStr = weather != null ? weather.condition : 'Sunny';
        final cloudStr = weather != null ? '${weather.cloudCover}%' : '15%';
        final solarStr = weather != null ? weather.solarLevel : 'High';
        final humidStr = weather != null ? '${weather.humidity}%' : '42%';

        // Dynamic Icons and colors
        IconData weatherIcon = Icons.wb_sunny;
        Color iconColor = Colors.amber.shade400;
        if (weather != null) {
          final cond = weather.condition.toLowerCase();
          if (cond.contains('cloud')) {
            weatherIcon = Icons.cloud;
            iconColor = const Color(0xFF64748B);
          } else if (cond.contains('rain')) {
            weatherIcon = Icons.water_drop;
            iconColor = const Color(0xFF3B82F6);
          } else if (cond.contains('snow')) {
            weatherIcon = Icons.ac_unit;
            iconColor = const Color(0xFF93C5FD);
          }
        }

        return _WhiteCard(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '6. WEATHER ANALYSIS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.8,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: WeatherService.isLoadingNotifier,
                    builder: (context, isLoading, _) {
                      if (isLoading) {
                        return const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kBrandBlue,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(weatherIcon, color: iconColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        conditionStr,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: kBrandDark,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    tempStr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kBrandDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WeatherStat('Cloud', cloudStr),
                  _WeatherStat('Solar', solarStr),
                  _WeatherStat('Humid', humidStr),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final String label;
  final String value;
  const _WeatherStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kBrandDark,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ENERGY OVERVIEW GRID (2×2)
// ─────────────────────────────────────────────
class _EnergyOverviewGrid extends StatelessWidget {
  const _EnergyOverviewGrid();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: isMobile ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isMobile ? 0.95 : 1.05,
        children: const [
          _EnergyDonutCard(
            label: '3. BATTERY CHARGE',
            icon: Icons.battery_charging_full,
            iconColor: kBrandBlue,
            progressColor: kBrandBlue,
            value: 0.82,
            centerTop: '82%',
            centerTopStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            centerBottom: 'SAFE',
            centerBottomColor: Color(0xFF22C55E),
            subLabel: 'Estimated Runtime',
            subValue: '8.6 Hours',
          ),
          _EnergyDonutCard(
            label: '4. SOLAR PRODUCTION',
            icon: Icons.solar_power,
            iconColor: Color(0xFF60A5FA),
            progressColor: Color(0xFF60A5FA),
            value: 0.60,
            centerTop: '850W',
            centerTopStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            centerBottom: 'NOW',
            centerBottomColor: Color(0xFF3B82F6),
            subLabel: "Today's Total",
            subValue: '6.8 kWh',
          ),
          _EnergyDonutCard(
            label: '2. LIGHTING STATUS',
            icon: Icons.lightbulb,
            iconColor: Color(0xFF1E3A8A),
            progressColor: Color(0xFF1E3A8A),
            value: 0.90,
            centerTop: '18/20',
            centerTopStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            centerBottom: 'ACTIVE',
            centerBottomColor: Color(0xFF1E3A8A),
            subLabel: 'System Active',
            subValue: '90%',
          ),
          _EnergyDonutCard(
            label: '10. ENERGY SAVING',
            icon: Icons.energy_savings_leaf,
            iconColor: Color(0xFF3B82F6),
            progressColor: Color(0xFF3B82F6),
            value: 0.23,
            centerTop: '23%',
            centerTopStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            centerBottom: 'SAVED',
            centerBottomColor: Color(0xFF3B82F6),
            subLabel: 'Vs. Traditional',
            subValue: 'Today',
          ),
        ],
      ),
    );
  }
}

class _EnergyDonutCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color progressColor;
  final double value;
  final String centerTop;
  final TextStyle centerTopStyle;
  final String centerBottom;
  final Color centerBottomColor;
  final String subLabel;
  final String subValue;

  const _EnergyDonutCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.progressColor,
    required this.value,
    required this.centerTop,
    required this.centerTopStyle,
    required this.centerBottom,
    required this.centerBottomColor,
    required this.subLabel,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(64, 64),
                  painter: _RingPainter(
                    value: value,
                    trackColor: const Color(0xFFF3F4F6),
                    progressColor: progressColor,
                    strokeWidth: 4.5,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: iconColor, size: 13),
                    Text(
                      centerTop,
                      style: centerTopStyle.copyWith(height: 1.1),
                    ),
                    Text(
                      centerBottom,
                      style: TextStyle(
                        fontSize: 6,
                        color: centerBottomColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subLabel,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: const TextStyle(
              fontSize: 10,
              color: kBrandDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  OPERATIONAL ENERGY ANALYSIS
// ─────────────────────────────────────────────
class _OperationalEnergyAnalysis extends StatefulWidget {
  final String selectedTimeRange;
  final VoidCallback onTimeRangeTap;

  const _OperationalEnergyAnalysis({
    required this.selectedTimeRange,
    required this.onTimeRangeTap,
  });

  @override
  State<_OperationalEnergyAnalysis> createState() =>
      _OperationalEnergyAnalysisState();
}

class _OperationalEnergyAnalysisState
    extends State<_OperationalEnergyAnalysis> {
  _DecisionPoint? _activePoint;
  Offset _tooltipOffset = Offset.zero;

  static const List<_DecisionPoint> _markers = [
    _DecisionPoint(
      x: 172,
      y: 110,
      time: '10:21 AM',
      prod: '420W',
      usage: '112W',
      decision: 'Brightness reduced to 70%',
    ),
    _DecisionPoint(
      x: 229,
      y: 12,
      time: '01:45 PM',
      prod: '920W',
      usage: '118W',
      decision: 'Energy-saving mode activated',
    ),
    _DecisionPoint(
      x: 308,
      y: 70,
      time: '06:30 PM',
      prod: '120W',
      usage: '580W',
      decision: 'Brightness increased to 100%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'OPERATIONAL ENERGY ANALYSIS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onTimeRangeTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          widget.selectedTimeRange,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: kBrandDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 12,
                          color: kBrandDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _LegendItem(
                  color: kBrandBlue,
                  label: 'Solar Production (W)',
                  dashed: false,
                ),
                _LegendItem(
                  color: const Color(0xFF93C5FD),
                  label: 'Energy Consumption (W)',
                  dashed: true,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kBrandDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Decisions',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chart area
            SizedBox(
              height: 200,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Y-axis labels
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '1000',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '750',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '500',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '250',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chart + markers
                  Positioned(
                    left: 28,
                    right: 0,
                    top: 0,
                    bottom: 20,
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        final scaleX = w / 400;
                        final scaleY = h / 150;
                        return GestureDetector(
                          onTapDown: (d) {
                            bool hit = false;
                            for (final m in _markers) {
                              final mx = m.x * scaleX;
                              final my = m.y * scaleY;
                              if ((d.localPosition - Offset(mx, my)).distance <
                                  18) {
                                setState(() {
                                  _activePoint = m;
                                  _tooltipOffset = Offset(mx, my);
                                });
                                hit = true;
                                break;
                              }
                            }
                            if (!hit) setState(() => _activePoint = null);
                          },
                          child: Stack(
                            children: [
                              // SVG-equivalent chart
                              CustomPaint(
                                size: Size(w, h),
                                painter: _ChartPainter(
                                  scaleX: scaleX,
                                  scaleY: scaleY,
                                ),
                              ),
                              // Marker circles
                              for (final m in _markers)
                                Positioned(
                                  left: m.x * scaleX - 6,
                                  top: m.y * scaleY - 6,
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _activePoint = (_activePoint == m)
                                          ? null
                                          : m;
                                      _tooltipOffset = Offset(
                                        m.x * scaleX,
                                        m.y * scaleY,
                                      );
                                    }),
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: kBrandDark,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // Tooltip
                              if (_activePoint != null)
                                Positioned(
                                  left: (_tooltipOffset.dx - 70).clamp(
                                    0,
                                    w - 150,
                                  ),
                                  top: (_tooltipOffset.dy - 90).clamp(
                                    0,
                                    h - 100,
                                  ),
                                  child: _ChartTooltip(point: _activePoint!),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // X-axis labels
                  Positioned(
                    left: 28,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '00:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '04:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '08:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '12:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '16:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '20:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '24:00',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1, color: Color(0xFFF8FAFC)),
            const SizedBox(height: 16),

            // AI System Insights
            const Text(
              'AI SYSTEM INSIGHTS',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF9CA3AF),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _Insight(
              color: kBrandBlue,
              text: 'Peak solar production reached 920W at 13:45.',
            ),
            _Insight(
              color: Color(0xFF93C5FD),
              text: 'AI reduced lighting output by 30% during low occupancy.',
            ),
            _Insight(
              color: Color(0xFF22C55E),
              text:
                  'Energy savings increased by 23% compared to normal operation.',
            ),
            _Insight(
              color: Color(0xFFFB923C),
              text: 'Consumption exceeded production between 18:00 and 21:00.',
            ),

            const SizedBox(height: 20),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: const [
                _StatCard(
                  label: 'TOTAL SOLAR GENERATED',
                  value: '6.8',
                  unit: 'kWh',
                  valueColor: kBrandDark,
                ),
                _StatCard(
                  label: 'TOTAL CONSUMED',
                  value: '5.2',
                  unit: 'kWh',
                  valueColor: kBrandDark,
                ),
                _StatCard(
                  label: 'AI ENERGY SAVED',
                  value: '1.6',
                  unit: 'kWh',
                  valueColor: kBrandBlue,
                ),
                _StatCard(
                  label: 'EFFICIENCY IMPROVEMENT',
                  value: '23%',
                  unit: '',
                  valueColor: Color(0xFF16A34A),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _LegendItem({
    required this.color,
    required this.label,
    required this.dashed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(12, 2),
          painter: _LinePainter(color: color, dashed: dashed),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _LinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (dashed) {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, size.height / 2),
          Offset(x + 3, size.height / 2),
          paint,
        );
        x += 5;
      }
    } else {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Insight extends StatelessWidget {
  final Color color;
  final String text;
  const _Insight({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kBrandDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color valueColor;
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
              children: unit.isNotEmpty
                  ? [
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(fontSize: 9, color: kBrandDark),
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Chart painter matching the SVG paths from HTML
class _ChartPainter extends CustomPainter {
  final double scaleX, scaleY;
  const _ChartPainter({required this.scaleX, required this.scaleY});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Energy Consumption (dashed light-blue)
    final consumptionPaint = Paint()
      // Use the same chart dashed color as the dashboard for consistency
      ..color = SolarisColors.chartDashed
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final consumptionPath = Path();
    final consumePoints = [
      Offset(0, 120),
      Offset(40, 115),
      Offset(80, 80),
      Offset(100, 85),
      Offset(150, 110),
      Offset(200, 115),
      Offset(250, 120),
      Offset(280, 95),
      Offset(300, 70),
      Offset(350, 60),
      Offset(380, 110),
      Offset(400, 125),
    ];

    consumptionPath.moveTo(
      consumePoints[0].dx * scaleX,
      consumePoints[0].dy * scaleY,
    );
    for (int i = 1; i < consumePoints.length; i++) {
      consumptionPath.lineTo(
        consumePoints[i].dx * scaleX,
        consumePoints[i].dy * scaleY,
      );
    }

    // Draw dashed
    final dashLen = 4.0 * scaleX;
    final gapLen = 3.0 * scaleX;
    final dashes = _dashPath(consumptionPath, dashLen, gapLen);
    canvas.drawPath(dashes, consumptionPaint);

    // Solar Production (solid brand blue)
    final solarPaint = Paint()
      ..color = kBrandBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final solarPath = Path();
    // M0,150 L100,150 C120,145 160,100 200,40 C220,15 240,12 260,35 C280,60 310,120 333,150 L400,150
    solarPath.moveTo(0 * scaleX, 150 * scaleY);
    solarPath.lineTo(100 * scaleX, 150 * scaleY);
    solarPath.cubicTo(
      120 * scaleX,
      145 * scaleY,
      160 * scaleX,
      100 * scaleY,
      200 * scaleX,
      40 * scaleY,
    );
    solarPath.cubicTo(
      220 * scaleX,
      15 * scaleY,
      240 * scaleX,
      12 * scaleY,
      260 * scaleX,
      35 * scaleY,
    );
    solarPath.cubicTo(
      280 * scaleX,
      60 * scaleY,
      310 * scaleX,
      120 * scaleY,
      333 * scaleX,
      150 * scaleY,
    );
    solarPath.lineTo(400 * scaleX, 150 * scaleY);
    canvas.drawPath(solarPath, solarPaint);
  }

  Path _dashPath(Path source, double dashLen, double gapLen) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double dist = 0;
      bool draw = true;
      while (dist < metric.length) {
        final len = draw ? dashLen : gapLen;
        final end = (dist + len).clamp(0.0, metric.length);
        if (draw) {
          result.addPath(metric.extractPath(dist, end), Offset.zero);
        }
        dist = end;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Tooltip data model
class _DecisionPoint {
  final double x, y;
  final String time, prod, usage, decision;
  const _DecisionPoint({
    required this.x,
    required this.y,
    required this.time,
    required this.prod,
    required this.usage,
    required this.decision,
  });
}

class _ChartTooltip extends StatelessWidget {
  final _DecisionPoint point;
  const _ChartTooltip({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kBrandDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                point.time,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${point.prod} Prod',
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF93C5FD),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Usage:',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                point.usage,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 4),
          Text(
            point.decision,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF4ADE80),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PREDICTION & ALERTS
// ─────────────────────────────────────────────
class _PredictionAndAlerts extends StatelessWidget {
  const _PredictionAndAlerts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: const [
          _EnergyPredictionCard(),
          SizedBox(height: 16),
          _SmartAlertsCard(),
        ],
      ),
    );
  }
}

class _EnergyPredictionCard extends StatelessWidget {
  const _EnergyPredictionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7. ENERGY PREDICTION',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Night Capacity',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '8.2 Hours Remaining',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: kBrandDark,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Forecast: Sufficient',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.check, color: Color(0xFF10B981), size: 11),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bar chart
              Container(
                height: 80,
                padding: const EdgeInsets.only(left: 16),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFF8FAFC))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Bar(height: 0.40, color: const Color(0xFFDBEAFE)),
                    _Bar(height: 0.60, color: const Color(0xFFBFDBFE)),
                    _Bar(height: 0.35, color: const Color(0xFF93C5FD)),
                    _Bar(height: 0.55, color: const Color(0xFF60A5FA)),
                    _Bar(height: 0.80, color: const Color(0xFF3B82F6)),
                    _Bar(height: 0.90, color: kBrandBlue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                'Now',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '16:00',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '20:00',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '24:00',
                style: TextStyle(
                  fontSize: 7,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: SizedBox(
        width: 6,
        height: 80 * height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
      ),
    );
  }
}

class _SmartAlertsCard extends StatelessWidget {
  const _SmartAlertsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '8. SMART ALERTS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: () => MainNavigationHub.pageIndex.value = 2,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: kBrandBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AlertRow(
            bgColor: const Color(0xFFFEFCE8),
            iconColor: const Color(0xFFFACC15),
            icon: Icons.warning_amber_rounded,
            message: 'Solar panel efficiency reduced 5%',
            time: '10:21 AM',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '⚠️ Solar panel efficiency dropped — check Panel Group 02',
                ),
                backgroundColor: Color(0xFFF97316),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AlertRow(
            bgColor: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFFB923C),
            icon: Icons.battery_alert,
            message: 'Battery below 30% expected soon',
            time: '09:45 AM',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🔋 Battery at 24% — consider reducing energy load tonight.',
                ),
                backgroundColor: Color(0xFFFB923C),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AlertRow(
            bgColor: const Color(0xFFFEF2F2),
            iconColor: const Color(0xFFEF4444),
            icon: Icons.build_circle_outlined,
            message: 'Lamp #12 requires maintenance',
            time: 'Yesterday',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🔧 Lamp #12 flagged for maintenance. Tap Alerts for details.',
                ),
                backgroundColor: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final Color bgColor, iconColor;
  final IconData icon;
  final String message, time;
  final VoidCallback? onTap;
  const _AlertRow({
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.message,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kBrandDark,
                height: 1.4,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// _BottomNav, _NavItem, _NavItemBadge removed — using SharedBottomNav from main_navigation_hub.dart

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final Widget child;
  final double? width;
  const _WhiteCard({required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
//  RING PAINTER  (circular progress)
// ─────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double value;
  final Color trackColor, progressColor;
  final double strokeWidth;

  const _RingPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * pi,
      false,
      trackPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * pi * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
