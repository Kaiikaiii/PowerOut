import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome_screen.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _adminEmail = 'admin@gmail.com';

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

    if (!mounted) return;
    setState(() {
      _adminEmail = adminEmail;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          TextButton(
            onPressed: _logoutAdmin,
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_adminEmail',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('You are now inside the protected admin page.'),
          ],
        ),
      ),
    );
  }
}
