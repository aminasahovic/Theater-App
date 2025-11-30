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
          slika: data['slikaProfila'],
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                color: Colors.white.withOpacity(0.4),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/logo.png', height: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'Prijavi se',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Korisničko ime',
                            prefixIcon: const Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.grey.shade200.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
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
                          decoration: InputDecoration(
                            labelText: 'Lozinka',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.grey.shade200.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Obavezno polje'
                                      : null,
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: const Color(0xFF800000),
                            ),
                            onPressed:
                                _isLoading
                                    ? null
                                    : () async {
                                      if (!_formKey.currentState!.validate())
                                        return;
                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });
                                      final username =
                                          _usernameController.text.trim();
                                      final password =
                                          _passwordController.text.trim();
                                      final data = await _login(
                                        username,
                                        password,
                                      );
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      if (data != null) {
                                        final tipKorisnikaId =
                                            data['tipKorisnikaId'];
                                        Widget targetScreen;
                                        if (tipKorisnikaId == 3) {
                                          targetScreen = const NovostiScreen();
                                        } else if (tipKorisnikaId == 2 ||
                                            tipKorisnikaId == 4) {
                                          targetScreen =
                                              const SalaKontrolaScreen();
                                        } else {
                                          setState(() {
                                            _errorMessage =
                                                'Nepoznat tip korisnika';
                                          });
                                          return;
                                        }
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => targetScreen,
                                          ),
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
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Prijava',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
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
            ),
          ),
        ],
      ),
    );
  }
}
