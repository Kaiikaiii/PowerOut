import 'package:flutter/material.dart';

/// Home "Status" tab — outage dashboard for POWEROUT.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _alertYellow = Color(0xFFFFCC00);
  static const Color _statusDown = Color(0xFFFF4D4D);
  static const Color _statusUnstable = Color(0xFFFFB800);
  static const Color _statusStable = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildEmergencyAlert(),
              const SizedBox(height: 24),
              _buildLiveMapSection(context),
              const SizedBox(height: 24),
              _buildOutagesHeader(context),
              const SizedBox(height: 12),
              _OutageCard(
                icon: Icons.power_off_rounded,
                iconBg: const Color(0xFFE8E8E8),
                title: 'Brgy. Estefania',
                subtitle: 'Grid Maintenance',
                statusLabel: 'DOWN',
                statusColor: _statusDown,
                rightSub: 'ETR: 4:00 PM',
                rightSubBold: true,
              ),
              const SizedBox(height: 12),
              _OutageCard(
                icon: Icons.bolt_rounded,
                iconBg: const Color(0xFFFFF3CD),
                iconColor: _statusUnstable,
                title: 'Lacson Street',
                subtitle: 'Voltage Surge',
                statusLabel: 'UNSTABLE',
                statusColor: _statusUnstable,
                rightSub: 'Assessing',
                rightSubBold: true,
              ),
              const SizedBox(height: 12),
              _OutageCard(
                icon: Icons.check_circle_rounded,
                iconBg: const Color(0xFFE8F8EE),
                iconColor: _statusStable,
                title: 'Barangay Bata',
                subtitle: 'Restored 10m ago',
                statusLabel: 'STABLE',
                statusColor: _statusStable,
                rightSub: 'Restored',
                rightSubBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POWEROUT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'BACOLOD CITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: const Color(0xFFF0F0F0),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.notifications_outlined, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _alertYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EMERGENCY ALERT',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Heavy Rain: Grid maintenance scheduled for Brgy. Mandalagan. Expect intermittent outages.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.black.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE STATUS MAP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Updated 2m ago',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE8F5E9),
                        Colors.amber.shade50,
                        const Color(0xFFFFF8E1),
                      ],
                    ),
                  ),
                ),
                CustomPaint(painter: _MapMarkersPainter()),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '12 ACTIVE ZONES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.open_in_full,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutagesHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'CURRENT OUTAGES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: Colors.grey.shade600,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'View All',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapMarkersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void dot(double x, double y, Color c) {
      final paint = Paint()..color = c;
      canvas.drawCircle(Offset(x * size.width, y * size.height), 8, paint);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        10,
        Paint()
          ..color = c.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    dot(0.25, 0.35, const Color(0xFFFF9800));
    dot(0.55, 0.45, const Color(0xFF9C27B0));
    dot(0.72, 0.28, const Color(0xFFFF9800));
    dot(0.4, 0.62, const Color(0xFF9C27B0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OutageCard extends StatelessWidget {
  const _OutageCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
    required this.rightSub,
    this.iconColor,
    this.rightSubBold = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;
  final String rightSub;
  final bool rightSubBold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? Colors.black54, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statusLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.3,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rightSub,
                style: TextStyle(
                  fontWeight: rightSubBold ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
