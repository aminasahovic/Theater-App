import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart' show ApiService;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DodajKorisnikaDialog extends StatefulWidget {
  final VoidCallback onKorisnikDodan;

  const DodajKorisnikaDialog({super.key, required this.onKorisnikDodan});

  @override
  State<DodajKorisnikaDialog> createState() => _DodajKorisnikaDialogState();
}

class _DodajKorisnikaDialogState extends State<DodajKorisnikaDialog> {
  final _formKey = GlobalKey<FormState>();
  String ime = '';
  String prezime = '';
  String username = '';
  String password = '';
  String passwordPotvrda = '';
  String brojTelefona = '';
  String email = '';
  bool isActive = true;
  TipKorisnika? selectedTip;
  List<TipKorisnika> tipovi = [];

  @override
  void initState() {
    super.initState();
    _fetchTipove();
  }

  Future<void> _fetchTipove() async {
    tipovi = await ApiService().getTipoviKorisnika();
    setState(() {});
  }

  void _dodajKorisnika() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Molimo odaberite tip korisnika")),
      );
      return;
    }

    final korisnik = KorisniciInsert(
      ime: ime,
      prezime: prezime,
      username: username,
      password: password,
      passwordPotvrda: passwordPotvrda,
      brojTelefona: brojTelefona,
      email: email,
      isActive: isActive,
      tipKorisnikaId: selectedTip?.id,
    );

    try {
      await ApiService.dodajKorisnika(korisnik);
      widget.onKorisnikDodan();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Korisnik uspješno dodan"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom dodavanja: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Dodaj korisnika',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Ime', (v) => ime = v, (v) {
                        if (v!.isEmpty) return 'Unesite ime';
                        if (!RegExp(r"^[A-ZČĆŽŠĐ][a-zčćžšđ]+$").hasMatch(v)) {
                          return 'Počnite velikim slovom';
                        }
                        return null;
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField('Prezime', (v) => prezime = v, (
                        v,
                      ) {
                        if (v!.isEmpty) return 'Unesite prezime';
                        if (!RegExp(r"^[A-ZČĆŽŠĐ][a-zčćžšđ]+$").hasMatch(v)) {
                          return 'Počnite velikim slovom';
                        }
                        return null;
                      }),
                    ),
                  ],
                ),
                _buildTextField(
                  'Username',
                  (v) => username = v,
                  (v) => v!.isEmpty ? 'Unesite username' : null,
                ),
                _buildTextField(
                  'Password',
                  (v) => password = v,
                  (v) => v!.length < 4 ? 'Min 4 karaktera' : null,
                  obscure: true,
                ),
                _buildTextField(
                  'Potvrdi password',
                  (v) => passwordPotvrda = v,
                  (v) => v != password ? 'Passwordi se ne poklapaju' : null,
                  obscure: true,
                ),
                _buildTextField(
                  'Broj telefona',
                  (v) => brojTelefona = v,
                  (v) => v!.isEmpty ? 'Unesite broj telefona' : null,
                  keyboard: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildTextField('Email', (v) => email = v, (v) {
                  if (v!.isEmpty) return 'Unesite email';
                  if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)) {
                    return 'Neispravan email';
                  }
                  return null;
                }),
                const SizedBox(height: 10),
                DropdownButtonFormField<TipKorisnika>(
                  value: selectedTip,
                  items:
                      tipovi
                          .map(
                            (tip) => DropdownMenuItem(
                              value: tip,
                              child: Text(tip.naziv),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => selectedTip = val),
                  decoration: _fieldDecoration('Tip korisnika'),
                  validator:
                      (val) => val == null ? 'Odaberite tip korisnika' : null,
                ),
                SwitchListTile(
                  title: const Text('Aktivan'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                  contentPadding: EdgeInsets.zero,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: const Text("Otkaži"),
        ),
        FilledButton.icon(
          onPressed: _dodajKorisnika,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text("Dodaj"),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF7F7F7),
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );

  Widget _buildTextField(
    String label,
    Function(String) onChanged,
    String? Function(String?) validator, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        obscureText: obscure,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        validator: validator,
        decoration: _fieldDecoration(label),
      ),
    );
  }
}
