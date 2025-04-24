import 'dart:convert';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GlumciScreen extends StatefulWidget {
  const GlumciScreen({super.key});

  @override
  State<GlumciScreen> createState() => _GlumciScreenState();
}

class _GlumciScreenState extends State<GlumciScreen> {
  final ApiService _apiService = ApiService();
  List<Glumac> _glumci = [];
  String _searchQuery = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchGlumci();
  }

  void _fetchGlumci() async {
    try {
      final glumci = await _apiService.getGlumci(page: _currentPage);
      setState(() {
        _glumci =
            glumci.where((g) {
              final imePrezime = '${g.ime} ${g.prezime}'.toLowerCase();
              return imePrezime.contains(_searchQuery.toLowerCase());
            }).toList();
      });
    } catch (e) {
      print('Error fetching glumci: $e');
    }
  }

  Future<void> _showGlumacDialog({Glumac? glumac}) async {
    final isEditMode = glumac != null;
    final imeController = TextEditingController(text: glumac?.ime ?? '');
    final prezimeController = TextEditingController(
      text: glumac?.prezime ?? '',
    );
    String base64Slika = glumac?.slika ?? '';
    final _imagePicker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditMode ? 'Uredi Glumca' : 'Dodaj Glumca'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes();
                      base64Slika = base64Encode(bytes);
                      setState(() {});
                    }
                  },
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        base64Slika.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(base64Slika),
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Center(
                              child: Icon(Icons.person_add, size: 50),
                            ),
                  ),
                ),
                const SizedBox(height: 10),
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Odustani'),
            ),
            TextButton(
              onPressed: () async {
                final glumacData = InsertGlumac(
                  ime: imeController.text,
                  prezime: prezimeController.text,
                  slika: base64Slika,
                );
                if (isEditMode) {
                  await ApiService.updateGlumac(glumac!.id!, glumacData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Glumac uspješno ažuriran!')),
                  );
                } else {
                  await ApiService.dodajGlumca(glumacData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Glumac uspješno dodan!')),
                  );
                }
                Navigator.pop(context);
                _fetchGlumci();
              },
              child: Text(isEditMode ? 'Spremi' : 'Dodaj'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGlumac(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Potvrda Brisanja'),
          content: const Text(
            'Da li ste sigurni da želite obrisati ovog glumca?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.deleteGlumac(id);
                Navigator.pop(context);
                _fetchGlumci();
              },
              child: const Text('Obriši'),
            ),
          ],
        );
      },
    );
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
    _fetchGlumci();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Glumci',
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Pretraži po imenu ili prezimenu...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _fetchGlumci();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    _showGlumacDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj glumca"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _glumci.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final glumac = _glumci[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 350,
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child:
                                glumac.slika != null &&
                                        glumac.slika!.isNotEmpty &&
                                        glumac.slika != "string"
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(glumac.slika!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Center(
                                      child: Icon(Icons.person_off, size: 40),
                                    ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${glumac.ime} ${glumac.prezime}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showGlumacDialog(glumac: glumac);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteGlumac(glumac.id!);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      _currentPage > 1
                          ? () => _changePage(_currentPage - 1)
                          : null,
                ),
                Text('Stranica $_currentPage'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _changePage(_currentPage + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
