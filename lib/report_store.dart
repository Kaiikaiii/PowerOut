import 'package:flutter/foundation.dart';

class UserReport {
  const UserReport({
    required this.title,
    required this.location,
    required this.details,
    required this.createdAt,
  });

  final String title;
  final String location;
  final String details;
  final DateTime createdAt;
}

class ReportStore {
  static final ValueNotifier<List<UserReport>> submittedReports =
      ValueNotifier<List<UserReport>>(<UserReport>[]);

  static void add(UserReport report) {
    submittedReports.value = <UserReport>[report, ...submittedReports.value];
  }
}
