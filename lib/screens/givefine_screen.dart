import 'package:fineapp/screens/createfine_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GivefineScreen extends StatefulWidget {
  final String clubId;

  const GivefineScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<GivefineScreen> createState() => _GivefineScreenState();
}

class _GivefineScreenState extends State<GivefineScreen> {
  final supabase = Supabase.instance.client;

  List players = [];
  List fineTemplates = [];

  String? selectedUserId;
  String? selectedFineId;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final members = await supabase
          .from('club_members')
          .select('user_id, profiles(name)')
          .eq('club_id', widget.clubId);

      final fines = await supabase
          .from('fines')
          .select()
          .eq('club_id', widget.clubId);

      setState(() {
        players = members;
        fineTemplates = fines;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> assignFine() async {
  setState(() => loading = true);

  try {
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) return;

    if (selectedUserId == null || selectedFineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select player and fine")),
      );

      setState(() => loading = false);
      return;
    }

    // CHECK IF CURRENT USER IS ADMIN
    final memberData = await supabase
        .from('club_members')
        .select('role')
        .eq('club_id', widget.clubId)
        .eq('user_id', currentUser.id)
        .single();

    final bool isAdmin = memberData['role'] == 'admin';

    // ADMIN = AUTO APPROVED
    // MEMBER = PENDING
    final String status = isAdmin ? 'approved' : 'pending';

    await supabase.from('fine_requests').insert({
      'club_id': widget.clubId,
      'user_id': selectedUserId, // person getting fined
      'fine_id': selectedFineId,
      'created_by': currentUser.id, // who gave the fine
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdmin
              ? "Fine assigned"
              : "Fine sent for approval",
        ),
      ),
    );

    Navigator.pop(context, true);

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Assign Fine",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateFineScreen(
                    clubId: widget.clubId,
                  ),
                ),
              );

              loadData();
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // PLAYER SELECT
            DropdownButtonFormField<String>(
              initialValue: selectedUserId,
              items: players.map<DropdownMenuItem<String>>((p) {
                final name = p['profiles']?['name'] ?? 'Unknown';

                return DropdownMenuItem(
                  value: p['user_id'],
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUserId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Player",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // FINE TEMPLATE SELECT
            DropdownButtonFormField<String>(
              initialValue: selectedFineId,
              items: fineTemplates.map<DropdownMenuItem<String>>((f) {
                return DropdownMenuItem(
                  value: f['id'],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(f['title']),
                      Text("  ${f['amount']} DKK"),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFineId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Select Fine Type",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : assignFine,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Assign Fine"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}