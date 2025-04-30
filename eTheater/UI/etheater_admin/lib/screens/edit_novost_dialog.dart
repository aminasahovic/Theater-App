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
      title: const Text('Uredi novost'),
      content: SizedBox(
        width: 800,
        height: 500,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child:
                        _slikaBytes != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                _slikaBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Center(child: Text('Nema slike')),
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
                    icon: const Icon(Icons.image),
                    label: const Text('Promijeni sliku'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 7,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
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
                      const SizedBox(height: 10),
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
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Otkaži'),
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
                await ApiService.updateNovost(widget.novost.id!, updateModel);
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Greška: $e')));
              }
            }
          },
          child: const Text('Spremi izmjene'),
        ),
      ],
    );
  }
}
