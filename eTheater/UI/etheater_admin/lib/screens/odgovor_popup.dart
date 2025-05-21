import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OdgovoriKomentarPopup extends StatefulWidget {
  final int komentarId;
  const OdgovoriKomentarPopup({super.key, required this.komentarId});

  @override
  State<OdgovoriKomentarPopup> createState() => _OdgovoriKomentarPopupState();
}

class _OdgovoriKomentarPopupState extends State<OdgovoriKomentarPopup> {
  final ApiService _apiService = ApiService();
  int _page = 1;
  int _pageSize = 5;
  int _total = 0;
  List<OdgovorKomentar> _odgovori = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final result = await _apiService.getOdgovoriNaKomentar(
        komentariObavijestiId: widget.komentarId,
        page: _page,
        pageSize: _pageSize,
      );
      setState(() {
        _odgovori = result['data'];
        _total = result['count'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_total / _pageSize).ceil();
    return Padding(
      padding: const EdgeInsets.all(16),
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Odgovori na komentar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _odgovori.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final odgovor = _odgovori[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 0,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              "${odgovor.imeKorisnika} ${odgovor.prezimeKorisnika}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(odgovor.textOdgovora),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(odgovor.datum),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Potvrda brisanja'),
                                        content: const Text(
                                          'Jeste li sigurni da želite obrisati ovaj odgovor?',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Otkaži'),
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                          ),
                                          TextButton(
                                            child: const Text(
                                              'Obriši',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  try {
                                    await ApiService.deleteOdgovorKomentar(
                                      odgovor.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Odgovor obrisan'),
                                      ),
                                    );
                                    // Refresh lista
                                    _fetch();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Greška pri brisanju: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              _page > 1 ? () => setState(() => _page--) : null,
                          child: const Text("Prethodna"),
                        ),
                        Text("Stranica $_page / $totalPages"),
                        TextButton(
                          onPressed:
                              _page < totalPages
                                  ? () => setState(() => _page++)
                                  : null,
                          child: const Text("Sljedeća"),
                        ),
                      ],
                    ),
                ],
              ),
    );
  }
}
