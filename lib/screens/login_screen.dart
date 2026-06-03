import 'package:flutter/material.dart';
import '../features/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final AuthService _authService = AuthService();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> handleAuth() async {
  setState(() => isLoading = true);

  try {
    if (isLogin) {
      await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      await _authService.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
    }

    // ✅ ADD THIS: go to profile after success
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile');
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF121212),

    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // LOGO / TITLE
                const Icon(
                  Icons.sports_soccer,
                  size: 70,
                  color: Colors.white,
                ),

                const SizedBox(height: 15),

                const Text(
                  "FineApp",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isLogin
                      ? "Login to your club"
                      : "Create your account",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                // NAME FIELD (ONLY SIGNUP)
                if (!isLogin)
                  Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: "Name",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),

                // EMAIL
                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                ),

                const SizedBox(height: 15),

                // PASSWORD
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  obscure: true,
                ),

                const SizedBox(height: 25),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: isLoading ? null : handleAuth,

                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isLogin ? "Login" : "Create Account",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // TOGGLE LOGIN/SIGNUP
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },

                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Login",
                    style: const TextStyle(
                      color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,

    style: const TextStyle(color: Colors.white),

    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),

      prefixIcon: Icon(icon, color: Colors.white70),

      filled: true,
      fillColor: const Color(0xFF2A2A2A),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
        ),
      ),
    );
  }
}