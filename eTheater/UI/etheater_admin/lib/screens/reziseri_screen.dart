import 'package:flutter/material.dart';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:etheater_admin/models/models.dart';

class ReziseriScreen extends StatefulWidget {
  const ReziseriScreen({super.key});

  @override
  State<ReziseriScreen> createState() => _ReziseriScreenState();
}

class _ReziseriScreenState extends State<ReziseriScreen> {
  final ApiService _apiService = ApiService();
  List<Reziser> _reziseri = [];
  int _currentPage = 1;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchReziseri();
  }

  void _fetchReziseri() async {
    try {
      final data = await _apiService.getReziseri(page: _currentPage);
      setState(() {
        _reziseri = data;
      });
    } catch (e) {
      print("Greška: $e");
    }
  }

  void _showReziserDialog({Reziser? reziser}) {
    final isEdit = reziser != null;
    final imeController = TextEditingController(text: reziser?.ime ?? '');
    final prezimeController = TextEditingController(
      text: reziser?.prezime ?? '',
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isEdit ? 'Uredi režisera' : 'Dodaj režisera'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: imeController,
                  decoration: const InputDecoration(labelText: 'Ime'),
                ),
                TextField(
                  controller: prezimeController,
                  decoration: const InputDecoration(labelText: 'Prezime'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Odustani'),
              ),
              TextButton(
                onPressed: () async {
                  final ime = imeController.text.trim();
                  final prezime = prezimeController.text.trim();

                  if (ime.isEmpty || prezime.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ime i prezime su obavezni.'),
                      ),
                    );
                    return;
                  }

                  final novi = InsertReziser(ime: ime, prezime: prezime);

                  try {
                    if (isEdit) {
                      await _apiService.updateReziser(reziser!.id, novi);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Režiser uspješno ažuriran!'),
                        ),
                      );
                    } else {
                      await _apiService.dodajRezisera(novi);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Režiser uspješno dodat!'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                    _fetchReziseri();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Greška: $e')));
                  }
                },
                child: const Text('Spremi'),
              ),
            ],
          ),
    );
  }

  void _obrisiRezisera(int id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Potvrda'),
            content: const Text('Da li želite obrisati ovog režisera?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Otkaži'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _apiService.obrisiRezisera(id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Režiser uspješno obrisan!'),
                      ),
                    );
                    _fetchReziseri();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Greška: $e')));
                  }
                },
                child: const Text('Obriši'),
              ),
            ],
          ),
    );
  }

  set searchTerm(String value) {
    setState(() {
      _search = value.toLowerCase();
      _currentPage = 1;
    });
    _fetchReziseri();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Režiseri',
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Pretraži po imenu ili prezimenu',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => searchTerm = value,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showReziserDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj režisera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Ime')),
                    DataColumn(label: Text('Prezime')),
                    DataColumn(label: Text('Akcije')),
                  ],
                  rows:
                      _reziseri.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text('${r.id}')),
                            DataCell(Text(r.ime)),
                            DataCell(Text(r.prezime)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => _showReziserDialog(reziser: r),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _obrisiRezisera(r.id),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
