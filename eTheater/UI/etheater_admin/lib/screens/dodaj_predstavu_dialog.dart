import 'dart:convert';
import 'dart:io';
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
  Uint8List? _slikaBytes;

  List<Zanr> zanrovi = [];
  List<Reziser> reziseri = [];
  List<Glumac> glumci = [];
  List<Glumac> odabraniGlumci = [];
  Map<int, String> ulogePoGlumcu = {};

  bool _uspjesnoDodano = false;

  @override
  void initState() {
    super.initState();
    _ucitajPodatke();
  }

  Future<void> _ucitajPodatke() async {
    zanrovi = await ApiService.fetchZanrovi();
    reziseri = await ApiService.fetchReziseri();
    glumci = await ApiService.fetchGlumci();
    setState(() {});
  }

  String? _validirajNaziv(String? value) {
    if (value == null || value.isEmpty) return 'Unesite naziv';
    if (!RegExp(r'^[A-ZČĆŽŠĐ]').hasMatch(value)) {
      return 'Naziv mora početi velikim slovom';
    }
    return null;
  }

  String? _validirajGodinu(String? value) {
    if (value == null || value.isEmpty) return 'Unesite godinu';
    final broj = int.tryParse(value);
    if (broj == null || value.length != 4) return 'Unesite ispravnu godinu';
    return null;
  }

  String? _validirajBroj(String? value) {
    if (value == null || int.tryParse(value) == null) return 'Unesite broj';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj novu predstavu'),
      content: SizedBox(
        width: 800,
        height: 500,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  if (_slikaBytes != null)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Image.memory(
                        _slikaBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.grey[200],
                      ),
                      child: const Center(child: Text('Nema slike')),
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
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Desna sekcija - forma
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Naziv'),
                        validator: _validirajNaziv,
                        onSaved: (value) => naziv = value!,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Trajanje (min)',
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validirajBroj,
                        onSaved: (value) => trajanje = int.parse(value!),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Godina'),
                        keyboardType: TextInputType.number,
                        validator: _validirajGodinu,
                        onSaved: (value) => godina = int.parse(value!),
                      ),
                      const SizedBox(height: 10),
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
                        validator:
                            (value) => value == null ? 'Izaberite žanr' : null,
                        decoration: const InputDecoration(labelText: 'Žanr'),
                      ),
                      const SizedBox(height: 10),
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
                            (value) =>
                                value == null ? 'Izaberite režisera' : null,
                        decoration: const InputDecoration(labelText: 'Režiser'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<Glumac>(
                        decoration: const InputDecoration(
                          labelText: 'Dodaj glumca',
                        ),
                        items:
                            glumci
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text('${g.ime} ${g.prezime}'),
                                  ),
                                )
                                .toList(),
                        onChanged: (glumac) {
                          if (glumac != null &&
                              !odabraniGlumci.contains(glumac)) {
                            setState(() {
                              odabraniGlumci.add(glumac);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ...odabraniGlumci.map(
                        (glumac) => Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText:
                                      'Uloga za ${glumac.ime} ${glumac.prezime}',
                                ),
                                onChanged:
                                    (value) => ulogePoGlumcu[glumac.id] = value,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  odabraniGlumci.remove(glumac);
                                  ulogePoGlumcu.remove(glumac.id);
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Opis'),
                        maxLines: 4,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Unesite opis'
                                    : null,
                        onSaved: (value) => opis = value!,
                      ),
                      const SizedBox(height: 16),
                      if (_uspjesnoDodano)
                        const Text(
                          'Predstava uspješno dodana!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
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
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Otkaži'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              try {
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

                final predstavaId = await ApiService.dodajPredstavu(nova);

                for (final glumac in odabraniGlumci) {
                  final uloga = ulogePoGlumcu[glumac.id] ?? '';
                  final glumacPredstava = GlumacPredstavaInsert(
                    glumacId: glumac.id,
                    predstavaId: predstavaId,
                    uloga: uloga,
                  );
                  await ApiService.dodajGlumcaPredstavi(glumacPredstava);
                }

                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Predstava uspješno dodana!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Greška pri dodavanju predstave: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            }
          },

          child: const Text('Spremi'),
        ),
      ],
    );
  }
}
