import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

/// Home "Status" tab — outage dashboard for POWEROUT.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _bg = Colors.white;
  static const Color _alertYellow = Color.fromARGB(255, 248, 248, 248);
  static const Color _statusDown = Color(0xFFFF4D4D);
  static const Color _statusUnstable = Color(0xFFFFB800);
  static const Color _statusStable = Color(0xFF27AE60);

  final MapController _mapController = MapController();
      
  // Default to Bacolod City coordinates
  final LatLng _defaultLocation = const LatLng(10.6667, 122.9500);
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLiveLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  /// Requests permission and starts live user location updates.
  Future<void> _startLiveLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    final current = LatLng(position.latitude, position.longitude);
    if (!mounted) return;

    setState(() {
      _currentPosition = current;
    });
    _mapController.move(current, 15.0);

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!mounted) return;
      final updatedPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = updatedPosition;
      });
      _mapController.move(updatedPosition, _mapController.camera.zoom);
    });
  }

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
              const _OutageCard(
                icon: Icons.power_off_rounded,
                iconBg: Color(0xFFE8E8E8),
                title: 'Brgy. Estefania',
                subtitle: 'Grid Maintenance',
                statusLabel: 'DOWN',
                statusColor: _statusDown,
                rightSub: 'ETR: 4:00 PM',
                rightSubBold: true,
              ),
              const SizedBox(height: 12),
              const _OutageCard(
                icon: Icons.bolt_rounded,
                iconBg: Color(0xFFFFF3CD),
                iconColor: _statusUnstable,
                title: 'Lacson Street',
                subtitle: 'Voltage Surge',
                statusLabel: 'UNSTABLE',
                statusColor: _statusUnstable,
                rightSub: 'Assessing',
                rightSubBold: true,
              ),
              const SizedBox(height: 12),
              const _OutageCard(
                icon: Icons.check_circle_rounded,
                iconBg: Color(0xFFE8F8EE),
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
    // ... (Keep your existing _buildHeader code exactly the same)
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
    // ... (Keep your existing _buildEmergencyAlert code exactly the same)
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
              'Updated Just Now',
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
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? _defaultLocation,
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.afa9a9f2dce73422dfca1685d22c7acc',
                      userAgentPackageName: 'com.powerout.app',
                    ),
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 30,

                            ),
                          ),
                        ],
                      ),
                  ],
                ),
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
                      'TRACKING LOCATION',
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
                      onTap: () {
                        if (_currentPosition != null) {
                          _mapController.move(_currentPosition!, 15.0);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.my_location,
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
    // ... (Keep your existing _buildOutagesHeader code exactly the same)
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

// ... (Keep your existing _OutageCard code exactly the same)
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