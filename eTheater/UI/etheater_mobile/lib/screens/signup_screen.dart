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
      appBar: AppBar(
        title: const Text('Registracija'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ime',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => _validateName(v, 'Ime'),
                  onChanged: (v) => ime = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Prezime',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => _validateName(v, 'Prezime'),
                  onChanged: (v) => prezime = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Korisničko ime',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.isEmpty)
                              ? 'Unesite korisničko ime'
                              : null,
                  onChanged: (v) => username = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Lozinka',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: _validatePassword,
                  onChanged: (v) => password = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Potvrda lozinke',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator:
                      (v) =>
                          (v == null || v.isEmpty) ? 'Potvrdite lozinku' : null,
                  onChanged: (v) => passwordPotvrda = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator:
                      (v) =>
                          (v == null || !v.contains('@'))
                              ? 'Unesite validan email'
                              : null,
                  onChanged: (v) => email = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Broj telefona',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                  validator: _validatePhone,
                  onChanged: (v) => brojTelefona = v,
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Registruj se'),
                    ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
