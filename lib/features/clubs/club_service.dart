import '../../core/supabase_client.dart';

class ClubService {
  Future<void> joinClub(String name, String password) async {
    final user = supabase.auth.currentUser;

    final club = await supabase
        .from('clubs')
        .select()
        .eq('name', name)
        .eq('password', password)
        .single();

    await supabase.from('club_members').insert({
      'club_id': club['id'],
      'user_id': user!.id,
      'role': 'member',
    });
  }
}