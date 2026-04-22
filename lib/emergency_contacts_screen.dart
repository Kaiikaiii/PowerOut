import 'package:flutter/material.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Emergency Contacts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  const Icon(Icons.info_rounded, size: 18, color: Color(0xFF4B4B4B)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8EA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search (e.g., CENECO, Fire)',
                    hintStyle: TextStyle(fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const _ContactSection(
                title: 'Utility Providers',
                contacts: [
                  _ContactItemData(
                    icon: Icons.bolt_rounded,
                    iconColor: Color(0xFF1D1D1D),
                    title: 'CENECO Main',
                    subtitle: 'Bacolod Power Utility Hotline',
                  ),
                  _ContactItemData(
                    icon: Icons.build_rounded,
                    iconColor: Color(0xFF1D1D1D),
                    title: 'CENECO Technical',
                    subtitle: 'Technical Repair Services',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _ContactSection(
                title: 'Emergency Services',
                contacts: [
                  _ContactItemData(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: Color(0xFF1D1D1D),
                    title: 'Bacolod Fire Dept',
                    subtitle: 'Fire Emergency (BFP)',
                  ),
                  _ContactItemData(
                    icon: Icons.local_police_rounded,
                    iconColor: Color(0xFF1D1D1D),
                    title: 'Bacolod Police',
                    subtitle: 'BCPO Station Dispatch',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _ContactSection(
                title: 'Disaster Response',
                contacts: [
                  _ContactItemData(
                    icon: Icons.wifi_tethering_error_rounded,
                    iconColor: Color(0xFF1D1D1D),
                    title: 'DRRMO Bacolod',
                    subtitle: 'Rescue & Disaster Hotline',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.title,
    required this.contacts,
  });

  final String title;
  final List<_ContactItemData> contacts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF434343),
          ),
        ),
        const SizedBox(height: 8),
        ...contacts.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ContactItem(item: item),
            )),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({required this.item});

  final _ContactItemData item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFECE400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: item.iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8A8A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 34,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${item.title}...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFECE400),
              foregroundColor: const Color(0xFF242424),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text(
              'CALL',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactItemData {
  const _ContactItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
}
