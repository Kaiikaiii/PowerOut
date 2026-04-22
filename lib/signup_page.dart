import 'package:flutter/material.dart';
import 'apiservice.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? _selectedBarangay;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _barangayOptions = const [
    'Barangay Villamonte',
    'Barangay Estefania',
    'Barangay 2',
    'Barangay Mandalagan',
  ];

  // The yellow theme color
  final Color themeYellow = const Color(0xFFFFD119);

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }
    if (_selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your barangay.')),
      );
      return;
    }

    setState(() => _isLoading = true);
final response = await ApiService.signup(
  name,
  email,
  password,
  _selectedBarangay!,
);    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_isSuccess(response)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageFrom(response, 'Signup successful.'))),
      );
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_messageFrom(response, 'Signup failed. Please try again.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // 1. Yellow Logo Box
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
              
              // 2. Title and Subtitle
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
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 3. Name Input
              const Text(
                'Name',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: 'Kyle Arguelles',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 4. Email Input
              const Text(
                'Email',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'example@email.com',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 5. Password Input
              const Text(
                'Password',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••',
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Colors.black54),
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
              
              const SizedBox(height: 20),
              
              // 6. Barangay Dropdown
              const Text(
                'Barangay',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
              ),
              const SizedBox(height: 8),
              _buildInputContainer(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBarangay,
                    hint: const Text(
                      'Select your Barangay',
                      style: TextStyle(color: Colors.black54),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: _barangayOptions
                        .map((b) => DropdownMenuItem<String>(
                              value: b,
                              child: Text(b),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBarangay = value;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 7. The Yellow SIGN UP Button
              Center(
                child: SizedBox(
                  width: 200, // Matches the narrow button from your image
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeYellow,
                      foregroundColor: Colors.black, // Black text
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSignup,
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
                            'SIGN UP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 8. Log In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: Color(0xFF2854C5), // The blue color from your image
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to keep the input fields looking clean with a light background and border
  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Very light grey fill
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: child,
    );
  }
}