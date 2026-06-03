import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingFinesScreen extends StatefulWidget {
  final String clubId;

  const PendingFinesScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<PendingFinesScreen> createState() => _PendingFinesScreenState();
}

class _PendingFinesScreenState extends State<PendingFinesScreen> {
  final supabase = Supabase.instance.client;

  List fines = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFines();
  }

  Future<void> loadFines() async {
    try {
      final data = await supabase
          .from('fine_requests')
          .select('''
            id,
            status,
            created_at,
            fines:fine_id(title),
            profiles:user_id(name)
          ''')
          .eq('club_id', widget.clubId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        fines = data;
        loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
    }
  }

  Future<void> approveFine(String id) async {
    await supabase
        .from('fine_requests')
        .update({'status': 'approved'})
        .eq('id', id);

    loadFines();
  }

  Future<void> declineFine(String id) async {
    await supabase
        .from('fine_requests')
        .update({'status': 'declined'})
        .eq('id', id);

    loadFines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Pending Fines",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : fines.isEmpty
              ? const Center(
                  child: Text(
                    "No pending fines",
                    style: TextStyle(color: Colors.white70),
                  ),
                )

              : ListView.builder(
                  itemCount: fines.length,
                  itemBuilder: (context, index) {
                    final fine = fines[index];
                    final profile = fine['profiles'];
                    final name = profile != null
                        ? profile['name']
                        : 'Unknown';

                    final template = fine['fines'];
                    final title = template != null
                        ? template['title']
                        : 'Fine';

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${fine['amount']} DKK",
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Created: ${fine['created_at']}",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    declineFine(fine['id']),
                                child: const Text(
                                  "Decline",
                                  style:
                                      TextStyle(color: Colors.red),
                                ),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () =>
                                    approveFine(fine['id']),
                                child: const Text("Approve"),
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