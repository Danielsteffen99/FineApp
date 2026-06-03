import 'package:fineapp/screens/joinclub_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        });
      } else {
        setState(() {
          _nameController.text =
              user.userMetadata?['display_name'] ?? '';

          _emailController.text = user.email ?? '';
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateProfile() async {
    setState(() => loading = true);

    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Update profiles table
      await supabase.from('profiles').upsert({
        'id': user.id,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      // Update auth email
      if (_emailController.text.trim() != user.email) {
        await supabase.auth.updateUser(
          UserAttributes(
            email: _emailController.text.trim(),
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated"),
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    setState(() => loading = false);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 10),

            Text(
              _nameController.text.isEmpty
                  ? "Hello"
                  : "Hello ${_nameController.text}",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 35),

            _buildField(
              controller: _nameController,
              label: "Name",
              icon: Icons.person,
            ),

            const SizedBox(height: 20),

            _buildField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email,
            ),

            const SizedBox(height: 20),

            _buildField(
              controller: _phoneController,
              label: "Phone Number",
              icon: Icons.phone,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : updateProfile,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Update Profile"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinClubScreen(),
                  ),
                );
              },

              child: const Text("Join Club"),
            ),
          ],
        ),
      ),
    );
  }
}