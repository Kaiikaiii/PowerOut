import 'package:flutter/material.dart';
import 'admin_login_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // The yellow color from your design
  final Color themeYellow = const Color(0xFFFFD119);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // 1. Yellow Logo Box
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: themeYellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 90,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 2. Title
              const Text(
                'Welcome To PowerOut',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia', // Matches your serif font
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 3. Subtitle
              Text(
                'Stay informed. Track real-time power outages\nacross Bacolod City with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  height: 1.4, // Line height for readability
                ),
              ),
              
              const Spacer(flex: 2),
              
              // 4. LOGIN Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeYellow,
                    foregroundColor: Colors.black, // Black text
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 5. SIGN UP Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8F9FA), // Very slight off-white fill like the image
                    foregroundColor: Colors.black, // Black text
                    side: BorderSide(color: themeYellow, width: 1.5), // Yellow border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AdminLoginPage(),
                    ),
                  );
                },
                child: const Text('Admin Login'),
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}