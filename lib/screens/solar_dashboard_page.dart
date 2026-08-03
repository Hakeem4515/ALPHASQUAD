// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'main_navigation_hub.dart' show SharedBottomNav, ProfileAvatar, MainNavigationHub;
import '../services/weather_service.dart';
import '../models/weather_model.dart';

import '../utils/responsive.dart';

// ---------------------------------------------------------------------------
// Color Palette (matches tailwind.config "solaris" colors)
// ---------------------------------------------------------------------------
class SolarisColors {
  static const Color bg = Color(0xFFF6FAFD);
  static const Color heading = Color(0xFF0A1931);
  static const Color primary = Color(0xFF4A7FA7);
  static const Color accent = Color(0xFF1D4E89);
  static const Color green = Color(0xFF27AE60);
  static const Color orange = Color(0xFFF2994A);
  static const Color red = Color(0xFFEB5757);
  static const Color muted = Color(0xFF6B7280);
  static const Color chartLine = Color(0xFF0066CC);
  static const Color chartDashed = Color(0xFF85C1E9);
}

// ---------------------------------------------------------------------------
// Dashboard Screen (Tab Index 0)
// ---------------------------------------------------------------------------
class SolarDashboardPage extends StatefulWidget {
  const SolarDashboardPage({super.key});

  @override
  State<SolarDashboardPage> createState() => _SolarDashboardPageState();
}

class _SolarDashboardPageState extends State<SolarDashboardPage> {
  bool isLightOn = true;

  @override
  void initState() {
    super.initState();
    WeatherService.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double maxW = Responsive.maxContentWidth(context);

    return Scaffold(
      backgroundColor: SolarisColors.bg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: (isMobile ? 110 : 30) + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MainHeader(
                        onProfileTap: () {
                          MainNavigationHub.pageIndex.value = 3;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const QuickStatusCards(),
                                  const SizedBox(height: 24),
                                  const BatteryHealthSection(),
                                  const SizedBox(height: 24),
                                  SmartLightCard(
                                    isOn: isLightOn,
                                    onToggle: () {
                                      setState(() {
                                        isLightOn = !isLightOn;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  const SolarProductionChart(),
                                  const SizedBox(height: 24),
                                  const SystemStatusSection(),
                                  const SizedBox(height: 24),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Pane: Status, Battery & Controls
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const QuickStatusCards(),
                                        const SizedBox(height: 24),
                                        const BatteryHealthSection(),
                                        const SizedBox(height: 24),
                                        SmartLightCard(
                                          isOn: isLightOn,
                                          onToggle: () {
                                            setState(() {
                                              isLightOn = !isLightOn;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Right Pane: Charts & System Details
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SolarProductionChart(),
                                        const SizedBox(height: 24),
                                        const SystemStatusSection(),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SharedBottomNav(activeIndex: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class MainHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const MainHeader({
    super.key,
    this.onProfileTap,
  });

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
            onTap: onProfileTap,
            child: const ProfileAvatar(size: 40),
          ),
        ),
      ),
    );
  }
}



// ---------------------------------------------------------------------------
// BEGIN: QuickStatusCards
// ---------------------------------------------------------------------------
class QuickStatusCards extends StatelessWidget {
  const QuickStatusCards({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WeatherModel?>(
      valueListenable: WeatherService.weatherNotifier,
      builder: (context, weather, _) {
        final tempStr = weather != null ? '${weather.temp.round()}°C' : '31°C';
        final conditionStr = weather != null ? weather.condition : 'Sunny';

        return Row(
          children: [
            Expanded(
              child: _StatusCard(
                icon: Icons.device_thermostat,
                title: tempStr,
                subtitle: 'Temperature',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🌞 Current temperature in Mosul: $tempStr ($conditionStr). System running at optimal thermal levels.',
                      ),
                      backgroundColor: SolarisColors.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatusCard(
                icon: Icons.wifi,
                title: 'Connected',
                subtitle: 'Network Status',
                showDot: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '🌐 Connection is stable. Connected to server via 5G backup link.',
                      ),
                      backgroundColor: SolarisColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDot;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: SolarisColors.primary, size: 26),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (showDot) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: SolarisColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SolarisColors.heading,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
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

// -------------------------------------------------------------------------------------------
// BEGIN: BatteryHealthSection
// ---------------------------------------------------------------------------
class BatteryHealthSection extends StatelessWidget {
  const BatteryHealthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Section header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Battery Health',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SolarisColors.heading,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      color: SolarisColors.green,
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Safe',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SolarisColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Ring gauge ──
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _BatteryRingPainter(progress: 0.82),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _BatteryIcon(color: Color(0xFF4A7FA7), size: 34),
                    const SizedBox(height: 6),
                    const Text(
                      '82%',
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        color: SolarisColors.heading,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Charge Level',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // ── Stats row ──
          Row(
            children: [
              _BatteryStatItem(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFF4A7FA7),
                iconBg: const Color(0xFFEFF6FF),
                label: 'Voltage',
                value: '12.4V',
              ),
              _VerticalDivider(),
              _BatteryStatItem(
                icon: Icons.thermostat_rounded,
                iconColor: const Color(0xFF27AE60),
                iconBg: const Color(0xFFE8F5E9),
                label: 'Temperature',
                value: '28°C',
              ),
              _VerticalDivider(),
              _BatteryStatItem(
                icon: Icons.timelapse_rounded,
                iconColor: const Color(0xFFF2994A),
                iconBg: const Color(0xFFFFF7ED),
                label: 'Est. Life',
                value: '4.2 hrs',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Legend ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _LegendItem(
                color: SolarisColors.green,
                range: '60% – 100%',
                label: 'Safe',
              ),
              _LegendItem(
                color: SolarisColors.orange,
                range: '25% – 59%',
                label: 'Medium',
              ),
              _LegendItem(
                color: SolarisColors.red,
                range: '0% – 24%',
                label: 'Danger',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatteryStatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _BatteryStatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: SolarisColors.heading,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: const Color(0xFFF1F5F9));
  }
}

class _BatteryIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _BatteryIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.55, size),
      painter: _BatteryIconPainter(color: color),
    );
  }
}

class _BatteryIconPainter extends CustomPainter {
  final Color color;
  _BatteryIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final capHeight = size.height * 0.08;
    final capWidth = size.width * 0.45;

    // Body outline
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, capHeight, size.width, size.height - capHeight),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, paint);

    // Cap (solid)
    final capPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((size.width - capWidth) / 2, 0, capWidth, capHeight + 1.0),
      const Radius.circular(1),
    );
    canvas.drawRRect(capRect, capPaint);

    // Lightning bolt (solid fill)
    final boltPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final boltPath = Path();
    final bx = size.width / 2;
    final by = capHeight + (size.height - capHeight) / 2;
    final scale = size.height / 38.0;

    boltPath.moveTo(bx + 1.5 * scale, by - 6.5 * scale);
    boltPath.lineTo(bx - 3.5 * scale, by + 1.0 * scale);
    boltPath.lineTo(bx - 0.8 * scale, by + 1.0 * scale);
    boltPath.lineTo(bx - 2.5 * scale, by + 6.5 * scale);
    boltPath.lineTo(bx + 2.5 * scale, by - 1.0 * scale);
    boltPath.lineTo(bx - 0.2 * scale, by - 1.0 * scale);
    boltPath.close();

    canvas.drawPath(boltPath, boltPaint);
  }

  @override
  bool shouldRepaint(covariant _BatteryIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _BatteryRingPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  _BatteryRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.82;
    final strokeWidth = 6.0;

    // 1. Concentric outer dotted circle
    final dottedPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final dottedRadius = radius + 15.0;
    _drawDashedCircle(canvas, center, dottedRadius, dottedPaint, 2.0, 4.0);

    // 2. Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // 3. Gradient progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [Color(0xFF60A5FA), Color(0xFF1D4E89)],
    );
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);

    // 4. Dot/thumb at the end of the arc
    final endAngle = startAngle + sweepAngle;
    final thumbX = center.dx + radius * math.cos(endAngle);
    final thumbY = center.dy + radius * math.sin(endAngle);

    final thumbPaint = Paint()
      ..color = const Color(0xFF5BA3D0)
      ..style = PaintingStyle.fill;
    final thumbBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(thumbX, thumbY), 5.5, thumbPaint);
    canvas.drawCircle(Offset(thumbX, thumbY), 5.5, thumbBorderPaint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final double circumference = 2 * math.pi * radius;
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final double angleStep = 2 * math.pi / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final double angle = i * angleStep;
      final double startX = center.dx + radius * math.cos(angle);
      final double startY = center.dy + radius * math.sin(angle);
      final double endX =
          center.dx +
          radius *
              math.cos(
                angle + angleStep * (dashWidth / (dashWidth + dashSpace)),
              );
      final double endY =
          center.dy +
          radius *
              math.sin(
                angle + angleStep * (dashWidth / (dashWidth + dashSpace)),
              );
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String range;
  final String label;

  const _LegendItem({
    required this.color,
    required this.range,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              range,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: SolarisColors.heading,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ],
    );
  }
}
// END: BatteryHealthSection

// ---------------------------------------------------------------------------
// BEGIN: SmartLightCard
// ---------------------------------------------------------------------------
class SmartLightCard extends StatelessWidget {
  final bool isOn;
  final VoidCallback onToggle;

  const SmartLightCard({super.key, required this.isOn, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + title + toggle ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isOn
                          ? SolarisColors.heading
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                      color: isOn ? Colors.white : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Light',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: SolarisColors.heading,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isOn
                                  ? SolarisColors.green
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOn ? 'Active · 70% brightness' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Power toggle
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52,
                  height: 28,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isOn ? SolarisColors.heading : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: isOn
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),
          // ── Bottom action buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LightActionButton(
                icon: Icons.schedule_rounded,
                label: 'Schedule',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '📅 Light schedule: ON at 06:00 PM · OFF at 06:00 AM',
                    ),
                    backgroundColor: SolarisColors.primary,
                  ),
                ),
              ),
              _LightActionButton(
                icon: Icons.brightness_6_rounded,
                label: 'Brightness',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💡 Brightness set to 70%. AI mode active.'),
                    backgroundColor: SolarisColors.primary,
                  ),
                ),
              ),
              _LightActionButton(
                icon: Icons.auto_awesome_rounded,
                label: 'AI Mode',
                isActive: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🤖 AI Mode ON: Auto-adjusts brightness based on motion & time.',
                    ),
                    backgroundColor: SolarisColors.accent,
                  ),
                ),
              ),
              _LightActionButton(
                icon: Icons.info_outline_rounded,
                label: 'Details',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'ℹ️ Smart Light — Model SL-220X · Uptime: 14 days.',
                    ),
                    backgroundColor: SolarisColors.heading,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LightActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LightActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isActive ? SolarisColors.heading : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : SolarisColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
// END: SmartLightCard

// ---------------------------------------------------------------------------
// BEGIN: SolarProductionChart
// ---------------------------------------------------------------------------
class SolarProductionChart extends StatefulWidget {
  const SolarProductionChart({super.key});

  @override
  State<SolarProductionChart> createState() => _SolarProductionChartState();
}

class _SolarProductionChartState extends State<SolarProductionChart> {
  String _selectedTimeRange = 'Last 24 Hours';

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
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: SolarisColors.heading,
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
                            content: Text(
                              'Dashboard Chart: Now showing $range',
                            ),
                            backgroundColor: SolarisColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SolarisColors.heading
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? SolarisColors.heading
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
                                color: isSelected
                                    ? Colors.white
                                    : SolarisColors.heading,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solar Production',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SolarisColors.heading,
                ),
              ),
              GestureDetector(
                onTap: _showTimeRangeSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedTimeRange,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: SolarisColors.heading,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.expand_more,
                        size: 16,
                        color: SolarisColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              Container(width: 16, height: 2, color: SolarisColors.chartLine),
              const SizedBox(width: 8),
              Text(
                'Actual (W)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              CustomPaint(
                size: const Size(16, 2),
                painter: _DashedLinePainter(color: SolarisColors.chartDashed),
              ),
              const SizedBox(width: 8),
              Text(
                'Expected (W)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Area
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Y axis labels
                    SizedBox(
                      width: 32,
                      height: 192,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: ['1000', '750', '500', '250', '0']
                            .map(
                              (e) => Text(
                                e,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chart + tooltip
                    Expanded(
                      child: SizedBox(
                        height: 192,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomPaint(
                              size: const Size(double.infinity, 192),
                              painter: _SolarChartPainter(),
                            ),
                            Positioned(
                              top: 24,
                              right: 12,
                              child: _ChartTooltip(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: -8,
                  left: 40,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:
                        [
                              '00:00',
                              '04:00',
                              '08:00',
                              '12:00',
                              '16:00',
                              '20:00',
                              '24:00',
                            ]
                            .map(
                              (e) => Text(
                                e,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                            .toList(),
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

class _ChartTooltip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SolarisColors.heading,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time header
          const Text(
            '12:00 PM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            color: const Color(0xFF374151),
            margin: const EdgeInsets.only(bottom: 6),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 9, color: Colors.white70),
                  children: [
                    TextSpan(text: 'Actual: '),
                    TextSpan(
                      text: '850 W',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 9, color: Colors.white70),
                  children: [
                    TextSpan(text: 'Expected: '),
                    TextSpan(
                      text: '920 W',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SolarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // viewBox is 300x150, scale to actual size
    final sx = size.width / 300;
    final sy = size.height / 150;

    Offset map(double x, double y) => Offset(x * sx, y * sy);

    // Grid lines (5 horizontal lines)
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Expected curve (dashed) - approximate quadratic/cubic bezier from path
    final expectedPath = Path();
    expectedPath.moveTo(map(0, 150).dx, map(0, 150).dy);
    expectedPath.quadraticBezierTo(
      map(75, 120).dx,
      map(75, 120).dy,
      map(150, 20).dx,
      map(150, 20).dy,
    );
    expectedPath.quadraticBezierTo(
      map(225, -80).dx,
      map(225, -80).dy,
      map(300, 150).dx,
      map(300, 150).dy,
    );

    _drawDashedPath(canvas, expectedPath, SolarisColors.chartDashed, 1.5);

    // Actual curve (solid)
    final actualPath = Path();
    final points = [
      [0.0, 150.0],
      [30.0, 145.0],
      [60.0, 135.0],
      [90.0, 110.0],
      [105.0, 100.0],
      [120.0, 115.0],
      [140.0, 80.0],
      [160.0, 70.0],
      [180.0, 60.0],
      [200.0, 65.0],
      [220.0, 100.0],
      [240.0, 110.0],
      [260.0, 130.0],
      [300.0, 150.0],
    ];
    actualPath.moveTo(
      map(points[0][0], points[0][1]).dx,
      map(points[0][0], points[0][1]).dy,
    );
    for (var p in points.skip(1)) {
      final pt = map(p[0], p[1]);
      actualPath.lineTo(pt.dx, pt.dy);
    }

    final actualPaint = Paint()
      ..color = SolarisColors.chartLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(actualPath, actualPaint);

    // Tooltip trigger point
    final outerDot = map(170, 62);
    canvas.drawCircle(outerDot, 4, Paint()..color = SolarisColors.chartLine);
    final innerDot = map(170, 50);
    canvas.drawCircle(innerDot, 3, Paint()..color = Colors.white);
    canvas.drawCircle(
      innerDot,
      3,
      Paint()
        ..color = SolarisColors.chartDashed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        final next = math.min(distance + len, metric.length);
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, next), paint);
        }
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// END: SolarProductionChart

// ---------------------------------------------------------------------------
// BEGIN: SystemStatus
// ---------------------------------------------------------------------------
class SystemStatusSection extends StatelessWidget {
  const SystemStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SolarisColors.heading,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _SystemStatusItem(
              icon: Icons.solar_power,
              label: 'Solar',
              value: 'Good',
              valueColor: SolarisColors.green,
            ),
            _SystemStatusItem(
              icon: Icons.battery_charging_full,
              label: 'Battery',
              value: 'Excellent',
              valueColor: SolarisColors.green,
            ),
            _SystemStatusItem(
              icon: Icons.cell_tower,
              label: 'Network',
              value: 'Stable',
              valueColor: SolarisColors.primary,
            ),
            _SystemStatusItem(
              icon: Icons.shield_outlined,
              label: 'System',
              value: 'Protected',
              valueColor: SolarisColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _SystemStatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _SystemStatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD6E8F5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: SolarisColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: SolarisColors.heading,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// END: SystemStatus
