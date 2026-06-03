import '../../core/supabase_client.dart';

class AuthService {
  Future<void> signUp(
    String email,
    String password,
    String name,
)    async {

  final response = await supabase.auth.signUp(
    email: email,
    password: password,

    data: {
      'display_name': name,
    },
  );

  final user = response.user;

  if (user != null) {
    await supabase.from('profiles').insert({
      'id': user.id,
      'name': name,
      'email': email,
    });
  }
}

  Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
}