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
      title: const Text('Dodaj korisnika'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Ime'),
                        onChanged: (val) => ime = val,
                        validator: (val) {
                          if (val!.isEmpty) return 'Unesite ime';
                          if (!RegExp(r'^[A-ZŽ][a-zž]+$').hasMatch(val))
                            return 'Ime mora početi velikim slovom i ne smije sadržavati brojeve';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Prezime'),
                        onChanged: (val) => prezime = val,
                        validator: (val) {
                          if (val!.isEmpty) return 'Unesite prezime';
                          if (!RegExp(r'^[A-ZŽ][a-zž]+$').hasMatch(val))
                            return 'Prezime mora početi velikim slovom i ne smije sadržavati brojeve';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (val) => username = val,
                  validator: (val) => val!.isEmpty ? 'Unesite username' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator:
                      (val) => val!.length < 4 ? 'Min 4 karaktera' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Potvrdi password',
                  ),
                  obscureText: true,
                  onChanged: (val) => passwordPotvrda = val,
                  validator:
                      (val) =>
                          val != password ? 'Passwordi se ne poklapaju' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Broj telefona'),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => brojTelefona = val,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator:
                      (val) => val!.isEmpty ? 'Unesite broj telefona' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (val) => email = val,
                  validator: (val) {
                    if (val!.isEmpty) return 'Unesite email';
                    if (!RegExp(
                      r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                    ).hasMatch(val)) {
                      return 'Unesite validan email';
                    }
                    return null;
                  },
                ),
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
                  decoration: const InputDecoration(labelText: 'Tip korisnika'),
                  validator:
                      (val) => val == null ? 'Odaberite tip korisnika' : null,
                ),
                SwitchListTile(
                  title: const Text('Aktivan'),
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Otkaži"),
        ),
        ElevatedButton(
          onPressed: _dodajKorisnika,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800020),
          ),
          child: const Text("Dodaj"),
        ),
      ],
    );
  }
}
