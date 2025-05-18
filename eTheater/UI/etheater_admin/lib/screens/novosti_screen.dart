import 'dart:convert';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/dodaj_novost_dialog.dart';
import 'package:etheater_admin/screens/edit_novost_dialog.dart';
import 'package:etheater_admin/screens/novosti_details.dart';
import 'package:flutter/material.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:intl/intl.dart';

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
  final int _pageSize = 6;
  final DateFormat formatter = DateFormat('dd.MM.yyyy.');

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _datumController = TextEditingController();
  DateTime? _selectedDate;
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
        naslov: _searchController.text,
        datumObjave: _selectedDate,
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

  int get _totalPages => (_totalCount / _pageSize).ceil();

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
          _loadNovosti();
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
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _datumController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Datum objave",
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _datumController.text =
                                  picked.toLocal().toString().split(' ')[0];
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _currentPage = 1;
                        });
                        _loadNovosti();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _datumController.clear();
                          _selectedDate = null;
                          _currentPage = 1;
                        });
                        _loadNovosti();
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _openAddDialog(context);
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Slika
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  obavijest.slika != "string" &&
                                          obavijest.slika != null
                                      ? Image.memory(
                                        base64Decode(obavijest.slika!),
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        height: 100,
                                        width: 100,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image,
                                          size: 40,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 16),
                            // Tekstualni dio
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    obavijest.naslov,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Datum objave: ${formatter.format(obavijest.datumObjave.toLocal())}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    obavijest.sadrzaj,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _openEditDialog(context, obavijest);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _confirmDelete(obavijest.id);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalPages, (index) {
                        int pageNumber = index + 1;
                        bool isSelected = _currentPage == pageNumber;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.blue : Colors.grey[300],
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentPage = pageNumber;
                              });
                              _loadNovosti();
                            },
                            child: Text(pageNumber.toString()),
                          ),
                        );
                      }),
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
        return EditNovostDialog(novost: obavijest);
      },
    );

    if (result == true) {
      _loadNovosti();
    }
  }

  void _openAddDialog(BuildContext context) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const DodajNovostDialog();
      },
    );

    if (result == true) {
      _loadNovosti();
    }
  }
}
