import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'master_screen.dart';
import 'login_screen.dart'; // Ako koristiš named routing, koristi Navigator.pushNamed(context, 'login')

class ProfileScreen extends StatefulWidget {
  final int korisnikId;

  const ProfileScreen({Key? key, required this.korisnikId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Korisnik> _futureKorisnik;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordPotvrdaController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();

  bool _showPasswordFields = false;
  var tipKorisnika = 0;

  @override
  void initState() {
    super.initState();
    _futureKorisnik = ApiService.getKorisnikById(AuthProvider.userId!);
    _futureKorisnik.then((korisnik) {
      _imeController.text = korisnik.ime;
      _prezimeController.text = korisnik.prezime;
      _usernameController.text = korisnik.username;
      _emailController.text = korisnik.email;
      _telefonController.text = korisnik.brojTelefona;
      tipKorisnika = korisnik.tipKorisnikaId;
    });
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordPotvrdaController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final password = _passwordController.text;
    final passwordPotvrda = _passwordPotvrdaController.text;

    if (_formKey.currentState!.validate()) {
      try {
        final request = KorisnikUpdateRequest(
          ime: _imeController.text,
          prezime: _prezimeController.text,
          brojTelefona: _telefonController.text,
          status: true,
          email: _emailController.text,
          password: password.isNotEmpty ? password : null,
          passwordPotvrda: passwordPotvrda.isNotEmpty ? passwordPotvrda : null,
          tipKorisnikaId: tipKorisnika,
        );

        bool updated = await ApiService.updateKorisnik(
          AuthProvider.userId!,
          request,
        );

        if (updated) {
          if (password.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lozinka promijenjena. Prijavite se ponovo.'),
              ),
            );
            AuthProvider.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil uspješno ažuriran')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri ažuriranju profila: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Profil korisnika",
      FutureBuilder<Korisnik>(
        future: _futureKorisnik,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Greška: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Korisnik nije pronađen.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    _imeController,
                    "Ime",
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Unesite ime';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _prezimeController,
                    "Prezime",
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Unesite prezime';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _usernameController,
                    "Korisničko ime",
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Unesite korisničko ime';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _emailController,
                    "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Unesite email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val))
                        return 'Neispravan email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _telefonController,
                    "Broj telefona",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    title: const Text("Promijeni lozinku"),
                    trailing: Icon(
                      _showPasswordFields
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onTap: () {
                      setState(() {
                        _showPasswordFields = !_showPasswordFields;
                      });
                    },
                  ),
                  if (_showPasswordFields) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      _passwordController,
                      "Nova lozinka",
                      obscureText: true,
                      validator: (val) {
                        if (_showPasswordFields &&
                            (val == null || val.length < 6)) {
                          return 'Lozinka mora imati najmanje 6 znakova';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordPotvrdaController,
                      "Potvrdi novu lozinku",
                      obscureText: true,
                      validator: (val) {
                        if (_showPasswordFields &&
                            val != _passwordController.text) {
                          return 'Lozinke se ne poklapaju';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Spremi promjene",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
