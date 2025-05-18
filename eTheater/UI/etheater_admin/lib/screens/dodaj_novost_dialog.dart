import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:file_picker/file_picker.dart';

class DodajNovostDialog extends StatefulWidget {
  const DodajNovostDialog({super.key});

  @override
  State<DodajNovostDialog> createState() => _DodajNovostDialogState();
}

class _DodajNovostDialogState extends State<DodajNovostDialog> {
  final _formKey = GlobalKey<FormState>();
  String naslov = '';
  String sadrzaj = '';
  DateTime datumObjave = DateTime.now();
  String base64Slika = '';
  Uint8List? _slikaBytes;
  bool _uspjesnoDodano = false;

  // Poziv na instancu ApiService klase
  Future<int?> _getKorisnikId() async {
    // Kreiranje instance ApiService
    final apiService = ApiService();
    final korisnik =
        await apiService.getLogovaniKorisnik(); // Poziv na instancu metode
    return korisnik?.id; // Pretpostavljamo da 'id' postoji u Korisnik modelu
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj novu novost'),
      content: SizedBox(
        width: 800,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[200],
                ),
                child:
                    _slikaBytes != null
                        ? Image.memory(
                          _slikaBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : const Center(child: Text('Nema slike')),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.image);
                  if (result != null) {
                    final file = result.files.first;
                    final bytes =
                        file.bytes ?? await File(file.path!).readAsBytes();
                    setState(() {
                      _slikaBytes = bytes;
                      base64Slika = base64Encode(bytes);
                    });
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text('Odaberi sliku'),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Naslov'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Unesite naslov'
                                  : null,
                      onSaved: (value) => naslov = value!,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Sadržaj'),
                      maxLines: 4,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Unesite sadržaj'
                                  : null,
                      onSaved: (value) => sadrzaj = value!,
                    ),
                    const SizedBox(height: 16),
                    if (_uspjesnoDodano)
                      const Text(
                        'Novost uspješno dodana!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
              final korisnikId = await _getKorisnikId();
              if (korisnikId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nije moguće dohvatiti korisnika'),
                  ),
                );
                return;
              }

              final novaNovost = InsertNovosti(
                korisnikId: korisnikId,
                naslov: naslov,
                sadrzaj: sadrzaj,
                datumObjave: DateTime.now(),
                slika: base64Slika,
              );

              try {
                await ApiService.dodajNovost(novaNovost);
                setState(() {
                  _uspjesnoDodano = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Novost uspješno dodana.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Došlo je do greške: $e'),
                    backgroundColor: Colors.black87,
                  ),
                );
              }
            }
          },
          child: const Text('Spremi'),
        ),
      ],
    );
  }
}
