import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ps_books/services/study/target_sync.dart' as target_sync;
import 'package:ps_books/state/google_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignIn = true;
  bool _isLoading = false;

  final _dio = Dio();
  final String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);

    try {
      final endpoint = _isSignIn ? '/api/auth/sign-in/email' : '/api/auth/sign-up/email';
      final data = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };

      if (!_isSignIn) {
        data['name'] = _nameController.text.trim();
      }
print('$baseUrl$endpoint');
      final response = await _dio.post('$baseUrl$endpoint', data: data);

      // Extract token and user info
      final responseData = response.data;
      final token = responseData['token'];
      final userData = responseData['user'];
      print(responseData);
      // Save to shared preferences for debugging
      final prefs = await SharedPreferences.getInstance();
      if (token != null) await prefs.setString('ps_auth_token', token);

      final userName = userData != null ? userData['name'] as String : '';
      await ref.read(userAccountsProvider.notifier).updatePsBooksUser(userName, true);

      target_sync.syncTargetsIfSignedIn();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSignIn ? "Logged in successfully" : "Signed up successfully",
            ),
          ),
        );
        context.pop();
      }
    } catch (e,h) {
      print(h);
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An unexpected error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF1B1227);
    const Color cardColor = Color(0xFF2A1C3D);
    const Color primaryAccent = Color(0xFF7C3AED);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(_isSignIn ? "Login" : "Sign Up"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isSignIn 
            ? _buildSignInWidget(cardColor, primaryAccent) 
            : _buildSignUpWidget(cardColor, primaryAccent),
        ),
      ),
    );
  }

  Widget _buildSignInWidget(Color cardColor, Color primaryAccent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.menu_book_rounded, size: 80),
        const SizedBox(height: 32),
        Text(
          "Welcome Back",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Login to sync your library and progress",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 40),
        _buildTextField(_emailController, "Email", Icons.email_outlined, cardColor),
        const SizedBox(height: 16),
        _buildTextField(_passwordController, "Password", Icons.lock_outline, cardColor, obscureText: true),
        const SizedBox(height: 24),
        _buildAuthButton("Login", primaryAccent),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : () => setState(() => _isSignIn = false),
          child: const Text("Don't have an account? Sign Up", style: TextStyle()),
        ),
      ],
    );
  }

  Widget _buildSignUpWidget(Color cardColor, Color primaryAccent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.menu_book_rounded, size: 80,),
        const SizedBox(height: 32),
        Text(
          "Welcome Aboard",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign Up to sync your Timetable and Targets",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 40),
        _buildTextField(_nameController, "Full Name", Icons.person_outline, cardColor),
        const SizedBox(height: 16),
        _buildTextField(_emailController, "Email", Icons.email_outlined, cardColor),
        const SizedBox(height: 16),
        _buildTextField(_passwordController, "Password", Icons.lock_outline, cardColor, obscureText: true),
        const SizedBox(height: 24),
        _buildAuthButton("Sign Up", primaryAccent),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : () => setState(() => _isSignIn = true),
          child: const Text("Already have an account? Log In", style: TextStyle()),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, Color cardColor, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      enabled: !_isLoading,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        fillColor: cardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildAuthButton(String label, Color primaryAccent) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _isLoading ? null : _handleAuth,
      child: _isLoading 
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
        : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
