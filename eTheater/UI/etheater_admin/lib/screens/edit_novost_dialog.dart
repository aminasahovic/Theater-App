import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EditNovostDialog extends StatefulWidget {
  final Obavijest novost;

  const EditNovostDialog({super.key, required this.novost});

  @override
  State<EditNovostDialog> createState() => _EditNovostDialogState();
}

class _EditNovostDialogState extends State<EditNovostDialog> {
  final _formKey = GlobalKey<FormState>();
  late String naslov;
  late String sadrzaj;
  String base64Slika = '';
  Uint8List? _slikaBytes;

  @override
  void initState() {
    super.initState();
    naslov = widget.novost.naslov;
    sadrzaj = widget.novost.sadrzaj;
    base64Slika = widget.novost.slika ?? '';
    if (base64Slika.isNotEmpty) {
      _slikaBytes = base64Decode(base64Slika);
    }
  }

  Future<int?> _getKorisnikId() async {
    final korisnik = await ApiService().getLogovaniKorisnik();
    return korisnik?.id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Uredi novost',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 800,
        height: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Slika
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      _slikaBytes != null
                          ? Image.memory(
                            _slikaBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                          : const Center(child: Text('Nema slike')),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
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
                icon: const Icon(Icons.image, color: Colors.black87),
                label: const Text(
                  'Odaberi sliku',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: naslov,
                      decoration: const InputDecoration(labelText: 'Naslov'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Unesite naslov'
                                  : null,
                      onSaved: (value) => naslov = value!,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: sadrzaj,
                      decoration: const InputDecoration(labelText: 'Sadržaj'),
                      maxLines: 4,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Unesite sadržaj'
                                  : null,
                      onSaved: (value) => sadrzaj = value!,
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Otkaži'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(fontSize: 14),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final korisnikId = await _getKorisnikId();
              if (korisnikId == null) return;

              final updateModel = UpdateNovosti(
                korisnikId: widget.novost.korisnikId,
                naslov: naslov,
                sadrzaj: sadrzaj,
                datumObjave: widget.novost.datumObjave,
                slika: base64Slika,
                datumUredjivanja: DateTime.now(),
                modifyBy: korisnikId,
              );

              try {
                await ApiService.updateNovost(widget.novost.id, updateModel);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Novost uspješno ažurirana!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Greška: $e')));
                }
              }
            }
          },
          child: const Text('Spremi izmjene'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
