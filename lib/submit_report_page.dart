import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiservice.dart';
import 'report_store.dart';

class SubmitReportPage extends StatefulWidget {
  const SubmitReportPage({super.key});

  @override
  State<SubmitReportPage> createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  static const LatLng _defaultLocation = LatLng(10.6667, 122.9500);
  LatLng? _selectedLocation;
  String _selectedType = 'No Power';
  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final current = await _getCurrentLatLng();
    if (!mounted || current == null) return;

    setState(() {
      _selectedLocation = current;
      _locationController.text = _formatCoordinates(current);
    });
    _mapController.move(current, 15.0);
  }

  Future<LatLng?> _getCurrentLatLng() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _useCurrentLocation() async {
    final current = await _getCurrentLatLng();
    if (!mounted || current == null) return;

    setState(() {
      _selectedLocation = current;
      _locationController.text = _formatCoordinates(current);
    });
    _mapController.move(current, 16.0);
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      _selectedLocation = point;
      _locationController.text = _formatCoordinates(point);
    });
  }

  String _formatCoordinates(LatLng point) {
    return '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
  }

  String _mapReportTypeForApi(String typeLabel) {
    switch (typeLabel) {
      case 'No Power':
        return 'no_power';
      case 'Partial Power':
        return 'partial_power';
      case 'Downed Line':
        return 'downed_line';
      default:
        return 'other';
    }
  }

  bool _isApiSuccess(Map<String, dynamic> response) {
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

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    final location = _locationController.text.trim().isEmpty
        ? 'Bacolod City'
        : _locationController.text.trim();
    final details = _detailsController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id')?.trim() ?? '';
    final userBarangay = prefs.getString('user_barangay')?.trim() ?? '';

    if (userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again before submitting.')),
      );
      return;
    }
    if (userBarangay.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing user barangay. Please update profile.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final apiResponse = await ApiService.submitReport(
      userId: userId,
      location: location,
      barangay: userBarangay,
      reportType: _mapReportTypeForApi(_selectedType),
      details: details,
      photo: _selectedPhoto?.name ?? '',
      photoBytes: _selectedPhotoBytes,
      photoFileName: _selectedPhoto?.name,
    );

    final isSuccess = _isApiSuccess(apiResponse);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (!isSuccess) {
      final message =
          (apiResponse['message'] ?? 'Failed to submit report. Please try again.').toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    await ReportStore.add(
      UserReport(
        userId: userId,
        title: _selectedType,
        location: location,
        details: details,
        createdAt: DateTime.now(),
        latitude: _selectedLocation?.latitude,
        longitude: _selectedLocation?.longitude,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((apiResponse['message'] ?? 'Report submitted successfully.').toString()),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickPhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (!mounted || image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _selectedPhoto = image;
      _selectedPhotoBytes = bytes;
    });
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
      _selectedPhotoBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Report an Outage',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7DB46),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Submit Report',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('LOCATION', Icons.location_on_rounded),
            const SizedBox(height: 8),
            _mapPlaceholder(),
            const SizedBox(height: 8),
            _outlinedButton(
              icon: Icons.my_location,
              label: 'Use current location',
              onPressed: _useCurrentLocation,
            ),
            const SizedBox(height: 12),
            _input(
              controller: _locationController,
              hintText: 'Search address or landmark',
            ),
            const SizedBox(height: 14),
            _sectionLabel('OUTAGE DETAILS', Icons.info_rounded),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _typeChip('No Power'),
                _typeChip('Partial Power'),
                _typeChip('Downed Line'),
                _typeChip('Other'),
              ],
            ),
            const SizedBox(height: 8),
            _input(
              controller: _detailsController,
              hintText: 'Add details or notes (optional)',
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            _sectionLabel('PHOTOS', Icons.photo_camera_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18, color: Colors.grey),
                        SizedBox(height: 4),
                        Text(
                          'ADD',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedPhotoBytes != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(_selectedPhotoBytes!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: _removePhoto,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _outlinedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Color(0xFFE1E1E1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _typeChip(String label) {
    final selected = _selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = label),
      child: Container(
        width: 84,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? Colors.black87 : const Color(0xFFE1E1E1),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _mapPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation ?? _defaultLocation,
            initialZoom: 13.0,
            onTap: (_, point) => _onMapTapped(point),
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
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
