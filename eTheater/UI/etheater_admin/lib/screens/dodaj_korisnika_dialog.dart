import 'dart:convert';
import 'dart:io';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart' show ApiService;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
  bool isActive = true;
  TipKorisnika? selectedTip;
  List<TipKorisnika> tipovi = [];
  String? base64Slika;

  @override
  void initState() {
    super.initState();
    _fetchTipove();
  }

  Future<void> _fetchTipove() async {
    tipovi = await ApiService().getTipoviKorisnika();
    setState(() {});
  }

  Future<void> _odaberiSliku() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final bytes = File(result.files.single.path!).readAsBytesSync();
      base64Slika = base64Encode(bytes);
      setState(() {});
    }
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
      isActive: isActive,
      tipKorisnikaId: selectedTip?.id,
      slika: base64Slika,
    );

    try {
      await ApiService.dodajKorisnika(korisnik);
      print(korisnik.tipKorisnikaId);
      widget.onKorisnikDodan();
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Korisnik uspješno dodat")));
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
                        validator: (val) => val!.isEmpty ? 'Unesite ime' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Prezime'),
                        onChanged: (val) => prezime = val,
                        validator:
                            (val) => val!.isEmpty ? 'Unesite prezime' : null,
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
                  onChanged: (val) => brojTelefona = val,
                  validator: (val) => val!.isEmpty ? 'Unesite broj' : null,
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
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _odaberiSliku,
                  icon: const Icon(Icons.image),
                  label: const Text("Dodaj sliku"),
                ),
                if (base64Slika != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.memory(
                      base64Decode(base64Slika!),
                      height: 100,
                      fit: BoxFit.cover,
                    ),
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
