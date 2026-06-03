import '../../core/supabase_client.dart';

class FineService {
Future<void> createFine(String title, String clubId, String description, double amount,) 

async {
    final user = supabase.auth.currentUser;

    await supabase.from('fines').insert({
      'title': title,
      'club_id': clubId,
      'description': description,
      'amount': amount,
      'created_by': user!.id,
    });
  }
}

Future<void> giveFine({
  required String clubId,
  required String playerId,
  required Map fine,

}) async {
    final user = supabase.auth.currentUser;

    await supabase.from('assigned_fines').insert({
      'club_id': clubId,
      'player_id': playerId,
      'fine_id': fine['id'],
      'amount': fine['amount'],
      'created_by': user!.id,
    });
  }

Future<void> createFineRequest({
  required String clubId,
  required String playerId,
  required String fineId,
  String? reason,
  
}) async {
  final user = supabase.auth.currentUser;

  await supabase.from('fine_requests').insert({
      'club_id': clubId,
      'player_id': playerId,
      'fine_id': fineId,
      'created_by': user!.id,
      'reason': reason,
  });
}