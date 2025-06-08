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
  final int _pageSize = 10;
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
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth ~/ 300;
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              _novosti.map((obavijest) {
                                return SizedBox(
                                  width:
                                      constraints.maxWidth / crossAxisCount -
                                      12,
                                  child: Card(
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
                                                    NovostiDetailsScreen(
                                                      obavijest: obavijest,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                            child:
                                                isValidBase64(obavijest.slika)
                                                    ? Image.memory(
                                                      base64Decode(
                                                        obavijest.slika!,
                                                      ),
                                                      height: 140,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    )
                                                    : Container(
                                                      height: 140,
                                                      width: double.infinity,
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 60,
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade500,
                                                        ),
                                                      ),
                                                    ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              children: [
                                                Text(
                                                  obavijest.naslov,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Datum: ${formatter.format(obavijest.datumObjave.toLocal())}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  obavijest.sadrzaj,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed:
                                                            () =>
                                                                _openEditDialog(
                                                                  context,
                                                                  obavijest,
                                                                ),
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed:
                                                            () =>
                                                                _confirmDelete(
                                                                  obavijest.id,
                                                                ),
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          size: 20,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _currentPage > 1
                                  ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                    _loadNovosti();
                                  }
                                  : null,
                          child: const Text("Prethodna"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text("Stranica $_currentPage od $_totalPages"),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:
                              _currentPage < _totalPages
                                  ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                    _loadNovosti();
                                  }
                                  : null,
                          child: const Text("Sljedeća"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
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
