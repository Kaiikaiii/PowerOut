import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserReport {
  const UserReport({
    required this.userId,
    required this.title,
    required this.location,
    required this.details,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  final String userId;
  final String title;
  final String location;
  final String details;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'title': title,
      'location': location,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      userId: (json['userId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class ReportStore {
  static const String _storageKey = 'submitted_reports_cache_v1';
  static final ValueNotifier<List<UserReport>> submittedReports =
      ValueNotifier<List<UserReport>>(<UserReport>[]);
  static bool _initialized = false;

  static Future<void> add(UserReport report) async {
    submittedReports.value = <UserReport>[report, ...submittedReports.value];
    await _persist();
  }

  static Future<void> clear() async {
    submittedReports.value = <UserReport>[];
    await _persist();
  }

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final loaded = decoded
          .whereType<Map>()
          .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
          .map(UserReport.fromJson)
          .toList();
      submittedReports.value = loaded;
    } catch (_) {
      // Ignore corrupt cache and keep app usable.
    }
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(submittedReports.value.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
