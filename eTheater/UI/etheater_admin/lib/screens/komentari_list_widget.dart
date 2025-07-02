import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/odgovor_popup.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KomentariListWidget extends StatefulWidget {
  final int obavijestId;

  const KomentariListWidget({super.key, required this.obavijestId});

  @override
  State<KomentariListWidget> createState() => _KomentariListWidgetState();
}

class _KomentariListWidgetState extends State<KomentariListWidget> {
  final ApiService _apiService = ApiService();
  int _currentPage = 1;
  int _totalCount = 0;
  final int _pageSize = 2;
  List<KomentarObavijest> _komentari = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchKomentari();
  }

  Future<void> _fetchKomentari() async {
    setState(() => _loading = true);

    try {
      final result = await _apiService.getKomentariByObavijest(
        obavijestId: widget.obavijestId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (!mounted) return;

      setState(() {
        _komentari = result['data'];
        _totalCount = result['count'];
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: ${e.toString()}")));
    } finally {
      if (!mounted) return;

      setState(() => _loading = false);
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > (_totalCount / _pageSize).ceil()) return;
    setState(() => _currentPage = page);
    _fetchKomentari();
  }

  Widget buildKomentarCard(KomentarObavijest komentar) {
    print(
      'Komentar: id=${komentar.id}, tekst=${komentar.text}, autor=${komentar.imeKorisnika}',
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.person), radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${komentar.imeKorisnika} ${komentar.prezimeKorisnika}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(komentar.text),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(komentar.datum),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.comment_outlined),
                            label: Text('${komentar.brojOdgovora}'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  komentar.brojOdgovora > 0
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                            onPressed:
                                komentar.brojOdgovora > 0
                                    ? () => prikaziPopupSaOdgovorima(komentar)
                                    : null,
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.black,
                            ),
                            tooltip: "Obriši komentar",
                            onPressed: () async {
                              final potvrda = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Potvrda'),
                                      content: const Text(
                                        'Da li ste sigurni da želite obrisati komentar?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('Ne'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text('Da'),
                                        ),
                                      ],
                                    ),
                              );

                              if (potvrda == true) {
                                try {
                                  await ApiService.deleteKomentar(komentar.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Komentar je obrisan'),
                                    ),
                                  );
                                  _fetchKomentari();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Greška pri brisanju komentara: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
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
  }

  void prikaziPopupSaOdgovorima(KomentarObavijest komentar) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 500,
              height: 400,
              child: OdgovoriKomentarPopup(komentarId: komentar.id),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_totalCount / _pageSize).ceil();

    return Column(
      children: [
        const SizedBox(height: 8),
        if (_loading)
          const CircularProgressIndicator()
        else if (_komentari.isEmpty)
          const Text("Nema komentara za ovu obavijest.")
        else
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _komentari.length,
              itemBuilder: (context, index) {
                return buildKomentarCard(_komentari[index]);
              },
            ),
          ),

        if (totalPages > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                icon: const Icon(Icons.arrow_back),
              ),
              Text("$_currentPage / $totalPages"),
              IconButton(
                onPressed:
                    _currentPage < totalPages
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
      ],
    );
  }
}
