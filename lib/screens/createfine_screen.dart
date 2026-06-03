import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateFineScreen extends StatefulWidget {
  final String clubId;

  const CreateFineScreen({
    super.key,
    required this.clubId,
  });

  @override
  State<CreateFineScreen> createState() =>
      _CreateFineScreenState();
}

class _CreateFineScreenState
    extends State<CreateFineScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  bool loading = false;

  Future<void> createFine() async {
    setState(() => loading = true);

    try {
      final title = _titleController.text.trim();
      final amountText =
          _amountController.text.trim();

      // VALIDATION
      if (title.isEmpty || amountText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Enter title and amount",
            ),
          ),
        );

        setState(() => loading = false);
        return;
      }

      final amount = int.tryParse(amountText);

      if (amount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Amount must be a number",
            ),
          ),
        );

        setState(() => loading = false);
        return;
      }

      // INSERT FINE TEMPLATE
      await supabase.from('fines').insert({
        'club_id': widget.clubId,
        'title': title,
        'amount': amount,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fine created"),
        ),
      );

      Navigator.pop(context);

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
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Create Fine",
          style: TextStyle(color: Colors.white),
      ),
        iconTheme: const IconThemeData(
          color: Colors.white,
      ),
    ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // TITLE
            TextField(
              controller: _titleController,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: const InputDecoration(
                labelText: "Fine Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // AMOUNT
            TextField(
              controller: _amountController,

              keyboardType:
                  TextInputType.number,

              style: const TextStyle(
                color: Colors.white,
              ),

              decoration: const InputDecoration(
                labelText: "Amount (DKK)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    loading ? null : createFine,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Fine"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}