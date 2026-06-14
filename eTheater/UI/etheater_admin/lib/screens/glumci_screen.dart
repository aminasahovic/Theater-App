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
  int _pageSize = 5;
  int _totalCount = 0;

  final imeController = TextEditingController();
  final prezimeController = TextEditingController();
  String base64Slika = '';
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    _fetchGlumci();
  }

  void _fetchGlumci() async {
    try {
      final result = await _apiService.getGlumci(
        page: _currentPage,
        pageSize: _pageSize,
        imePrezime: _searchQuery,
      );

      setState(() {
        _glumci = result.resultList; // Uzmi listu glumaca
        _totalCount = result.count; // Ukupan broj glumaca
      });
    } catch (e) {
      print('Greška prilikom dohvaćanja glumaca: $e');
    }
  }

  Future<void> _showGlumacDialog({Glumac? glumac}) async {
    final isEditMode = glumac != null;
    imeController.text = glumac?.ime ?? '';
    prezimeController.text = glumac?.prezime ?? '';
    base64Slika = glumac?.slika ?? '';
    final _imagePicker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void _localValidateForm() {
              final ime = imeController.text;
              final prezime = prezimeController.text;

              final isImeValid =
                  ime.isNotEmpty &&
                  ime[0] == ime[0].toUpperCase() &&
                  !RegExp(r'\d').hasMatch(ime);

              final isPrezimeValid =
                  prezime.isNotEmpty &&
                  prezime[0] == prezime[0].toUpperCase() &&
                  !RegExp(r'\d').hasMatch(prezime);

              final formValid = isImeValid && isPrezimeValid;

              setDialogState(() {
                isFormValid = formValid;
              });
            }

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
                          setDialogState(() {});
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
                      onChanged: (_) => _localValidateForm(),
                    ),
                    TextField(
                      controller: prezimeController,
                      decoration: const InputDecoration(labelText: 'Prezime'),
                      onChanged: (_) => _localValidateForm(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Odustani'),
                ),
                TextButton(
                  onPressed:
                      isFormValid
                          ? () async {
                            final glumacData = InsertGlumac(
                              ime: imeController.text,
                              prezime: prezimeController.text,
                              slika: base64Slika,
                            );
                            if (isEditMode) {
                              await ApiService.updateGlumac(
                                glumac.id,
                                glumacData,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Glumac uspješno ažuriran!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              await ApiService.dodajGlumca(glumacData);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Glumac uspješno dodan!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            Navigator.pop(context);
                            _fetchGlumci();
                          }
                          : null,
                  child: Text(isEditMode ? 'Spremi' : 'Dodaj'),
                ),
              ],
            );
          },
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
              onPressed: () => Navigator.pop(context),
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

  Widget _buildPaginationControls() {
    int ukupnoStranica = (_totalCount / _pageSize).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              _currentPage > 1
                  ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _fetchGlumci();
                  }
                  : null,
          child: const Text('Prethodna'),
        ),
        const SizedBox(width: 16),
        Text('Stranica $_currentPage od $ukupnoStranica'),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed:
              _currentPage < ukupnoStranica
                  ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _fetchGlumci();
                  }
                  : null,
          child: const Text('Sljedeća'),
        ),
      ],
    );
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
                    decoration: InputDecoration(
                      hintText: 'Pretraži po imenu ili prezimenu...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF800020),
                          width: 1.4,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                      });
                      _fetchGlumci();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _showGlumacDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj glumca"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    itemCount: _glumci.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final glumac = _glumci[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200]?.withOpacity(0.5),
                                  ),
                                  child:
                                      glumac.slika.isNotEmpty
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.memory(
                                              base64Decode(glumac.slika),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                          : const Center(
                                            child: Icon(
                                              Icons.person_off,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
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
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed:
                                        () => _showGlumacDialog(glumac: glumac),
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Uredi'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      textStyle: const TextStyle(fontSize: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _deleteGlumac(glumac.id),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Obriši'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      textStyle: const TextStyle(fontSize: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}
