import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersScreen extends StatefulWidget {
  final String clubId;

  const MembersScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final supabase = Supabase.instance.client;

  List members = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      final data = await supabase
          .from('club_members')
          .select('role, profiles(name)')
          .eq('club_id', widget.clubId);

      setState(() {
        members = data;
        loading = false;
      });

    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("Members"),
        backgroundColor: Colors.black,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : members.isEmpty
              ? const Center(
                  child: Text(
                    "No members found",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: members.length,

                  itemBuilder: (context, index) {
                    final member = members[index];

                    final profile = member['profiles'];

                    final name =
                        profile != null
                            ? profile['name'] ?? 'Unknown'
                            : 'Unknown';

                    final role = member['role'];

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

                          // Avatar
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : "?",
                            ),
                          ),

                          const SizedBox(width: 15),

                          // Name + Role
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  role.toString().toUpperCase(),
                                  style: TextStyle(
                                    color: role == 'admin'
                                        ? Colors.amber
                                        : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Icon
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}