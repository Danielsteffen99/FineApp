import 'package:fineapp/screens/club_screen.dart';
import 'package:fineapp/screens/login_screen.dart';
import 'package:fineapp/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final supabase = Supabase.instance.client;

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    checkUser();
  });
}

  Future<void> checkUser() async {

  try {

    final session = supabase.auth.currentSession;

    // NOT LOGGED IN
    if (session == null) {

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );

      return;
    }

    final user = session.user;

    // CHECK MEMBERSHIP
    final membership = await supabase
        .from('club_members')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    // USER HAS CLUB
    if (membership != null) {

      final clubId = membership['club_id'];

      // GET CLUB SEPARATELY
      final club = await supabase
          .from('clubs')
          .select()
          .eq('id', clubId)
          .single();

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

    // NO CLUB
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );

  } catch (e) {

    debugPrint("Splash Error: $e");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}