import 'package:etheater_admin/services/services.dart';

class AuthProvider {
  static int? korisnikId;
  static String? username;
  static String? password;

  static Future<void> login(String user, String pass) async {
    final response = await ApiService.login(user, pass);

    if (response.tipKorisnikaId != 4) {
      throw Exception("Pristup dozvoljen samo administratorima (tip 4).");
    }

    korisnikId = response.id;
    username = user;
    password = pass;
  }

  static void logout() {
    korisnikId = null;
    username = null;
    password = null;
  }
}
