import 'dart:convert';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/providers/auth_providers.dart';
import 'package:etheater_admin/screens/dodaj_novost_dialog.dart';
import 'package:etheater_admin/screens/edit_novost_dialog.dart';
import 'package:etheater_admin/screens/novosti_details.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:etheater_admin/layouts/master_screen.dart';

class NovostiScreen extends StatefulWidget {
  const NovostiScreen({super.key});

  @override
  State<NovostiScreen> createState() => _NovostiScreenState();
}

class _NovostiScreenState extends State<NovostiScreen> {
  List<Obavijest> _novosti = [];
  bool _isLoading = true;
  int _totalCount = 0;
  int _currentPage = 1;
  int _pageSize = 6;
  String _searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNovosti();
  }

  Future<void> _loadNovosti() async {
    try {
      final response = await ApiService().getObavijesti(
        page: _currentPage,
        pageSize: _pageSize,
        search: _searchQuery,
      );
      setState(() {
        _novosti = response['data'];
        _totalCount = response['count'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Greška pri dohvatu obavijesti: $e");
    }
  }

  Future<void> _confirmDelete(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Potvrda brisanja'),
            content: const Text('Sigurno želite obrisati ovu novost?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Otkaži'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Obriši'),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        final success = await ApiService.deleteNovost(id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Novost uspješno obrisana')),
          );
          _loadNovosti(); // Reload the news after deletion
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška pri brisanju novosti')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Novosti",
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: "Pretraži po nazivu",
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _currentPage = 1;
                          });
                          _loadNovosti();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _openAddDialog(context); // Fixed here
                      },
                      child: const Text("Dodaj novost"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (var obavijest in _novosti)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    NovostiDetailsScreen(obavijest: obavijest),
                          ),
                        );
                      },
                      hoverColor: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      obavijest.slika != "string" &&
                                              obavijest.slika != null
                                          ? Image.memory(
                                            base64Decode(obavijest.slika!),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image,
                                              size: 40,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obavijest.naslov,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Datum objave: ${obavijest.datumObjave.toLocal().toString().split(' ')[0]}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        obavijest.sadrzaj.length > 150
                                            ? "${obavijest.sadrzaj.substring(0, 150)}..."
                                            : obavijest.sadrzaj,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _openEditDialog(context, obavijest);
                                  },
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  onPressed: () {
                                    _confirmDelete(obavijest.id);
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_totalCount > _novosti.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage * _pageSize < _totalCount) {
                          setState(() {
                            _currentPage++;
                          });
                          _loadNovosti();
                        }
                      },
                      child: const Text('Pokaži više'),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  void _openEditDialog(BuildContext context, Obavijest obavijest) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditNovostDialog(novost: obavijest); // koristi pravi parametar
      },
    );

    if (result == true) {
      _loadNovosti(); // osvježi listu ako je novost uređena
    }
  }

  // Unutar NovostiScreen
  void _openAddDialog(BuildContext context) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DodajNovostDialog();
      },
    );

    if (result == true) {
      // Ako je novost uspešno dodana, reloaduj podatke
      _loadNovosti();
    }
  }
}
