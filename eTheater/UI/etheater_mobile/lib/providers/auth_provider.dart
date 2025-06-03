import 'dart:convert';

class AuthProvider {
  static String? _username;
  static String? _password;
  static int? _userId;

  static void setAuthInfo({
    required String username,
    required String password,
    required int id,
  }) {
    _username = username;
    _password = password;
    _userId = id;
  }

  static void logout() {
    _username = null;
    _password = null;
    _userId = null;
  }

  static Map<String, String> get authHeaders {
    if (_username == null || _password == null) {
      throw Exception('Credentials not set');
    }

    final credentials = '$_username:$_password';
    final encoded = base64Encode(utf8.encode(credentials));

    return {
      'Authorization': 'Basic $encoded',
      'Content-Type': 'application/json',
    };
  }

  static bool get isLoggedIn => _username != null && _password != null;
  static String? get username => _username;
  static String? get password => _password;
  static int? get userId => _userId;
}
