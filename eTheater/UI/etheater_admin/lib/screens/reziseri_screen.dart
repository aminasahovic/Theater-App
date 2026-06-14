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
  bool _hasNextPage = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchReziseri();
  }

  void _fetchReziseri() async {
    try {
      final data = await _apiService.getReziseri(
        page: _currentPage,
        search: _search,
      );
      setState(() {
        _reziseri = data;
        _hasNextPage = data.length == 10;
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
    final isFormValid = ValueNotifier<bool>(false);

    bool validateImePrezime(String ime, String prezime) {
      final regex = RegExp(r"^[A-ZŠĐŽČĆ][a-zšđžčć]+$");
      return regex.hasMatch(ime) && regex.hasMatch(prezime);
    }

    void onFormChanged() {
      final ime = imeController.text.trim();
      final prezime = prezimeController.text.trim();
      isFormValid.value = validateImePrezime(ime, prezime);
    }

    imeController.addListener(onFormChanged);
    prezimeController.addListener(onFormChanged);

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
                  decoration: const InputDecoration(
                    labelText: 'Ime',
                    hintText: 'Npr. Marko',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: prezimeController,
                  decoration: const InputDecoration(
                    labelText: 'Prezime',
                    hintText: 'Npr. Popović',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Odustani'),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isFormValid,
                builder: (context, isValid, _) {
                  return TextButton(
                    onPressed:
                        isValid
                            ? () async {
                              final ime = imeController.text.trim();
                              final prezime = prezimeController.text.trim();
                              final novi = InsertReziser(
                                ime: ime,
                                prezime: prezime,
                              );

                              try {
                                if (isEdit) {
                                  await _apiService.updateReziser(
                                    reziser!.id,
                                    novi,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Režiser uspješno ažuriran!',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  await _apiService.dodajRezisera(novi);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Režiser uspješno dodan!'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                                Navigator.pop(context);
                                _fetchReziseri();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Greška: $e')),
                                );
                              }
                            }
                            : null,
                    child: const Text('Spremi'),
                  );
                },
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
            title: const Text('Potvrda brisanja'),
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
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
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
                    decoration: InputDecoration(
                      labelText: 'Pretraži po imenu ili prezimenu',
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
                    onChanged: (value) => searchTerm = value,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showReziserDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj režisera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _reziseri.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final reziser = _reziseri[index];
                  return Card(
                    color: Colors.white, // potpuno bijela kartica
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                '${reziser.ime} ${reziser.prezime}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Uredi'),
                                onPressed:
                                    () => _showReziserDialog(reziser: reziser),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Obriši'),
                                onPressed: () => _obrisiRezisera(reziser.id),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
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
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed:
                      _currentPage > 1
                          ? () {
                            setState(() => _currentPage--);
                            _fetchReziseri();
                          }
                          : null,
                  child: const Text('Prethodna'),
                ),
                const SizedBox(width: 8),
                Text('Stranica $_currentPage'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:
                      _hasNextPage
                          ? () {
                            setState(() => _currentPage++);
                            _fetchReziseri();
                          }
                          : null,
                  child: const Text('Sljedeća'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
