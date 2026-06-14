import 'dart:convert';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/dodaj_novost_dialog.dart';
import 'package:etheater_admin/screens/edit_novost_dialog.dart';
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
  final int _pageSize = 8;
  final DateFormat formatter = DateFormat('dd.MM.yyyy.');

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _datumController = TextEditingController();
  DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();
    _loadNovosti();
  }

  bool isValidBase64(String? str) {
    if (str == null || str.isEmpty) return false;
    if (str.trim().toLowerCase() == 'string') return false;
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
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
            title: const Text(
              'Potvrda brisanja',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            content: const Text(
              'Sigurno želite obrisati ovu novost?',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Otkaži'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Obriši'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
          : Padding(
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
                          labelText: "Pretraži po nazivu...",
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
                    // **Dodano Padding s desne strane da bude usklađeno sa karticama**
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                      ), // isto kao kod kartica
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800020),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _openAddDialog(context);
                        },
                        child: const Text("Dodaj novost"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth ~/ 300;
                      crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              _novosti.map((obavijest) {
                                return SizedBox(
                                  width:
                                      (constraints.maxWidth / crossAxisCount) -
                                      12,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Slika
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          child:
                                              isValidBase64(obavijest.slika)
                                                  ? Image.memory(
                                                    base64Decode(
                                                      obavijest.slika!,
                                                    ),
                                                    height: 150,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    height: 150,
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 60,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                        // Sadržaj kartice
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                obavijest.naslov,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formatter.format(
                                                  obavijest.datumObjave
                                                      .toLocal(),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                obavijest.sadrzaj,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  // Uredi dugme
                                                  OutlinedButton.icon(
                                                    onPressed:
                                                        () => _openEditDialog(
                                                          context,
                                                          obavijest,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 16,
                                                    ),
                                                    label: const Text("Uredi"),
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      textStyle:
                                                          const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Obriši dugme
                                                  OutlinedButton.icon(
                                                    onPressed:
                                                        () => _confirmDelete(
                                                          obavijest.id,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 16,
                                                    ),
                                                    label: const Text("Obriši"),
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      textStyle:
                                                          const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      foregroundColor:
                                                          Colors.red,
                                                      side: const BorderSide(
                                                        color: Colors.red,
                                                      ),
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
                                );
                              }).toList(),
                        ),
                      );
                    },
                  ),
                ),

                if (_totalPages > 1) const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed:
                              _currentPage > 1
                                  ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                    _loadNovosti();
                                  }
                                  : null,
                          child: const Text('Prethodna'),
                        ),
                        const SizedBox(width: 16),
                        Text('Stranica $_currentPage od $_totalPages'),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed:
                              _currentPage < _totalPages
                                  ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                    _loadNovosti();
                                  }
                                  : null,
                          child: const Text('Sljedeća'),
                        ),
                      ],
                    ),
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
