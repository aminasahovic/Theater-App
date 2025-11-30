import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String ime = '';
  String prezime = '';
  String username = '';
  String password = '';
  String passwordPotvrda = '';
  String email = '';
  String brojTelefona = '';

  bool _isLoading = false;
  String? _errorMessage;

  final _nameRegex = RegExp(r'^[A-Z][a-zA-Z]*$');
  final _phoneRegex = RegExp(r'^\+?[0-9]{6,}$');

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (password != passwordPotvrda) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Lozinka i potvrda lozinke se ne poklapaju.";
      });
      return;
    }
    var user = InsertKorisnik(
      ime: ime,
      prezime: prezime,
      username: username,
      password: password,
      passwordPotvrda: passwordPotvrda,
      email: email,
      brojTelefona: brojTelefona,
      tipKorisnikaId: 3,
      isActive: true,
    );

    var success = await ApiService.registrujKorisnika(user);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Uspješno'),
              content: const Text(
                'Registracija uspješna! Možete se sada prijaviti.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } else {
      setState(() {
        _errorMessage = 'Registracija nije uspjela. Pokušajte ponovo.';
      });
    }
  }

  String? _validateName(String? v, String fieldName) {
    if (v == null || v.isEmpty) return 'Unesite $fieldName';
    if (!_nameRegex.hasMatch(v)) {
      return '$fieldName mora počinjati velikim slovom i ne smije sadržavati brojeve ili specijalne znakove';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.length < 4) {
      return 'Lozinka mora imati najmanje 4 karaktera';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Unesite broj telefona';
    if (!_phoneRegex.hasMatch(v)) {
      return 'Broj telefona nije validan (samo cifre i opcionalno + na početku, minimalno 6 cifara)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
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
                        const Text(
                          'Registracija',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'Ime',
                          icon: Icons.person,
                          onChanged: (v) => ime = v,
                          validator: (v) => _validateName(v, 'Ime'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Prezime',
                          icon: Icons.person_outline,
                          onChanged: (v) => prezime = v,
                          validator: (v) => _validateName(v, 'Prezime'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Korisničko ime',
                          icon: Icons.account_circle,
                          onChanged: (v) => username = v,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Unesite korisničko ime'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Lozinka',
                          icon: Icons.lock,
                          obscureText: true,
                          onChanged: (v) => password = v,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Potvrda lozinke',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          onChanged: (v) => passwordPotvrda = v,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Potvrdite lozinku'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Email',
                          icon: Icons.email,
                          onChanged: (v) => email = v,
                          validator:
                              (v) =>
                                  (v == null || !v.contains('@'))
                                      ? 'Unesite validan email'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: 'Broj telefona',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+]'),
                            ),
                          ],
                          onChanged: (v) => brojTelefona = v,
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
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
                            onPressed: _isLoading ? null : _submit,
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Registruj se',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade200.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
