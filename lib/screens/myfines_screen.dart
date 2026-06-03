import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinesScreen extends StatefulWidget {
  final String clubId;

  const FinesScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<FinesScreen> createState() => _FinesScreenState();
}

class _FinesScreenState extends State<FinesScreen> {
  final supabase = Supabase.instance.client;

  List fines = [];
  bool loading = true;

  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    loadFines();
  }

  Future<void> loadFines() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final data = await supabase
          .from('fine_requests')
          .select('''
            id,
            status,
            created_at,
            fines:fine_id(
              title,
              amount
            )
          ''')
          .eq('user_id', user.id)
          .eq('club_id', widget.clubId)
          .eq('status', 'approved')
          .order('created_at', ascending: false);

      double total = 0;

      for (var fine in data) {
        final fineData = fine['fines'];

        final amount =
            (fineData['amount'] as num?)?.toDouble() ?? 0;

        total += amount;
      }

      setState(() {
        fines = data;
        totalAmount = total;
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
        title: const Text(
          "My Fines",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : fines.isEmpty
              ? const Center(
                  child: Text(
                    "No fines yet",
                    style:
                        TextStyle(color: Colors.white70),
                  ),
                )

              : Column(
                  children: [
                    // TOTAL AMOUNT
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Total Amount Owed",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${totalAmount.toStringAsFixed(0)} DKK",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: fines.length,

                        itemBuilder: (context, index) {
                          final fine = fines[index];

                          final fineData =
                              fine['fines'];

                          final title =
                              fineData != null
                                  ? fineData['title']
                                  : 'Fine';

                          final amount =
                              fineData != null
                                  ? fineData['amount']
                                  : 0;

                          return Container(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),

                            padding:
                                const EdgeInsets.all(15),

                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFF1E1E1E),
                              borderRadius:
                                  BorderRadius
                                      .circular(12),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

                                  children: [
                                    Text(
                                      title,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors
                                                .white,
                                        fontSize:
                                            18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const Icon(
                                      Icons
                                          .check_circle,
                                      color:
                                          Colors
                                              .green,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height: 10),

                                Text(
                                  "$amount DKK",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors
                                            .amber,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}