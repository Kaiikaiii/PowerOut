import 'package:flutter/material.dart';
import 'db_connect.dart';
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

  // This is the yellow color from your image
  final Color themeYellow = const Color(0xFFFFD119);

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

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await ApiService.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_isSuccess(response)) {
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(
          builder: (_) => const MainNavigationScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_messageFrom(response, 'Login failed. Please try again.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background is now white
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // 1. The Yellow Logo Box
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: themeYellow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 2. PowerOut Title (Black)
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

              // 3. Email Input
              const Text(
                'Email',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.alternate_email, color: Colors.grey.shade600),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Password Input
              const Text(
                'Password',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
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

              // 5. The Yellow LOG IN Button
              Center(
                child: SizedBox(
                  width: 200, // Matching the smaller button width from image
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'LOG IN',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // 6. Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade600, fontFamily: 'Georgia'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
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

  // Helper widget to keep text field styling consistent with the image
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9), // Very light grey fill
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400), // Thin border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}