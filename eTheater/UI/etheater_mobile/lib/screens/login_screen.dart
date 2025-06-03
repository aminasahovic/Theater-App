import 'dart:convert';
import 'package:etheater_mobile/core/api_konstante.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/screens/novosti_screen.dart';
import 'package:etheater_mobile/screens/sala_kontrola_screen.dart';
import 'package:etheater_mobile/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<Map<String, dynamic>?> _login(String username, String password) async {
    try {
      final url = Uri.parse(
        '${ApiKonstante.baseUrl}/Korisnik/login',
      ).replace(queryParameters: {'username': username, 'password': password});

      final headers = {
        'accept': 'text/plain',
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      };

      final response = await http.post(url, headers: headers, body: '');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AuthProvider.setAuthInfo(
          username: username,
          password: password,
          id: data['id'],
        );
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('Greška prilikom login-a: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  'Prijavi se',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Korisničko ime',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Obavezno polje'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Lozinka',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Obavezno polje'
                              : null,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 10),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });

                            final username = _usernameController.text.trim();
                            final password = _passwordController.text.trim();

                            final data = await _login(username, password);

                            setState(() {
                              _isLoading = false;
                            });

                            if (data != null) {
                              final tipKorisnikaId = data['tipKorisnikaId'];
                              Widget targetScreen;

                              if (tipKorisnikaId == 3) {
                                targetScreen = const NovostiScreen();
                              } else if (tipKorisnikaId == 2 ||
                                  tipKorisnikaId == 4) {
                                targetScreen = const SalaKontrolaScreen();
                              } else {
                                setState(() {
                                  _errorMessage = 'Nepoznat tip korisnika';
                                });
                                return;
                              }

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => targetScreen),
                              );
                            } else {
                              setState(() {
                                _errorMessage =
                                    'Neispravno korisničko ime ili lozinka';
                              });
                            }
                          },
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Prijava'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Nemate račun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('Registrujte se'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
