import 'dart:convert';

import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/predstave_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
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
      'Novosti',
      RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _refreshKomentari,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Hero image
            if (novost.slika != null && novost.slika!.isNotEmpty)
              Stack(
                children: [
                  Image.memory(
                    base64Decode(novost.slika!),
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.pageBackground.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    novost.naslov,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatDate(novost.datumObjave),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Body
                  ..._buildParagraphs(novost.sadrzaj),
                  const SizedBox(height: 24),

                  // Recommendations
                  if (preporucenePredstave.isNotEmpty) ...[
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    const Text(
                      'Preporuke za vas',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: preporucenePredstave.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final p = preporucenePredstave[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PredstavaScreen(
                                  predstavaId: p.id,
                                  izvedbaId: p.izvedbaId,
                                ),
                              ),
                            ),
                            child: Container(
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (p.plakat != null && p.plakat!.isNotEmpty)
                                    Image.memory(
                                      base64Decode(p.plakat!),
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    Container(
                                      height: 120,
                                      decoration: const BoxDecoration(
                                        gradient: AppTheme.placeholderGradient,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.naziv,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${p.trajanje} min · ${p.godina}',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Comments section
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'Komentari',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Add comment input
                  TextField(
                    controller: _komentarController,
                    decoration: InputDecoration(
                      hintText: 'Napišite komentar...',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send_outlined,
                          color: AppTheme.primary,
                        ),
                        onPressed: () async {
                          final tekst = _komentarController.text.trim();
                          if (tekst.isEmpty) return;
                          try {
                            await ApiService.postKomentarNaObavijest(
                              InsertKomentarObavijest(
                                obavijestId: widget.novost.id,
                                korisnikId: AuthProvider.userId!,
                                text: tekst,
                                datum: DateTime.now(),
                              ),
                            );
                            _komentarController.clear();
                            _refreshKomentari();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Greška: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comment list
                  if (komentari.isEmpty && isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else if (komentari.isEmpty && !hasMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Budite prvi koji će komentarisati.',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                  ...komentari.map((k) => _buildKomentarCard(k)),

                  if (hasMore)
                    Center(
                      child: TextButton.icon(
                        onPressed: isLoading ? null : _loadKomentari,
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primary,
                                ),
                              )
                            : const Icon(Icons.expand_more),
                        label: const Text('Učitaj još komentara'),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKomentarCard(KomentarObavijest k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.accentTint,
                  child: Text(
                    (k.imeKorisnika.isNotEmpty ? k.imeKorisnika[0] : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${k.imeKorisnika} ${k.prezimeKorisnika}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDate(k.datum),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              k.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // Reply input
            TextField(
              controller: odgovorKontroleri.putIfAbsent(
                k.id,
                () => TextEditingController(),
              ),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Odgovorite na komentar...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send_outlined,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  onPressed: () async {
                    final tekst =
                        odgovorKontroleri[k.id]?.text.trim() ?? '';
                    if (tekst.isEmpty) return;
                    try {
                      await ApiService.postOdgovorNaKomentar(
                        InsertOdgovorKomentar(
                          komentariObavijestiId: k.id,
                          korisnikId: AuthProvider.userId!,
                          textOdgovora: tekst,
                          datum: DateTime.now(),
                        ),
                      );
                      odgovorKontroleri[k.id]?.clear();
                      trenutnaStranicaOdgovora[k.id] = 1;
                      imaJosOdgovora[k.id] = true;
                      odgovoriPoKomentaru[k.id] = [];
                      await _loadOdgovori(k.id);
                      setState(() => prikaziOdgovore[k.id] = true);
                    } catch (e) {
                      debugPrint('Greška: $e');
                    }
                  },
                ),
              ),
            ),

            // Toggle replies
            TextButton.icon(
              onPressed: () async {
                final otvoren = prikaziOdgovore[k.id] ?? false;
                if (!otvoren && odgovoriPoKomentaru[k.id] == null) {
                  await _loadOdgovori(k.id);
                }
                setState(() => prikaziOdgovore[k.id] = !otvoren);
              },
              icon: Icon(
                (prikaziOdgovore[k.id] ?? false)
                    ? Icons.expand_less
                    : Icons.expand_more,
                size: 16,
              ),
              label: Text(
                (prikaziOdgovore[k.id] ?? false)
                    ? 'Sakrij odgovore'
                    : 'Prikaži odgovore',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),

            if (prikaziOdgovore[k.id] == true)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Column(
                  children: [
                    if (odgovoriPoKomentaru[k.id]?.isEmpty ?? true)
                      const Text(
                        'Nema odgovora.',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ...odgovoriPoKomentaru[k.id]!.map(
                        (odg) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.reply,
                                size: 14,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(width: 6),
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.grey.shade100,
                                child: Text(
                                  odg.imeKorisnika.isNotEmpty
                                      ? odg.imeKorisnika[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${odg.imeKorisnika} ${odg.prezimeKorisnika}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      odg.textOdgovora,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (imaJosOdgovora[k.id] == true)
                      TextButton.icon(
                        onPressed: () => _loadOdgovori(k.id),
                        icon: const Icon(Icons.more_horiz, size: 16),
                        label: const Text(
                          'Učitaj još odgovora',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
