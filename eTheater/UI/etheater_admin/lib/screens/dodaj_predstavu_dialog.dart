import 'dart:convert';
import 'dart:typed_data';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DodajPredstavuDialog extends StatefulWidget {
  const DodajPredstavuDialog({super.key});

  @override
  State<DodajPredstavuDialog> createState() => _DodajPredstavuDialogState();
}

class _DodajPredstavuDialogState extends State<DodajPredstavuDialog> {
  final _formKey = GlobalKey<FormState>();
  String naziv = '';
  String opis = '';
  int trajanje = 0;
  int godina = 0;
  bool isActive = true;
  Zanr? odabraniZanr;
  Reziser? odabraniReziser;
  String base64Slika = '';

  List<Zanr> zanrovi = [];
  List<Reziser> reziseri = [];

  @override
  void initState() {
    super.initState();
    _ucitajPodatke();
  }

  Future<void> _ucitajPodatke() async {
    zanrovi = await ApiService.fetchZanrovi();
    reziseri = await ApiService.fetchReziseri();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj novu predstavu'),
      content: SizedBox(
        width: 500, // širi popup
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Naziv'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Unesite naziv'
                              : null,
                  onSaved: (value) => naziv = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Trajanje (min)',
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value == null || int.tryParse(value) == null
                              ? 'Unesite broj'
                              : null,
                  onSaved: (value) => trajanje = int.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Godina'),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value == null || int.tryParse(value) == null
                              ? 'Unesite godinu'
                              : null,
                  onSaved: (value) => godina = int.parse(value!),
                ),
                DropdownButtonFormField<Zanr>(
                  items:
                      zanrovi
                          .map(
                            (z) => DropdownMenuItem(
                              value: z,
                              child: Text(z.naziv),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => odabraniZanr = value,
                  validator: (value) => value == null ? 'Izaberite žanr' : null,
                  decoration: const InputDecoration(labelText: 'Žanr'),
                ),
                DropdownButtonFormField<Reziser>(
                  items:
                      reziseri
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text('${r.ime} ${r.prezime}'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => odabraniReziser = value,
                  validator:
                      (value) => value == null ? 'Izaberite režisera' : null,
                  decoration: const InputDecoration(labelText: 'Režiser'),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Opis'),
                  maxLines: 5,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Unesite opis'
                              : null,
                  onSaved: (value) => opis = value!,
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null) {
                      Uint8List fileBytes = result.files.first.bytes!;
                      base64Slika = base64Encode(fileBytes);
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Odaberi sliku'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Otkaži'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              final nova = PredstavaInsert(
                naziv: naziv,
                opis: opis,
                trajanje: trajanje,
                godina: godina,
                plakat: base64Slika,
                isActive: isActive,
                zanrId: odabraniZanr!.id,
                reziserId: odabraniReziser!.id,
              );

              await ApiService.dodajPredstavu(nova);
              Navigator.pop(context, true);
            }
          },
          child: const Text('Spremi'),
        ),
      ],
    );
  }
}
