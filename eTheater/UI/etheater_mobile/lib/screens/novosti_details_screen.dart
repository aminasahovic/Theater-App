import 'dart:convert';

import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/predstave_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NovostiDetailsScreen extends StatefulWidget {
  final Novost novost;
  const NovostiDetailsScreen({super.key, required this.novost});

  @override
  State<NovostiDetailsScreen> createState() => _NovostiDetailsScreenState();
}

class _NovostiDetailsScreenState extends State<NovostiDetailsScreen> {
  final TextEditingController _komentarController = TextEditingController();
  Map<int, TextEditingController> odgovorKontroleri = {};
  List<PredstavaPreporuka> preporucenePredstave = [];

  List<KomentarObavijest> komentari = [];
  int currentPage = 1;
  final int pageSize = 3;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void dispose() {
    _komentarController.dispose();
    for (var controller in odgovorKontroleri.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<int, List<OdgovorKomentar>> odgovoriPoKomentaru = {};
  Map<int, int> trenutnaStranicaOdgovora = {};
  Map<int, bool> imaJosOdgovora = {};
  Map<int, bool> ucitavanjeOdgovora = {};
  final int odgovoriPageSize = 2;

  Map<int, bool> prikaziOdgovore = {};
  Future<void> _loadPreporuke() async {
    try {
      final result = await ApiService.getPreporukeZaKorisnika(
        AuthProvider.userId!,
      );
      setState(() {
        preporucenePredstave = result;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju preporuka: $e");
    }
  }

  Future<void> _loadKomentari() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiService.getKomentariByObavijest(
        obavijestiId: widget.novost.id,
        page: currentPage,
        pageSize: pageSize,
      );

      setState(() {
        if (currentPage == 1) {
          komentari = response.resultList;
          odgovorKontroleri.clear();
        } else {
          komentari.addAll(response.resultList);
        }
        for (var komentar in response.resultList) {
          if (!odgovorKontroleri.containsKey(komentar.id)) {
            odgovorKontroleri[komentar.id] = TextEditingController();
          }
        }
        hasMore = komentari.length < response.count;
        if (hasMore) currentPage++;
      });
    } catch (e) {
      debugPrint('Greška pri učitavanju komentara: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshKomentari() async {
    setState(() {
      currentPage = 1;
      hasMore = true;
      odgovoriPoKomentaru.clear();
      trenutnaStranicaOdgovora.clear();
      imaJosOdgovora.clear();
      ucitavanjeOdgovora.clear();
      prikaziOdgovore.clear();
    });
    await _loadKomentari();
  }

  Future<void> _loadOdgovori(int komentarId) async {
    if (ucitavanjeOdgovora[komentarId] == true ||
        imaJosOdgovora[komentarId] == false) {
      return;
    }

    ucitavanjeOdgovora[komentarId] = true;
    int page = (trenutnaStranicaOdgovora[komentarId] ?? 1);

    try {
      final result = await ApiService.getOdgovoriByKomentarId(
        komentarId: komentarId,
        page: page,
        pageSize: odgovoriPageSize,
      );

      final stariOdgovori = odgovoriPoKomentaru[komentarId] ?? [];
      final noviOdgovori = List<OdgovorKomentar>.from(stariOdgovori)
        ..addAll(result.resultList);

      setState(() {
        odgovoriPoKomentaru[komentarId] = noviOdgovori;
        imaJosOdgovora[komentarId] = noviOdgovori.length < result.count;
        if (imaJosOdgovora[komentarId] == true) {
          trenutnaStranicaOdgovora[komentarId] = page + 1;
        }
      });
    } catch (e) {
      debugPrint('Greška pri učitavanju odgovora za komentar $komentarId: $e');
    } finally {
      ucitavanjeOdgovora[komentarId] = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  List<Widget> _buildParagraphs(String text) {
    final parts = text.split(RegExp(r'(?<=\.)\s+'));
    return parts.map((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          p.trim(),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadKomentari();
    _loadPreporuke();
  }

  @override
  Widget build(BuildContext context) {
    final novost = widget.novost;

    return MasterScreen(
      "Novosti",
      RefreshIndicator(
        onRefresh: _refreshKomentari,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (novost.slika != null && novost.slika!.isNotEmpty)
              ClipRRect(
                child: Image.memory(
                  base64Decode(novost.slika!),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novost.naslov,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  ..._buildParagraphs(novost.sadrzaj),
                  const SizedBox(height: 8),
                  Text(
                    'Datum objave: ${_formatDate(novost.datumObjave)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.left,
                  ),
                  const Divider(height: 32),
                  if (preporucenePredstave.isNotEmpty) ...[
                    const Text(
                      'Preporuka za vas:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: preporucenePredstave.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final predstava = preporucenePredstave[index];
                          return SizedBox(
                            width: 180,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PredstavaScreen(
                                          predstavaId: predstava.id,
                                          izvedbaId: predstava.izvedbaId,
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (predstava.plakat != null &&
                                        predstava.plakat!.isNotEmpty)
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Image.memory(
                                          base64Decode(predstava.plakat!),
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            predstava.naziv,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${predstava.trajanje} min | ${predstava.godina}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            predstava.opis,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
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
                        },
                      ),
                    ),
                  ],
                  const Divider(height: 32),

                  const Text(
                    'Komentari',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _komentarController,
                    decoration: InputDecoration(
                      labelText: 'Dodaj komentar...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final tekst = _komentarController.text.trim();
                          if (tekst.isEmpty) return;
                          try {
                            final noviKomentar = InsertKomentarObavijest(
                              obavijestId: widget.novost.id,
                              korisnikId: AuthProvider.userId!,
                              text: tekst,
                              datum: DateTime.now(),
                            );
                            await ApiService.postKomentarNaObavijest(
                              noviKomentar,
                            );
                            _komentarController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Komentar uspješno dodan'),
                              ),
                            );
                            _refreshKomentari();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Greška: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (komentari.isEmpty && !isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: Text('Nema komentara')),
                    ),
                  ...komentari.map(
                    (k) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  (k.imeKorisnika.isNotEmpty
                                          ? k.imeKorisnika[0]
                                          : '') +
                                      (k.prezimeKorisnika.isNotEmpty
                                          ? k.prezimeKorisnika[0]
                                          : ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${k.imeKorisnika} ${k.prezimeKorisnika}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(k.text),
                              trailing: Text(
                                _formatDate(k.datum),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: odgovorKontroleri.putIfAbsent(
                                k.id,
                                () {
                                  return TextEditingController();
                                },
                              ),

                              decoration: InputDecoration(
                                hintText: 'Dodaj odgovor...',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () async {
                                    final tekst =
                                        odgovorKontroleri[k.id]?.text.trim() ??
                                        '';

                                    try {
                                      final noviOdgovor = InsertOdgovorKomentar(
                                        komentariObavijestiId: k.id,
                                        korisnikId: AuthProvider.userId!,
                                        textOdgovora: tekst,
                                        datum: DateTime.now(),
                                      );
                                      await ApiService.postOdgovorNaKomentar(
                                        noviOdgovor,
                                      );
                                      odgovorKontroleri[k.id]?.clear();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Odgovor uspješno dodan',
                                          ),
                                        ),
                                      );
                                      trenutnaStranicaOdgovora[k.id] = 1;
                                      imaJosOdgovora[k.id] = true;
                                      odgovoriPoKomentaru[k.id] = [];
                                      await _loadOdgovori(k.id);
                                      setState(() {
                                        prikaziOdgovore[k.id] = true;
                                      });
                                    } catch (e) {
                                      print("Greška: $e");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Greška: $e')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: TextButton(
                                onPressed: () async {
                                  bool otvoren = prikaziOdgovore[k.id] ?? false;

                                  if (!otvoren) {
                                    if (odgovoriPoKomentaru[k.id] == null) {
                                      await _loadOdgovori(k.id);
                                    }
                                  }

                                  setState(() {
                                    prikaziOdgovore[k.id] = !otvoren;
                                  });
                                },
                                child: Text(
                                  prikaziOdgovore[k.id] == true
                                      ? 'Sakrij odgovore'
                                      : 'Prikaži odgovore',
                                ),
                              ),
                            ),

                            if (prikaziOdgovore[k.id] == true)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 40,
                                  top: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((odgovoriPoKomentaru[k.id]?.isEmpty ??
                                        true))
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'Nema odgovora',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    else
                                      ...odgovoriPoKomentaru[k.id]!.map((odg) {
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.reply,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 6),
                                              CircleAvatar(
                                                radius: 14,
                                                child: Text(
                                                  (odg.imeKorisnika.isNotEmpty
                                                          ? odg.imeKorisnika[0]
                                                          : '') +
                                                      (odg
                                                              .prezimeKorisnika
                                                              .isNotEmpty
                                                          ? odg
                                                              .prezimeKorisnika[0]
                                                          : ''),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          title: Text(
                                            '${odg.imeKorisnika} ${odg.prezimeKorisnika}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(odg.textOdgovora),
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),

                            if (imaJosOdgovora[k.id] == true &&
                                prikaziOdgovore[k.id] == true)
                              Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: TextButton.icon(
                                  onPressed: () => _loadOdgovori(k.id),
                                  icon: const Icon(Icons.more_horiz),
                                  label: const Text('Učitaj još odgovora'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (hasMore)
                    Center(
                      child: TextButton(
                        onPressed: _loadKomentari,
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Učitaj još komentara'),
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
}
