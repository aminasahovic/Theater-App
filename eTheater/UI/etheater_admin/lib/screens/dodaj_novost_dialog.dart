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

  Future<int?> _getKorisnikId() async {
    final apiService = ApiService();
    final korisnik = await apiService.getLogovaniKorisnik();
    return korisnik?.id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Dodaj novu novost',
        style: TextStyle(
          fontWeight: FontWeight.w500, // srednja težina, manje napadno
          fontSize: 18, // smanjen font
          color: Colors.black87, // neutralnija boja
        ),
      ),

      content: SizedBox(
        width: 800,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Slika
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                clipBehavior: Clip.hardEdge,
                child:
                    _slikaBytes != null
                        ? Image.memory(
                          _slikaBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.image, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Nema odabrane slike',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
              ),
              const SizedBox(height: 12),
              // Dugme za upload slike
              OutlinedButton.icon(
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
                icon: const Icon(Icons.upload_file),
                label: const Text("Odaberi sliku"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.blueGrey),
                ),
              ),
              const SizedBox(height: 24),
              // Forma
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Naslov',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Unesite naslov'
                                  : null,
                      onSaved: (value) => naslov = value!,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Sadržaj',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
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
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Otkaži'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ElevatedButton.icon(
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
          icon: const Icon(Icons.save),
          label: const Text('Spremi'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
