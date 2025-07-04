import 'dart:async';
import 'dart:convert';
import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/ocijeni_predstavu_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MojeRezervacijeScreen extends StatefulWidget {
  const MojeRezervacijeScreen({super.key});

  @override
  State<MojeRezervacijeScreen> createState() => _MojeRezervacijeScreenState();
}

class _MojeRezervacijeScreenState extends State<MojeRezervacijeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<MojaRezervacija> _rezervacije = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _filterNaziv = "";
  bool _filterAktivne = true;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy. HH:mm');

  @override
  void initState() {
    super.initState();
    _loadRezervacije();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _loadRezervacije();
        }
      }
    });

    _searchController.addListener(() {
      final filter = _searchController.text.trim();
      if (filter != _filterNaziv) {
        _filterNaziv = filter;
        _resetAndLoadRezervacije();
      }
    });
  }

  Future<void> _resetAndLoadRezervacije() async {
    setState(() {
      _rezervacije.clear();
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadRezervacije();
  }

  Future<void> _loadRezervacije() async {
    if (!_hasMore) return;
    print("2");

    print(_filterAktivne);

    setState(() => _isLoading = true);

    try {
      final korisnikId = AuthProvider.userId ?? 0;
      final result = await ApiService.getMojeRezervacije(
        korisnikId: korisnikId,
        nazivPredstave: _filterNaziv,
        aktivne: _filterAktivne == true ? true : null,
        isUsedTicket: !_filterAktivne,
        page: _currentPage,
        pageSize: 4,
      );
      print('Ukupno: ${result.resultList}');

      setState(() {
        _rezervacije.addAll(result.resultList);
        _currentPage++;
        if (_rezervacije.length >= result.count) {
          _hasMore = false;
        }
      });
    } catch (e) {
      debugPrint('Greška pri učitavanju rezervacija: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRezervacijaCard(MojaRezervacija rez) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      elevation: 4,
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child:
                    rez.plakatUrl != null && rez.plakatUrl!.isNotEmpty
                        ? Image.memory(
                          base64Decode(
                            rez.plakatUrl!.contains(',')
                                ? rez.plakatUrl!.split(',')[1]
                                : rez.plakatUrl!,
                          ),
                          fit: BoxFit.cover,
                        )
                        : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50),
                        ),
              ),
            ),
            Positioned(
              top: 12,
              bottom: 12,
              left: 130,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rez.naziv ?? "Nepoznata predstava",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Datum: ${_dateFormat.format(rez.datumVrijemeIzvedbe)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sala: ${rez.nazivSale ?? "-"}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Broj karata: ${rez.brojKarata}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (rez.isUsedTicket)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder:
                                (context) => OcijeniPredstavuSheet(
                                  predstavaId: rez.predstavaId,
                                  onKomentarPoslan: () {},
                                ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: const Text("Ocijeni predstavu"),
                      ),
                    ),

                  if (rez.isKupljeno && _filterAktivne)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () {
                            _showQrCodeDialog(rez.id.toString());
                          },
                          child: const Text("QR code"),
                        ),
                      ),
                    ),

                  if (rez.datumVrijemeIzvedbe.isAfter(DateTime.now()) &&
                      rez.isKupljeno == false)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Potvrdi otkazivanje'),
                                  content: const Text(
                                    'Jeste li sigurni da želite otkazati rezervaciju?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Ne'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Da'),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            try {
                              final success =
                                  await ApiService.obrisiRezervaciju(rez.id);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Rezervacija uspješno otkazana.',
                                    ),
                                  ),
                                );
                                _resetAndLoadRezervacije();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Neuspjelo otkazivanje rezervacije.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Greška: $e')),
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        child: const Text("Otkaži rezervaciju"),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              bottom: 12,
              right: 12,
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.shade400,
                      Colors.transparent,
                      Colors.grey.shade400,
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Moje rezervacije",
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pretraži po nazivu predstave",
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Aktivne rezervacije: "),
                Switch(
                  value: _filterAktivne,
                  onChanged: (value) {
                    setState(() {
                      _filterAktivne = value;
                      print("1");

                      print(_filterAktivne);
                      _resetAndLoadRezervacije();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _rezervacije.isEmpty && !_isLoading
                      ? const Center(
                        child: Text(
                          "Nema rezervacija koje odgovaraju kriterijima.",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: _rezervacije.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _rezervacije.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final rez = _rezervacije[index];
                          return _buildRezervacijaCard(rez);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQrCodeDialog(String? brojRezervacije) {
    if (brojRezervacije == null || brojRezervacije.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nema dostupnog QR koda.')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('QR Code'),
            content: SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: brojRezervacije,
                version: QrVersions.auto,
                size: 200,
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zatvori'),
              ),
            ],
          ),
    );
  }
}
