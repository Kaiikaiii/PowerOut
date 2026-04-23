import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apiservice.dart';
import 'report_store.dart';
import 'welcome_screen.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _adminEmail = 'admin@gmail.com';
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all';
  List<_AdminReportRow> _rows = <_AdminReportRow>[];
  final Set<String> _updatingReportIds = <String>{};

  static const Color _sidebarColor = Color(0xFF0A1B44);
  static const Color _screenBg = Color(0xFFF3F5F8);
  static const Color _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _validateAccess();
  }

  Future<void> _validateAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdminLoggedIn = prefs.getBool('is_admin_logged_in') ?? false;
    final adminEmail = prefs.getString('admin_email') ?? '';

    if (!isAdminLoggedIn || adminEmail != 'admin@gmail.com') {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
      return;
    }

    await ReportStore.init();
    await _loadReports();

    if (!mounted) return;
    setState(() {
      _adminEmail = adminEmail;
    });
  }

  Future<void> _loadReports() async {
    final response = await ApiService.getReports();
    final apiRows = _extractApiRows(response);
    final localRows = _localRowsFromCache(ReportStore.submittedReports.value);

    if (!mounted) return;
    setState(() {
      _rows = <_AdminReportRow>[...apiRows, ...localRows];
      _isLoading = false;
    });
  }

  List<_AdminReportRow> _extractApiRows(Map<String, dynamic> response) {
    final reportsRaw = response['reports'] ?? response['data'] ?? response['items'];
    if (reportsRaw is! List) return <_AdminReportRow>[];

    return reportsRaw.whereType<Map>().map((item) {
      final map = item.map((k, v) => MapEntry(k.toString(), v));
      final userId = (map['user_id'] ?? map['userId'] ?? '').toString();
      final reportId = (map['report_id'] ?? map['id'] ?? '').toString();
      final reporterName =
          (map['reporter_name'] ?? map['name'] ?? map['user_name'] ?? '').toString().trim();
      final reporterEmail =
          (map['reporter_email'] ?? map['email'] ?? map['user_email'] ?? '').toString().trim();
      final reporterPhone = (map['phone'] ?? map['contact'] ?? '').toString().trim();
      final location = (map['location'] ?? '').toString().trim();
      final district = (map['barangay'] ?? map['district'] ?? '').toString().trim();
      final timestampRaw = (map['created_at'] ?? map['createdAt'] ?? '').toString();
      final parsedTime = DateTime.tryParse(timestampRaw) ?? DateTime.now();
      final rawStatus = (map['status'] ?? 'pending').toString().toLowerCase();

      return _AdminReportRow(
        reportId: reportId,
        reporterName: reporterName.isEmpty ? _fallbackName(userId) : reporterName,
        reporterId: userId.isEmpty ? 'Unknown' : userId,
        reporterEmail: reporterEmail.isEmpty ? 'No email provided' : reporterEmail,
        reporterPhone: reporterPhone.isEmpty ? 'No phone provided' : reporterPhone,
        location: location.isEmpty ? 'Unspecified location' : location,
        district: district.isEmpty ? 'N/A' : district,
        timestamp: parsedTime,
        status: _normalizeStatus(rawStatus),
      );
    }).toList();
  }

  List<_AdminReportRow> _localRowsFromCache(List<UserReport> reports) {
    return reports.map((report) {
      final district = _extractDistrict(report.location);
      return _AdminReportRow(
        reportId: '',
        reporterName: _fallbackName(report.userId),
        reporterId: report.userId,
        reporterEmail: 'No email provided',
        reporterPhone: 'No phone provided',
        location: report.location.isEmpty ? 'Unspecified location' : report.location,
        district: district,
        timestamp: report.createdAt,
        status: 'pending',
      );
    }).toList();
  }

  String _extractDistrict(String location) {
    final pieces = location.split(',');
    if (pieces.length < 2) return 'N/A';
    return pieces.last.trim();
  }

  String _fallbackName(String userId) {
    if (userId.trim().isEmpty) return 'App User';
    return 'User #$userId';
  }

  String _normalizeStatus(String status) {
    if (status == 'resolved') return 'resolved';
    if (status == 'verified' || status == 'investigating') return 'investigating';
    return 'pending';
  }

  Future<void> _logoutAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin_logged_in');
    await prefs.remove('admin_email');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  bool _isSuccess(Map<String, dynamic> response) {
    final success = response['success'];
    final status = response['status'];
    return success == true ||
        success == 1 ||
        success?.toString().toLowerCase() == 'true' ||
        success?.toString().toLowerCase() == 'success' ||
        status == true ||
        status == 1 ||
        status?.toString().toLowerCase() == 'true' ||
        status?.toString().toLowerCase() == 'success';
  }

  Future<void> _updateStatus(_AdminReportRow row, String newStatus) async {
    if (row.reportId.isEmpty || _updatingReportIds.contains(row.reportId)) return;
    setState(() {
      _updatingReportIds.add(row.reportId);
    });

    final response = await ApiService.updateReportStatus(
      reportId: row.reportId,
      status: newStatus,
    );

    if (!mounted) return;
    if (_isSuccess(response)) {
      setState(() {
        _rows = _rows
            .map(
              (item) => item.reportId == row.reportId
                  ? item.copyWith(status: _normalizeStatus(newStatus))
                  : item,
            )
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report status updated.')),
      );
    } else {
      final message = (response['message'] ?? 'Failed to update status.').toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    setState(() {
      _updatingReportIds.remove(row.reportId);
    });
  }

  List<_AdminReportRow> get _filteredRows {
    final lowerQuery = _searchQuery.trim().toLowerCase();
    return _rows.where((row) {
      final matchesStatus = _statusFilter == 'all' || row.status == _statusFilter;
      if (!matchesStatus) return false;
      if (lowerQuery.isEmpty) return true;
      return row.reporterName.toLowerCase().contains(lowerQuery) ||
          row.reporterEmail.toLowerCase().contains(lowerQuery) ||
          row.location.toLowerCase().contains(lowerQuery) ||
          row.district.toLowerCase().contains(lowerQuery);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        return Scaffold(
          backgroundColor: _screenBg,
          drawer: isMobile ? _buildMobileDrawer() : null,
          body: SafeArea(
            child: isMobile
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      children: [
                        _buildTopBar(isMobile: true),
                        const SizedBox(height: 12),
                        Expanded(child: _buildReportingCard(isMobile: true)),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      _buildSidebar(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopBar(),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _buildReportingCard(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 88,
      color: _sidebarColor,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
          const SizedBox(height: 20),
          _navTile(icon: Icons.description_rounded, selected: true),
          const SizedBox(height: 10),
          _navTile(icon: Icons.calendar_month_rounded),
          const Spacer(),
          _navTile(icon: Icons.settings_rounded),
          const SizedBox(height: 8),
          IconButton(
            onPressed: _logoutAdmin,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _navTile({required IconData icon, bool selected = false}) {
    return Container(
      width: 56,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? Colors.white12 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 21),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: _sidebarColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
            const SizedBox(height: 20),
            _navTile(icon: Icons.description_rounded, selected: true),
            const SizedBox(height: 10),
            _navTile(icon: Icons.calendar_month_rounded),
            const Spacer(),
            _navTile(icon: Icons.settings_rounded),
            const SizedBox(height: 10),
            IconButton(
              onPressed: _logoutAdmin,
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar({bool isMobile = false}) {
    return Row(
      children: [
        if (isMobile)
          Builder(
            builder: (context) => Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          ),
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6E8ED)),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search reporter, email, or location...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildReportingCard({bool isMobile = false}) {
    final visibleRows = _filteredRows;
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reporting Log',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Review outage reports submitted by app users.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          if (isMobile)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _statusDropDown(),
                Text('Admin: $_adminEmail', style: TextStyle(color: Colors.grey.shade700)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadReports();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            )
          else
            Row(
              children: [
                _statusDropDown(),
                const Spacer(),
                Text('Admin: $_adminEmail', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadReports();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : visibleRows.isEmpty
                    ? const Center(
                        child: Text(
                          'No reports found yet.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    : ListView.separated(
                        itemCount: visibleRows.length,
                        separatorBuilder: (_, __) =>
                            isMobile ? const SizedBox(height: 10) : const Divider(height: 1),
                        itemBuilder: (context, index) => isMobile
                            ? _buildMobileRowCard(visibleRows[index])
                            : _buildRow(visibleRows[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropDown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E4EA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Statuses')),
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'investigating', child: Text('Investigating')),
            DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _statusFilter = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRow(_AdminReportRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEFF3F9),
            child: Text(
              row.reporterName.isEmpty ? 'U' : row.reporterName[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.reporterName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  'ID: ${row.reporterId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.reporterEmail, style: const TextStyle(fontSize: 13)),
                Text(row.reporterPhone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${row.location}\n${row.district}',
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(row.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 8),
          _statusEditor(row),
        ],
      ),
    );
  }

  Widget _buildMobileRowCard(_AdminReportRow row) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E9EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFEFF3F9),
                child: Text(
                  row.reporterName.isEmpty ? 'U' : row.reporterName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.reporterName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      'ID: ${row.reporterId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              _statusEditor(row),
            ],
          ),
          const SizedBox(height: 10),
          Text(row.reporterEmail, style: const TextStyle(fontSize: 13)),
          Text(row.reporterPhone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            '${row.location}\n${row.district}',
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(row.timestamp).replaceAll('\n', ' • '),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _statusEditor(_AdminReportRow row) {
    final canUpdate = row.reportId.isNotEmpty;
    if (!canUpdate) {
      return _statusChip(row.status);
    }

    if (_updatingReportIds.contains(row.reportId)) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E4EA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: row.status,
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'investigating', child: Text('Investigating')),
            DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
          ],
          onChanged: (value) {
            if (value == null || value == row.status) return;
            _updateStatus(row, value);
          },
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'resolved':
        bg = const Color(0xFFE4F8EA);
        fg = const Color(0xFF237A49);
        label = 'RESOLVED';
        break;
      case 'investigating':
        bg = const Color(0xFFFFF4DB);
        fg = const Color(0xFF9D6B08);
        label = 'INVESTIGATING';
        break;
      default:
        bg = const Color(0xFFFFE8ED);
        fg = const Color(0xFFB03052);
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: fg,
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final meridiem = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${_monthName(dateTime.month)} ${dateTime.day}, ${dateTime.year}\n$hour:$minute $meridiem';
  }

  String _monthName(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _AdminReportRow {
  const _AdminReportRow({
    required this.reportId,
    required this.reporterName,
    required this.reporterId,
    required this.reporterEmail,
    required this.reporterPhone,
    required this.location,
    required this.district,
    required this.timestamp,
    required this.status,
  });

  final String reportId;
  final String reporterName;
  final String reporterId;
  final String reporterEmail;
  final String reporterPhone;
  final String location;
  final String district;
  final DateTime timestamp;
  final String status;

  _AdminReportRow copyWith({
    String? reportId,
    String? reporterName,
    String? reporterId,
    String? reporterEmail,
    String? reporterPhone,
    String? location,
    String? district,
    DateTime? timestamp,
    String? status,
  }) {
    return _AdminReportRow(
      reportId: reportId ?? this.reportId,
      reporterName: reporterName ?? this.reporterName,
      reporterId: reporterId ?? this.reporterId,
      reporterEmail: reporterEmail ?? this.reporterEmail,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      location: location ?? this.location,
      district: district ?? this.district,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
