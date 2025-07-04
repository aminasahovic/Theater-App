import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'master_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int korisnikId;

  const ProfileScreen({super.key, required this.korisnikId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordPotvrdaController =
      TextEditingController();

  bool _showPasswordFields = false;
  String? _slikaBase64;
  int tipKorisnika = 0;

  Future<KorisnikProfile>? _futureKorisnik;

  @override
  void initState() {
    super.initState();
    _futureKorisnik = ApiService.getKorisnikById(AuthProvider.userId!);
    _futureKorisnik!.then((korisnik) {
      _imeController.text = korisnik.ime;
      _prezimeController.text = korisnik.prezime;
      _usernameController.text = korisnik.username;
      _emailController.text = korisnik.email;
      _telefonController.text = korisnik.brojTelefona;
      tipKorisnika = korisnik.tipKorisnikaId;
      _slikaBase64 = korisnik.slikaProfila;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _slikaBase64 = base64Encode(bytes);
      });
    }
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
          slikaProfila: _slikaBase64,
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
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          } else {
            AuthProvider.setAuthInfo(
              username: AuthProvider.username!,
              password: AuthProvider.password!,
              id: AuthProvider.userId!,
              slika: _slikaBase64,
            );

            setState(() {});

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Profil ažuriran.')));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Profil korisnika",
      FutureBuilder<KorisnikProfile>(
        future: _futureKorisnik,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Greška: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Podaci nisu pronađeni."));
          }

          final korisnik = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            (_slikaBase64 != null && _slikaBase64!.isNotEmpty)
                                ? MemoryImage(base64Decode(_slikaBase64!))
                                : null,
                        child:
                            (_slikaBase64 == null || _slikaBase64!.isEmpty)
                                ? Text(
                                  korisnik.ime[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_imeController, "Ime"),
                  const SizedBox(height: 16),
                  _buildTextField(_prezimeController, "Prezime"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _usernameController,
                    "Korisničko ime",
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _emailController,
                    "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _telefonController,
                    "Telefon",
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
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordPotvrdaController,
                      "Potvrda lozinke",
                      obscureText: true,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Spremi promjene"),
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 18),
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
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: (value) {
        if (label.contains("lozinka")) return null;
        if (value == null || value.isEmpty) return 'Polje ne smije biti prazno';
        return null;
      },
      decoration: InputDecoration(labelText: label),
    );
  }
}
