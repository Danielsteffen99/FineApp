import 'package:fineapp/screens/club_screen.dart';
import 'package:fineapp/screens/login_screen.dart';
import 'package:fineapp/screens/profile_screen.dart';
import 'package:fineapp/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zhfgmysxqjlxbsggyxju.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpoZmdteXN4cWpseGJzZ2d5eGp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4OTU4MzUsImV4cCI6MjA5MzQ3MTgzNX0.fSHlomvMuSI4hoeK3ZpjOIoCGyI1__zg-_25FFoiuOk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      // START SCREEN
      home: const SplashScreen(),

      routes: {
        '/auth': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/clubscreen': (context) => const ClubScreen(clubId: '', clubName: '',)
        },
    );
  }
}