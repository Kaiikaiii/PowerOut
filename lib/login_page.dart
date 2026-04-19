import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apiservice.dart';
import 'main_navigation.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Color themeYellow = const Color(0xFFFFD119);

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  // =========================
  // 🔐 AUTO LOGIN
  // =========================
  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isSuccess(Map<String, dynamic> response) {
    final success = response['success'];
    final status = response['status'];
    return success == true ||
        success == 1 ||
        status == true ||
        status == 1 ||
        status?.toString().toLowerCase() == 'success';
  }

  String _messageFrom(Map<String, dynamic> response, String fallback) {
    return (response['message'] ??
            response['msg'] ??
            response['error'] ??
            fallback)
        .toString();
  }

  // =========================
  // 🔐 LOGIN FUNCTION
  // =========================
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.login(email, password);

    setState(() => _isLoading = false);

    print("LOGIN RESPONSE: $response");

    if (_isSuccess(response)) {
      // =========================
      // 💾 SAVE USER SESSION
      // =========================
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', response['id'].toString());
      await prefs.setString('user_name', response['name'] ?? '');
      await prefs.setString('user_email', response['email'] ?? '');
      await prefs.setString('user_barangay', response['barangay'] ?? '');

      if (!mounted) return;

      // Go to main app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _messageFrom(response, 'Login failed. Please try again.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: themeYellow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 80),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'POWEROUT',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              const Text(
                'Email',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.alternate_email,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Password',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              _buildInputContainer(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: SizedBox(
                  width: 200,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeYellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            )
                            : const Text(
                              'LOG IN',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}