import 'dart:convert';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/delete_utils.dart';
import 'package:etheater_admin/screens/dodaj_predstavu_dialog.dart';
import 'package:etheater_admin/screens/predstava_details_screen.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';

class PredstaveScreen extends StatefulWidget {
  const PredstaveScreen({super.key});

  @override
  State<PredstaveScreen> createState() => _PredstaveScreenState();
}

class _PredstaveScreenState extends State<PredstaveScreen> {
  int _trenutnaStranica = 1;
  final int _pageSize = 5;
  int _ukupnoRezultata = 0;
  final ApiService _apiService = ApiService();
  bool? _isActiveFilter;
  List<Predstava> _filtriranePredstave = [];
  List<Zanr> _zanrovi = [];
  Zanr? _odabraniZanr;

  List<Reziser> _reziseri = [];
  Reziser? _odabraniReziser;

  String? _odabranaGodina;
  late TextEditingController _nazivController;
  @override
  void initState() {
    super.initState();
    _nazivController = TextEditingController();
    _fetchData();
    _ucitajFilterPodatke();
  }

  Future<void> _ucitajFilterPodatke() async {
    final zanrovi = await ApiService.fetchZanrovi();
    final reziseri = await ApiService.fetchReziseri();
    setState(() {
      _zanrovi = zanrovi;
      _reziseri = reziseri;
    });
  }

  Future<void> _fetchData() async {
    try {
      final result = await _apiService.getPredstave(
        naziv: _nazivController.text,
        zanrId: _odabraniZanr?.id,
        reziserId: _odabraniReziser?.id,
        godina: _odabranaGodina != null ? int.tryParse(_odabranaGodina!) : null,
        isActive: _isActiveFilter,
        page: _trenutnaStranica,
        pageSize: _pageSize,
      );

      setState(() {
        _ukupnoRezultata = result.count;
        _filtriranePredstave = result.resultList;
      });
    } catch (e) {
      print('Greška prilikom dohvaćanja predstava: $e');
    }
  }

  Widget _buildPaginationControls() {
    int ukupnoStranica = (_ukupnoRezultata / _pageSize).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed:
              _trenutnaStranica > 1
                  ? () {
                    setState(() {
                      _trenutnaStranica--;
                    });
                    _fetchData();
                  }
                  : null,
          child: Text('Prethodna'),
        ),
        SizedBox(width: 16),
        Text('Stranica $_trenutnaStranica od $ukupnoStranica'),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed:
              _trenutnaStranica < ukupnoStranica
                  ? () {
                    setState(() {
                      _trenutnaStranica++;
                    });
                    _fetchData();
                  }
                  : null,
          child: Text('Sljedeća'),
        ),
      ],
    );
  }

  Widget _buildPlakat(String? base64Image) {
    return Container(
      width: 140,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child:
          base64Image == null || base64Image.isEmpty
              ? Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey[600],
                ),
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.cover,
                  width: 140,
                  height: 200,
                ),
              ),
    );
  }

  Widget _buildPredstavaCard(Predstava predstava) {
    return StatefulBuilder(
      builder: (context, setState) {
        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => PredstavaDetailsScreen(predstavaId: predstava.id),
              ),
            );
            if (result == true) {
              await _fetchData();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlakat(predstava.plakat),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        predstava.naziv,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.brown[900],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              predstava.isActive
                                  ? Colors.green[100]
                                  : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          predstava.isActive ? 'Aktivna' : 'Neaktivna',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                predstava.isActive
                                    ? Colors.green[800]
                                    : Colors.red[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: Colors.brown,
                              ),
                              const SizedBox(width: 4),
                              Text('${predstava.trajanje} min'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.brown,
                              ),
                              const SizedBox(width: 4),
                              Text('${predstava.godina}'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        predstava.opis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed:
                                () => showDeleteConfirmationDialog(
                                  context: context,
                                  predstavaId: predstava.id,
                                  onDeleted: _fetchData,
                                ),
                            icon: Icon(Icons.delete_outline),
                            label: Text('Obriši'),
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
      },
    );
  }

  void _primijeniFiltere() {
    setState(() {
      _trenutnaStranica = 1;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Pregled Predstava',
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _nazivController,
                              decoration: InputDecoration(
                                hintText: 'Pretraži po nazivu...',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (_) => _primijeniFiltere(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<Zanr>(
                              value: _odabraniZanr,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Žanr',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items:
                                  _zanrovi.map((zanr) {
                                    return DropdownMenuItem(
                                      value: zanr,
                                      child: Text(zanr.naziv),
                                    );
                                  }).toList(),
                              onChanged: (zanr) {
                                setState(() => _odabraniZanr = zanr);
                                _primijeniFiltere();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<Reziser>(
                              value: _odabraniReziser,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Režiser',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items:
                                  _reziseri.map((rez) {
                                    return DropdownMenuItem(
                                      value: rez,
                                      child: Text('${rez.ime} ${rez.prezime}'),
                                    );
                                  }).toList(),
                              onChanged: (rez) {
                                setState(() => _odabraniReziser = rez);
                                _primijeniFiltere();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              value: _odabranaGodina,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Godina',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: List.generate(50, (i) {
                                final year =
                                    (DateTime.now().year - i).toString();
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                );
                              }),
                              onChanged: (value) {
                                setState(() => _odabranaGodina = value);
                                _primijeniFiltere();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<bool>(
                              value: _isActiveFilter,
                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Status',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('Sve'),
                                ),
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('Aktivne'),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('Neaktivne'),
                                ),
                              ],
                              onChanged: (bool? value) {
                                setState(() => _isActiveFilter = value);
                                _primijeniFiltere();
                              },
                            ),
                          ),

                          Row(
                            children: [
                              const SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.refresh),
                                tooltip: 'Resetuj filtere',
                                onPressed: () {
                                  setState(() {
                                    _nazivController.clear();
                                    _odabraniZanr = null;
                                    _odabraniReziser = null;
                                    _odabranaGodina = null;
                                    _isActiveFilter = null;
                                  });
                                  _fetchData();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _otvoriDodajPredstavuDialog,
                  child: const Text('Dodaj predstavu'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _filtriranePredstave.isEmpty
                      ? const Center(child: Text('Nema pronađenih predstava.'))
                      : ListView.builder(
                        itemCount: _filtriranePredstave.length,
                        itemBuilder: (context, index) {
                          return _buildPredstavaCard(
                            _filtriranePredstave[index],
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

  void _otvoriDodajPredstavuDialog() async {
    final bool? dodano = await showDialog<bool>(
      context: context,
      builder: (context) => const DodajPredstavuDialog(),
    );

    if (dodano == true) {
      await _fetchData();
    }
  }
}
