// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'main_navigation_hub.dart' show SharedBottomNav, ProfileAvatar, MainNavigationHub;
import '../utils/responsive.dart';

// ---------------------------------------------------------------------------
// Color Palette (matches tailwind.config colors)
// ---------------------------------------------------------------------------
class AlertColors {
  static const Color solarisBg = Color(0xFFF6FAFD);
  static const Color solarisPrimary = Color(0xFF4A7FA7);
  static const Color solarisTitle = Color(0xFF0A1931);
  static const Color solarisCritical = Color(0xFFEF4444);
  static const Color solarisWarning = Color(0xFFF97316);
  static const Color solarisSuccess = Color(0xFF22C55E);
  static const Color solarisTextMuted = Color(0xFF64748B);
}

// ---------------------------------------------------------------------------
// Alert Data Model
// ---------------------------------------------------------------------------
class AlertData {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final String time;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;
  bool isDismissed;

  AlertData({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
    this.isDismissed = false,
  });
}

// ---------------------------------------------------------------------------
// Main Page
// ---------------------------------------------------------------------------
class AlertsCenterPage extends StatefulWidget {
  const AlertsCenterPage({super.key});

  @override
  State<AlertsCenterPage> createState() => _AlertsCenterPageState();
}

class _AlertsCenterPageState extends State<AlertsCenterPage> {
  bool _criticalExpanded = true;
  bool _warningsExpanded = true;
  bool _historyExpanded = true;
  String _activeFilter = 'All';

  final List<AlertData> _criticalAlerts = [
    AlertData(
      id: 'c1',
      icon: Icons.device_thermostat,
      iconColor: AlertColors.solarisCritical,
      iconBg: const Color(0x33FECACA),
      bgColor: const Color(0x1AFEF2F2),
      borderColor: const Color(0xFFFEE2E2),
      title: 'Overheating Detected',
      subtitle: 'Solar Panel 03',
      time: 'Today, 10:35 AM',
      badgeText: 'CRITICAL',
      badgeBg: const Color(0xFFFEE2E2),
      badgeColor: const Color(0xFFDC2626),
    ),
    AlertData(
      id: 'c2',
      icon: Icons.link_off,
      iconColor: AlertColors.solarisCritical,
      iconBg: const Color(0x33FECACA),
      bgColor: const Color(0x1AFEF2F2),
      borderColor: const Color(0xFFFEE2E2),
      title: 'Cable Disconnected',
      subtitle: 'Pole 05',
      time: 'Today, 09:21 AM',
      badgeText: 'CRITICAL',
      badgeBg: const Color(0xFFFEE2E2),
      badgeColor: const Color(0xFFDC2626),
    ),
  ];

  final List<AlertData> _warningAlerts = [
    AlertData(
      id: 'w1',
      icon: Icons.cleaning_services,
      iconColor: AlertColors.solarisWarning,
      iconBg: const Color(0x33FED7AA),
      bgColor: const Color(0x1AFFF7ED),
      borderColor: const Color(0xFFFFEDD5),
      title: 'Dust Accumulation',
      subtitle: 'Panel Group 02',
      time: 'Yesterday, 04:15 PM',
      badgeText: 'WARNING',
      badgeBg: const Color(0xFFFFEDD5),
      badgeColor: const Color(0xFFEA580C),
    ),
    AlertData(
      id: 'w2',
      icon: Icons.signal_cellular_alt_1_bar,
      iconColor: AlertColors.solarisWarning,
      iconBg: const Color(0x33FED7AA),
      bgColor: const Color(0x1AFFF7ED),
      borderColor: const Color(0xFFFFEDD5),
      title: 'Weak Network Signal',
      subtitle: 'Gateway Unit 04',
      time: 'Yesterday, 02:40 PM',
      badgeText: 'WARNING',
      badgeBg: const Color(0xFFFFEDD5),
      badgeColor: const Color(0xFFEA580C),
    ),
  ];

  int get _resolvedCount => 18;



  List<AlertData> get _filteredCritical {
    if (_activeFilter == 'Warnings') return [];
    if (_activeFilter == 'Resolved') return [];
    return _criticalAlerts.where((a) => !a.isDismissed).toList();
  }

  List<AlertData> get _filteredWarnings {
    if (_activeFilter == 'Critical') return [];
    if (_activeFilter == 'Resolved') return [];
    return _warningAlerts.where((a) => !a.isDismissed).toList();
  }

  void _showAlertDetail(BuildContext context, AlertData alert) {
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: alert.iconBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(alert.icon, color: alert.iconColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AlertColors.solarisTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AlertColors.solarisTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: alert.badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alert.badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: alert.badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.access_time_rounded, 'Detected At', alert.time),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _detailRow(Icons.location_on_outlined, 'Component', alert.subtitle),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _detailRow(
                      Icons.info_outline,
                      'Recommended Action',
                      alert.title.contains('Overheating')
                          ? 'Inspect panel ventilation and check surrounding temperature immediately.'
                          : alert.title.contains('Cable')
                              ? 'Inspect cable connections and tighten any loose terminals at the junction box.'
                              : alert.title.contains('Dust')
                                  ? 'Schedule a panel cleaning service within 48 hours to restore efficiency.'
                                  : 'Check network gateway antenna placement and signal booster status.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => alert.isDismissed = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Alert "${alert.title}" dismissed.'),
                            backgroundColor: const Color(0xFF475569),
                          ),
                        );
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AlertColors.solarisSuccess,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => alert.isDismissed = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ "${alert.title}" marked as resolved!'),
                            backgroundColor: AlertColors.solarisSuccess,
                          ),
                        );
                      },
                      child: const Text(
                        'Mark Resolved',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AlertColors.solarisPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AlertColors.solarisTextMuted,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AlertColors.solarisTitle,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    final filters = ['All', 'Critical', 'Warnings', 'Resolved'];
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
                    'Filter Alerts',
                    style: TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AlertColors.solarisTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Show only the alert severity level you want to view.',
                    style: TextStyle(fontSize: 13, color: AlertColors.solarisTextMuted),
                  ),
                  const SizedBox(height: 24),
                  ...filters.map((filter) {
                    final isSelected = _activeFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {});
                        setState(() => _activeFilter = filter);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0A1931) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0A1931) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              filter == 'All'
                                  ? Icons.all_inclusive
                                  : filter == 'Critical'
                                      ? Icons.report_problem
                                      : filter == 'Warnings'
                                          ? Icons.warning_amber
                                          : Icons.check_circle_outline,
                              color: isSelected ? Colors.white : AlertColors.solarisTextMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              filter,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AlertColors.solarisTitle,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check, color: Colors.white, size: 18),
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



  void _showViewAllSheet(BuildContext context, String type) {
    final isCritical = type == 'Critical';
    final items = isCritical ? _criticalAlerts : _warningAlerts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 20),
                  Text(
                    'All $type Alerts',
                    style: const TextStyle(
                      fontFamily: 'Libre Baskerville',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AlertColors.solarisTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${items.length} alert${items.length == 1 ? '' : 's'} found in this category.',
                    style: const TextStyle(fontSize: 13, color: AlertColors.solarisTextMuted),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final alert = items[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _showAlertDetail(context, alert);
                          },
                          child: _AlertItemWidget(alert: alert),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHistoryDetail(BuildContext context, _HistoryRowData row) {
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
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: row.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(row.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AlertColors.solarisTitle,
                        ),
                      ),
                      Text(
                        row.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AlertColors.solarisTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'RESOLVED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.play_circle_outline, 'Occurred', '${row.occurredDate}  ${row.occurredTime}'),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _detailRow(Icons.stop_circle_outlined, 'Resolved', '${row.resolvedDate}  ${row.resolvedTime}'),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _detailRow(Icons.timer_outlined, 'Total Duration', row.duration),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1931),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double maxW = Responsive.maxContentWidth(context);

    return Scaffold(
      backgroundColor: AlertColors.solarisBg,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Stack(
              children: [
                Column(
                  children: [
                    const _MainHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: (isMobile ? 110 : 30) + MediaQuery.viewPaddingOf(context).bottom,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 24 : 32,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _TitleSection(
                                activeFilter: _activeFilter,
                                onFilterTap: () => _showFilterSheet(context),
                              ),
                              const SizedBox(height: 32),
                              _StatisticsCards(
                                criticalCount:
                                    _criticalAlerts.where((a) => !a.isDismissed).length,
                                warningCount:
                                    _warningAlerts.where((a) => !a.isDismissed).length,
                                resolvedCount: _resolvedCount,
                              ),
                              const SizedBox(height: 32),
                              // Critical Faults
                              if (_activeFilter != 'Warnings' && _activeFilter != 'Resolved') ...[
                                _SectionHeader(
                                  dot: AlertColors.solarisCritical,
                                  label: 'Critical Faults',
                                  expanded: _criticalExpanded,
                                  onToggle: () => setState(() => _criticalExpanded = !_criticalExpanded),
                                ),
                                if (_criticalExpanded) ...[
                                  const SizedBox(height: 16),
                                  ..._filteredCritical.map((alert) => Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: GestureDetector(
                                          onTap: () => _showAlertDetail(context, alert),
                                          child: _AlertItemWidget(alert: alert),
                                        ),
                                      )),
                                  _ViewAllButton(
                                    onTap: () => _showViewAllSheet(context, 'Critical'),
                                  ),
                                ],
                                const SizedBox(height: 32),
                              ],
                              // Medium Warnings
                              if (_activeFilter != 'Critical' && _activeFilter != 'Resolved') ...[
                                _SectionHeader(
                                  dot: AlertColors.solarisWarning,
                                  label: 'Medium Warnings',
                                  expanded: _warningsExpanded,
                                  onToggle: () => setState(() => _warningsExpanded = !_warningsExpanded),
                                ),
                                if (_warningsExpanded) ...[
                                  const SizedBox(height: 16),
                                  ..._filteredWarnings.map((alert) => Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: GestureDetector(
                                          onTap: () => _showAlertDetail(context, alert),
                                          child: _AlertItemWidget(alert: alert),
                                        ),
                                      )),
                                  _ViewAllButton(
                                    onTap: () => _showViewAllSheet(context, 'Warning'),
                                  ),
                                ],
                                const SizedBox(height: 32),
                              ],
                              // Fault History
                              if (_activeFilter != 'Critical' && _activeFilter != 'Warnings') ...[
                                _SectionHeader(
                                  dot: AlertColors.solarisPrimary,
                                  label: 'FAULT HISTORY (LOG)',
                                  expanded: _historyExpanded,
                                  isHistory: true,
                                  onToggle: () => setState(() => _historyExpanded = !_historyExpanded),
                                ),
                                if (_historyExpanded) ...[
                                  const SizedBox(height: 16),
                                  _FaultHistoryTable(onRowTap: _showHistoryDetail),
                                  const SizedBox(height: 24),
                                  _ViewAllButton(
                                    label: 'View Full Log',
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Loading full fault log export...'),
                                          backgroundColor: AlertColors.solarisPrimary,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SharedBottomNav(activeIndex: 2),
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
// MainHeader (interactive)
// ---------------------------------------------------------------------------
class _MainHeader extends StatelessWidget {
  const _MainHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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

// ---------------------------------------------------------------------------
// TitleSection (interactive filter button)
// ---------------------------------------------------------------------------
class _TitleSection extends StatelessWidget {
  final String activeFilter;
  final VoidCallback onFilterTap;

  const _TitleSection({required this.activeFilter, required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alerts Center',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AlertColors.solarisTitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor system warnings and critical issues.',
                style: TextStyle(
                  fontSize: 13,
                  color: AlertColors.solarisTextMuted,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: activeFilter == 'All' ? Colors.white : const Color(0xFF0A1931),
              border: Border.all(
                color: activeFilter == 'All' ? Colors.grey.shade200 : const Color(0xFF0A1931),
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  size: 16,
                  color: activeFilter == 'All' ? AlertColors.solarisTitle : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  activeFilter == 'All' ? 'Filter' : activeFilter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: activeFilter == 'All' ? AlertColors.solarisTitle : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// StatisticsCards
// ---------------------------------------------------------------------------
class _StatisticsCards extends StatelessWidget {
  final int criticalCount;
  final int warningCount;
  final int resolvedCount;

  const _StatisticsCards({
    required this.criticalCount,
    required this.warningCount,
    required this.resolvedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.report_problem,
            iconColor: AlertColors.solarisCritical,
            iconBg: const Color(0xFFFEF2F2),
            value: '$criticalCount',
            label: 'CRITICAL',
            labelColor: const Color(0xFFDC2626),
            subLabel: 'Active',
            barColors: const [
              Color(0xFFFEE2E2),
              Color(0xFFFECACA),
              Color(0xFFFCA5A5),
              Color(0xFFFEE2E2),
            ],
            barHeights: const [8, 16, 24, 12],
            borderColor: Color(0x33EF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.warning_amber,
            iconColor: AlertColors.solarisWarning,
            iconBg: const Color(0xFFFFF7ED),
            value: '$warningCount',
            label: 'WARNINGS',
            labelColor: const Color(0xFFEA580C),
            subLabel: 'Active',
            barColors: const [
              Color(0xFFFFEDD5),
              Color(0xFFFED7AA),
              Color(0xFFFDBA74),
              Color(0xFFFFEDD5),
            ],
            barHeights: const [12, 20, 28, 16],
            borderColor: Color(0x33F97316),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            iconColor: AlertColors.solarisSuccess,
            iconBg: const Color(0xFFF0FDF4),
            value: '$resolvedCount',
            label: 'RESOLVED',
            labelColor: const Color(0xFF16A34A),
            subLabel: 'This Month',
            barColors: const [
              Color(0xFFDCFCE7),
              Color(0xFFBBF7D0),
              Color(0xFF86EFAC),
              Color(0xFFDCFCE7),
            ],
            barHeights: const [16, 8, 20, 28],
            borderColor: Color(0x3322C55E),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;
  final Color labelColor;
  final String subLabel;
  final List<Color> barColors;
  final List<double> barHeights;
  final Color borderColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
    required this.labelColor,
    required this.subLabel,
    required this.barColors,
    required this.barHeights,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(bottom: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 14),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AlertColors.solarisTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                subLabel,
                style: const TextStyle(
                  fontSize: 9,
                  color: AlertColors.solarisTextMuted,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Transform.scale(
              scale: 0.75,
              alignment: Alignment.bottomRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(barHeights.length, (i) {
                  return Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 6,
                    height: barHeights[i],
                    decoration: BoxDecoration(
                      color: barColors[i],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header (collapsible toggle)
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final Color dot;
  final String label;
  final bool expanded;
  final bool isHistory;
  final VoidCallback onToggle;

  const _SectionHeader({
    required this.dot,
    required this.label,
    required this.expanded,
    required this.onToggle,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isHistory)
                const Icon(Icons.access_time, color: AlertColors.solarisPrimary, size: 20)
              else
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AlertColors.solarisTitle,
                ),
              ),
            ],
          ),
          AnimatedRotation(
            turns: expanded ? 0 : 0.5,
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.keyboard_arrow_up,
              color: AlertColors.solarisTitle,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AlertItemWidget
// ---------------------------------------------------------------------------
class _AlertItemWidget extends StatelessWidget {
  final AlertData alert;

  const _AlertItemWidget({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.bgColor,
        border: Border.all(color: alert.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alert.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(alert.icon, color: alert.iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AlertColors.solarisTitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AlertColors.solarisTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AlertColors.solarisTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AlertColors.solarisTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: alert.badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: alert.badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ViewAllButton
// ---------------------------------------------------------------------------
class _ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _ViewAllButton({required this.onTap, this.label = 'View All'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEFF6FF)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AlertColors.solarisPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FaultHistory Table
// ---------------------------------------------------------------------------
class _HistoryRowData {
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final String occurredDate;
  final String occurredTime;
  final String resolvedDate;
  final String resolvedTime;
  final String duration;

  const _HistoryRowData({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.occurredDate,
    required this.occurredTime,
    required this.resolvedDate,
    required this.resolvedTime,
    required this.duration,
  });
}

class _FaultHistoryTable extends StatelessWidget {
  final void Function(BuildContext, _HistoryRowData) onRowTap;

  const _FaultHistoryTable({required this.onRowTap});

  static const _rows = [
    _HistoryRowData(
      iconBg: AlertColors.solarisCritical,
      icon: Icons.device_thermostat,
      title: 'Overheating Detected',
      subtitle: 'Solar Panel 01',
      occurredDate: 'Jun 14, 2025',
      occurredTime: '10:18:22 AM',
      resolvedDate: 'Jun 14, 2025',
      resolvedTime: '10:32:47 AM',
      duration: '14 min 25 sec',
    ),
    _HistoryRowData(
      iconBg: AlertColors.solarisWarning,
      icon: Icons.cleaning_services,
      title: 'Dust Accumulation',
      subtitle: 'Panel Group 03',
      occurredDate: 'Jun 13, 2025',
      occurredTime: '03:45:11 PM',
      resolvedDate: 'Jun 13, 2025',
      resolvedTime: '04:05:33 PM',
      duration: '20 min 22 sec',
    ),
    _HistoryRowData(
      iconBg: AlertColors.solarisSuccess,
      icon: Icons.check_circle,
      title: 'Cable Reconnected',
      subtitle: 'Pole 08',
      occurredDate: 'Jun 12, 2025',
      occurredTime: '11:02:09 AM',
      resolvedDate: 'Jun 12, 2025',
      resolvedTime: '11:08:51 AM',
      duration: '06 min 42 sec',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: _HeaderCell('EVENT')),
                  Expanded(child: _HeaderCell('OCCURRED')),
                  Expanded(child: _HeaderCell('RESOLVED')),
                  Expanded(child: _HeaderCell('DURATION')),
                  SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._rows.map((row) => Column(
                  children: [
                    GestureDetector(
                      onTap: () => onRowTap(context, row),
                      child: _HistoryRowWidget(row: row),
                    ),
                    const SizedBox(height: 16),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AlertColors.solarisTextMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _HistoryRowWidget extends StatelessWidget {
  final _HistoryRowData row;
  const _HistoryRowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: row.iconBg, shape: BoxShape.circle),
                child: Icon(row.icon, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AlertColors.solarisTitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      row.subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AlertColors.solarisTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Text(
            '${row.occurredDate}\n${row.occurredTime}',
            style: const TextStyle(
              fontSize: 11,
              color: AlertColors.solarisTextMuted,
              height: 1.3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '${row.resolvedDate}\n${row.resolvedTime}',
            style: const TextStyle(
              fontSize: 11,
              color: AlertColors.solarisTextMuted,
              height: 1.3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            row.duration,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AlertColors.solarisTitle,
            ),
          ),
        ),
        SizedBox(
          width: 16,
          child: Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
        ),
      ],
    );
  }
}
