import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardScreen extends StatefulWidget {
  final String clubId;

  const LeaderboardScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final supabase = Supabase.instance.client;

  List leaderboard = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    try {
      final data = await supabase
          .from('fines')
          .select('''
            user_id,
            amount,
            paid,
            profiles(name)
          ''')
          .eq('club_id', widget.clubId);

      final Map<String, dynamic> grouped = {};

      for (final item in data) {
        final userId = item['user_id'];
        final amount = (item['amount'] ?? 0).toDouble();
        final paid = item['paid'] ?? false;
        final name = item['profiles']?['name'] ?? 'Unknown';

        if (!grouped.containsKey(userId)) {
          grouped[userId] = {
            'name': name,
            'paid': 0.0,
            'unpaid': 0.0,
          };
        }

        if (paid) {
          grouped[userId]['paid'] += amount;
        } else {
          grouped[userId]['unpaid'] += amount;
        }
      }

      final list = grouped.entries.map((e) {
        final unpaid = e.value['unpaid'];
        final paid = e.value['paid'];

        return {
          'name': e.value['name'],
          'paid': paid,
          'unpaid': unpaid,
        };
      }).toList();

      // ONLY SORT BY UNPAID (HIGHEST FIRST)
      list.sort((a, b) => b['unpaid'].compareTo(a['unpaid']));

      setState(() {
        leaderboard = list;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Leaderboard"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaderboard.length,

              itemBuilder: (context, index) {
                final user = leaderboard[index];
                final rank = index + 1;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [

                      // RANK
                      CircleAvatar(
                        backgroundColor: rank == 1
                            ? Colors.amber
                            : Colors.white24,
                        child: Text(
                          "$rank",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // NAME
                      Expanded(
                        child: Text(
                          user['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // AMOUNTS (STACKED)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          // UNPAID (RED TOP)
                          Text(
                            "${user['unpaid'].toStringAsFixed(0)} DKK",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // PAID (GREEN BOTTOM)
                          Text(
                            "${user['paid'].toStringAsFixed(0)} DKK",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}