import 'dart:convert';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/model.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
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
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordPotvrdaController = TextEditingController();

  bool _showPasswordFields = false;
  bool _obscurePassword = true;
  bool _obscurePasswordPotvrda = true;
  String? _slikaBase64;
  int _tipKorisnika = 0;

  Future<KorisnikProfile>? _futureKorisnik;

  @override
  void initState() {
    super.initState();
    _futureKorisnik = ApiService.getKorisnikById(AuthProvider.userId!);
    _futureKorisnik!.then((k) {
      _imeController.text = k.ime;
      _prezimeController.text = k.prezime;
      _usernameController.text = k.username;
      _emailController.text = k.email;
      _telefonController.text = k.brojTelefona;
      _tipKorisnika = k.tipKorisnikaId;
      _slikaBase64 = k.slikaProfila;
    });
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _passwordController.dispose();
    _passwordPotvrdaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _slikaBase64 = base64Encode(bytes));
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final password = _passwordController.text;
    final passwordPotvrda = _passwordPotvrdaController.text;

    try {
      final request = KorisnikUpdateRequest(
        ime: _imeController.text,
        prezime: _prezimeController.text,
        brojTelefona: _telefonController.text,
        status: true,
        email: _emailController.text,
        password: password.isNotEmpty ? password : null,
        passwordPotvrda: passwordPotvrda.isNotEmpty ? passwordPotvrda : null,
        tipKorisnikaId: _tipKorisnika,
        slikaProfila: _slikaBase64,
      );

      final updated = await ApiService.updateKorisnik(
        AuthProvider.userId!,
        request,
      );

      if (!mounted) return;

      if (updated) {
        if (password.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lozinka promijenjena. Prijavite se ponovo.'),
              backgroundColor: AppTheme.success,
            ),
          );
          AuthProvider.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else {
          AuthProvider.setAuthInfo(
            username: AuthProvider.username!,
            password: AuthProvider.password!,
            id: AuthProvider.userId!,
            slika: _slikaBase64,
          );
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil uspješno ažuriran.'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Profil korisnika',
      FutureBuilder<KorisnikProfile>(
        future: _futureKorisnik,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Greška: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Podaci nisu pronađeni.'));
          }

          final korisnik = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header section with avatar
                _buildHeader(korisnik),

                // Form section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal info section
                        _SectionLabel(label: 'LIČNI PODACI'),
                        const SizedBox(height: 12),
                        _buildField(
                          _imeController,
                          'Ime',
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _prezimeController,
                          'Prezime',
                          Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _usernameController,
                          'Korisničko ime',
                          Icons.alternate_email,
                          readOnly: true,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _emailController,
                          'Email adresa',
                          Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          _telefonController,
                          'Broj telefona',
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 24),

                        // Password section
                        _SectionLabel(label: 'SIGURNOST'),
                        const SizedBox(height: 12),

                        // Toggle password
                        GestureDetector(
                          onTap:
                              () => setState(
                                () =>
                                    _showPasswordFields = !_showPasswordFields,
                              ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: const Border.fromBorderSide(
                                BorderSide(
                                  color: Color(0xFFe8e8e8),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Promijeni lozinku',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showPasswordFields
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showPasswordFields) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Nova lozinka',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordPotvrdaController,
                            obscureText: _obscurePasswordPotvrda,
                            validator: (v) {
                              if (_passwordController.text.isNotEmpty &&
                                  v != _passwordController.text) {
                                return 'Lozinke se ne podudaraju';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Potvrda lozinke',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordPotvrda
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscurePasswordPotvrda =
                                              !_obscurePasswordPotvrda,
                                    ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save_outlined, size: 20),
                            label: const Text('Spremi promjene'),
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(KorisnikProfile korisnik) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(gradient: AppTheme.drawerHeaderGradient),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      (_slikaBase64 != null && _slikaBase64!.isNotEmpty)
                          ? Image.memory(
                            base64Decode(_slikaBase64!),
                            fit: BoxFit.cover,
                          )
                          : Container(
                            color: AppTheme.primary.withOpacity(0.6),
                            child: Center(
                              child: Text(
                                korisnik.ime.isNotEmpty
                                    ? korisnik.ime[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${korisnik.ime} ${korisnik.prezime}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '@${korisnik.username}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(
        color: readOnly ? AppTheme.textMuted : AppTheme.textPrimary,
        fontSize: 15,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Polje ne smije biti prazno';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        fillColor: readOnly ? Colors.grey.shade50 : AppTheme.inputBackground,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}
