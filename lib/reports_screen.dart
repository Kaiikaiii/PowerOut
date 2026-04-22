import 'package:flutter/material.dart';
import 'report_store.dart';
import 'submit_report_page.dart';

/// Reports tab — Service Reports list (matches app bottom navigation shell).
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  /// 0 = All Reports, 1 = My Reports
  int _tabIndex = 0;

  static const Color _bg = Color(0xFFF8F9FA);
  static const Color _primaryBlue = Color(0xFF1A44F4);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UserReport>>(
      valueListenable: ReportStore.submittedReports,
      builder: (context, submitted, _) {
        final userItems = submitted.map(_fromUserReport).toList();
        final reports =
            _tabIndex == 0 ? [...userItems, ..._allReports] : [...userItems, ..._myReports];

        return Scaffold(
          backgroundColor: _bg,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: SizedBox(
            height: 44,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SubmitReportPage(),
                  ),
                );
              },
              backgroundColor: const Color(0xFFFFCC00),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add New Report',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Reports',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      _buildTabSwitcher(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'RECENT ACTIVITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.filter_list, color: Colors.grey.shade600),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: reports.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _ReportCard(data: reports[index]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: 'All Reports',
              selected: _tabIndex == 0,
              selectedColor: _primaryBlue,
              onTap: () => setState(() => _tabIndex = 0),
            ),
          ),
          Expanded(
            child: _TabChip(
              label: 'My Reports',
              selected: _tabIndex == 1,
              selectedColor: _primaryBlue,
              onTap: () => setState(() => _tabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  _ReportData _fromUserReport(UserReport report) {
    return _ReportData(
      icon: Icons.bolt_rounded,
      iconBg: const Color(0xFFFFF3CD),
      iconColor: const Color(0xFFB7791F),
      title: report.title,
      location: report.location,
      statusLabel: 'PENDING',
      statusBg: const Color(0xFFFFF3E0),
      statusFg: const Color(0xFFE65100),
      timeLabel: _timeAgo(report.createdAt),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return 'Yesterday';
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? selectedColor : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportData {
  const _ReportData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.location,
    required this.statusLabel,
    required this.statusBg,
    required this.statusFg,
    required this.timeLabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String location;
  final String statusLabel;
  final Color statusBg;
  final Color statusFg;
  final String timeLabel;
}

const List<_ReportData> _allReports = [
  _ReportData(
    icon: Icons.power_off_rounded,
    iconBg: Color(0xFFFFE8E8),
    iconColor: Color(0xFFE53935),
    title: 'Power Interruption',
    location: 'Barangay Alijis, Sector 4',
    statusLabel: 'PENDING',
    statusBg: Color(0xFFFFF3E0),
    statusFg: Color(0xFFE65100),
    timeLabel: '14 mins ago',
  ),
  _ReportData(
    icon: Icons.bolt_rounded,
    iconBg: Color(0xFFE3F2FD),
    iconColor: Color(0xFF1565C0),
    title: 'Line Maintenance',
    location: 'Mansilingan Heights',
    statusLabel: 'RESOLVED',
    statusBg: Color(0xFFE8F5E9),
    statusFg: Color(0xFF2E7D32),
    timeLabel: '2 hours ago',
  ),
  _ReportData(
    icon: Icons.warning_amber_rounded,
    iconBg: Color(0xFFEEEEEE),
    iconColor: Color(0xFF616161),
    title: 'Flickering Streetlight',
    location: 'Villamonte Drive',
    statusLabel: 'CLOSED',
    statusBg: Color(0xFFF5F5F5),
    statusFg: Color(0xFF424242),
    timeLabel: 'Yesterday',
  ),
];

/// Subset for "My Reports" demo.
const List<_ReportData> _myReports = [
  _ReportData(
    icon: Icons.power_off_rounded,
    iconBg: Color(0xFFFFE8E8),
    iconColor: Color(0xFFE53935),
    title: 'Power Interruption',
    location: 'Barangay Alijis, Sector 4',
    statusLabel: 'PENDING',
    statusBg: Color(0xFFFFF3E0),
    statusFg: Color(0xFFE65100),
    timeLabel: '14 mins ago',
  ),
];

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.data});

  final _ReportData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        data.location,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: data.statusFg,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.timeLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
