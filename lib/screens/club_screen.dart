import 'package:fineapp/screens/leaderboard_screen.dart';
import 'package:fineapp/screens/pendingfines_screen.dart';
import 'package:flutter/material.dart';
import 'package:fineapp/screens/members_screen.dart';
import 'package:fineapp/screens/myfines_screen.dart';
import 'package:fineapp/screens/givefine_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubScreen extends StatefulWidget {
  final String clubId;
  final String clubName;

  const ClubScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  final supabase = Supabase.instance.client;

  bool isAdmin = false;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    loadRole();
    loadTotalAmount();
  }

  Future<void> loadRole() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('club_members')
        .select('role')
        .eq('club_id', widget.clubId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (data != null) {
      setState(() {
        isAdmin = data['role'] == 'admin';
      });
    }
  }

  Future<void> loadTotalAmount() async {
  final data = await supabase
      .from('fine_requests')
      .select('''
        fines (
          amount
        )
      ''')
      .eq('club_id', widget.clubId)
      .eq('status', 'approved');

  double total = 0;

  for (var item in data) {
    final fine = item['fines'];

    if (fine != null) {
      total += (fine['amount'] as num?)?.toDouble() ?? 0;
    }
  }

    setState(() {
      totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: Text(
          widget.clubName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // TOTAL AMOUNT
            Column(
              children: [
                const Text(
                  "Bødekasse",
                    style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

    const SizedBox(height: 8),

            Text(
              "${totalAmount.toStringAsFixed(0)} DKK",
                style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

    const SizedBox(height: 5),

      const Text(
        "Total unpaid fines",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
          ),
        ),
      ],
    ),

            const SizedBox(height: 30),

            // ACTION CIRCLES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circle(
                  Icons.payment,
                  "Pay Fine",
                  onTap: () {},
                ),
                _circle(
                  Icons.gavel,
                  "Give Fine",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GivefineScreen(
                          clubId: widget.clubId,
                        ),
                      ),
                    );
                  },
                ),
                _circle(
                  Icons.emoji_events,
                  "Leaderboard",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeaderboardScreen(
                          clubId: widget.clubId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ADMIN ONLY
            if (isAdmin) ...[
              _menu(
                "Pending Fines",
                Icons.hourglass_top,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PendingFinesScreen(
                        clubId: widget.clubId,
                      ),
                    ),
                  );
                },
              ),

              _menu(
                "Activities",
                Icons.list,
                onTap: () {},
              ),
            ],

            // NORMAL MENU
            _menu(
              "Members",
              Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MembersScreen(
                      clubId: widget.clubId,
                    ),
                  ),
                );
              },
            ),

            _menu(
              "My Fines",
              Icons.receipt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinesScreen(
                      clubId: widget.clubId,
                    ),
                  ),
                );
              },
            ),

            _menu(
              "Settings",
              Icons.settings,
              onTap: () {},
            ),

            _menu(
              "Logout",
              Icons.logout,
              onTap: () async {
                await supabase.auth.signOut();

                if (!mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _circle(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E1E1E),
              border: Border.all(
                color: Colors.white12,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}