import 'package:flutter/material.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'SCHEDULED OUTAGES',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.info, size: 18),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search area or barangay...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _dateTag('TOMORROW, OCT 25'),
          const SizedBox(height: 10),
          const _ScheduleCard(
            startTime: '08:00 AM',
            endTime: '12:00 PM',
            title: 'Feeder 4 - Lacson St.',
            description:
                'Brgy. Mandalagan, Lacson St. from Robinson\'s Place to North Drive.',
            activity: 'MAINTENANCE',
          ),
          const Divider(height: 18, color: Color(0xFFE3E3E3)),
          const _ScheduleCard(
            startTime: '01:00 PM',
            endTime: '05:00 PM',
            title: 'Feeder 7 - Alijis',
            description:
                'Providencia Subd, Paglaum Village and surrounding areas.',
            activity: 'TREE TRIMMING',
          ),
          const SizedBox(height: 14),
          _dateTag('SATURDAY, OCT 26'),
          const SizedBox(height: 10),
          const _ScheduleCard(
            startTime: '09:00 AM',
            endTime: '04:00 PM',
            title: 'Feeder 2 - Mandalagan',
            description:
                'Affected areas include Art District, Santa Clara Subd.',
            activity: 'POLE REPLACEMENT',
          ),
        ],
      ),
    );
  }

  Widget _dateTag(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: const Color(0xFFF4DB3D),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
    required this.activity,
  });

  final String startTime;
  final String endTime;
  final String title;
  final String description;
  final String activity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              color: const Color(0xFFF4DB3D),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              child: Text(
                startTime,
                style: const TextStyle(
                  fontSize: 34 * 0.8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '— $endTime',
              style: const TextStyle(
                fontSize: 34 * 0.8,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 33 * 0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.build_circle_outlined, size: 13, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              activity,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'NOTIFY ME',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
