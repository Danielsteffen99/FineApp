import 'package:fineapp/screens/club_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JoinClubScreen extends StatefulWidget {
  const JoinClubScreen({super.key});

  @override
  State<JoinClubScreen> createState() => _JoinClubScreenState();
}

class _JoinClubScreenState extends State<JoinClubScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController _clubNameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool loading = false;

Future<void> joinClub() async {
  setState(() => loading = true);

  try {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    // Find club
    final club = await supabase
        .from('clubs')
        .select()
        .eq('name', _clubNameController.text.trim())
        .eq('password', _passwordController.text.trim())
        .maybeSingle();

    // Wrong club/password
    if (club == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Club not found or wrong password"),
        ),
      );

      setState(() => loading = false);
      return;
    }

    final clubId = club['id'];

    // Check if already member
    final existingMember = await supabase
        .from('club_members')
        .select()
        .eq('club_id', clubId)
        .eq('user_id', user.id)
        .maybeSingle();

    // Already member
    if (existingMember != null) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClubScreen(
            clubId: clubId,
            clubName: club['name'],
          ),
        ),
      );

      return;
    }

    // NOT member yet
    // Insert into club_members
    await supabase.from('club_members').insert({
      'club_id': clubId,
      'user_id': user.id,
      'role': 'member',
    });

    if (!mounted) return;

    // Go to club screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ClubScreen(
          clubId: clubId,
          clubName: club['name'],
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
      ),
    );
  }

  setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Club"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            const Text(
              "Join a Club",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _clubNameController,
              decoration: const InputDecoration(
                labelText: "Club Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Club Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: loading ? null : joinClub,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Join Club"),
            ),
          ],
        ),
      ),
    );
  }
}