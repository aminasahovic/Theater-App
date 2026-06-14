import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KomentariPredstaveScreen extends StatefulWidget {
  const KomentariPredstaveScreen({super.key});

  @override
  State<KomentariPredstaveScreen> createState() =>
      _KomentariPredstaveScreenState();
}

class _KomentariPredstaveScreenState extends State<KomentariPredstaveScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<PredstavaLov> _predstave = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 5;
  String _searchNaziv = '';

  final Set<int> _expandedIds = {};
  final Map<int, int> _komentariPageMap = {};
  final Map<int, PagedResult<KomentarPredstavaDTO>> _komentariPagedMap = {};
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPredstave();
    _searchController.addListener(() {
      final newText = _searchController.text.trim();
      if (newText != _searchNaziv) {
        _searchNaziv = newText;
        _currentPage = 1;
        _loadPredstave();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPredstave() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      var result = await ApiService.getPredstaveLov(
        naziv: _searchNaziv,
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _predstave = result.resultList;
        _totalPages = (result.count / _pageSize).ceil();
      });
    } catch (e) {
      setState(() {
        _error = 'Greška pri dohvaćanju podataka: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadKomentari(int predstavaId, int page) async {
    final result = await ApiService.getKomentariByPredstava(
      predstavaId,
      page: page,
    );
    setState(() {
      _komentariPagedMap[predstavaId] = result;
      _komentariPageMap[predstavaId] = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Komentari na predstave",
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pretraga po nazivu predstave...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF800020),
                    width: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text(_error!))
                      : _predstave.isEmpty
                      ? const Center(child: Text("Nema dostupnih predstava."))
                      : ListView.separated(
                        itemCount: _predstave.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final predstava = _predstave[index];
                          final isExpanded = _expandedIds.contains(
                            predstava.id,
                          );

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    predstava.naziv,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () async {
                                        setState(() {
                                          if (isExpanded) {
                                            _expandedIds.remove(predstava.id);
                                          } else {
                                            _expandedIds.add(predstava.id);
                                            _komentariPageMap[predstava.id] = 1;
                                          }
                                        });

                                        if (!isExpanded) {
                                          await _loadKomentari(predstava.id, 1);
                                        }
                                      },
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                      ),
                                      label: Text(
                                        isExpanded
                                            ? 'Sakrij komentare'
                                            : 'Prikaži komentare',
                                      ),
                                    ),
                                  ),
                                  if (isExpanded)
                                    Builder(
                                      builder: (context) {
                                        final pagedResult =
                                            _komentariPagedMap[predstava.id];
                                        final komentari =
                                            pagedResult?.resultList ?? [];
                                        final total = pagedResult?.count ?? 0;
                                        final currentPage =
                                            _komentariPageMap[predstava.id] ??
                                            1;
                                        final totalPages = (total / 3).ceil();

                                        if (pagedResult == null) {
                                          return const Padding(
                                            padding: EdgeInsets.only(top: 12),
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }

                                        if (komentari.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.only(top: 12),
                                            child: Text("Nema komentara."),
                                          );
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: Column(
                                            children: [
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      komentari.length > 1
                                                          ? 300
                                                          : double.infinity,
                                                ),
                                                child: Scrollbar(
                                                  controller: _scrollController,
                                                  thumbVisibility:
                                                      komentari.length > 1,
                                                  child: ListView.builder(
                                                    controller:
                                                        _scrollController,
                                                    shrinkWrap: true,
                                                    itemCount: komentari.length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final komentar =
                                                          komentari[index];
                                                      return ListTile(
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                        leading: CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .deepPurple[200],
                                                          child: const Icon(
                                                            Icons.person,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        title: Text(
                                                          '${komentar.imeKorisnika} ${komentar.prezimeKorisnika}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              komentar.komentar,
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              // ignore: unnecessary_null_comparison
                                                              'Objavljeno: ${komentar.datum != null ? DateFormat('dd.MM.yyyy. HH:mm').format(komentar.datum.toLocal()) : ''}',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: IconButton(
                                                          onPressed: () async {
                                                            final confirmed = await showDialog<
                                                              bool
                                                            >(
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    context,
                                                                  ) => AlertDialog(
                                                                    title: const Text(
                                                                      'Potvrda',
                                                                    ),
                                                                    content:
                                                                        const Text(
                                                                          'Da li ste sigurni da želite obrisati ovaj komentar?',
                                                                        ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.of(
                                                                              context,
                                                                            ).pop(
                                                                              false,
                                                                            ),
                                                                        child: const Text(
                                                                          'Otkaži',
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.of(
                                                                              context,
                                                                            ).pop(
                                                                              true,
                                                                            ),
                                                                        child: const Text(
                                                                          'Obriši',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            );

                                                            if (confirmed ==
                                                                true) {
                                                              try {
                                                                await ApiService.deleteKomentarPredstava(
                                                                  komentar.id,
                                                                );
                                                                await _loadKomentari(
                                                                  predstava.id,
                                                                  currentPage,
                                                                );
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      'Komentar uspješno obrisan',
                                                                    ),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Greška: $e',
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),

                                              if (totalPages > 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.arrow_back,
                                                        ),
                                                        onPressed:
                                                            currentPage > 1
                                                                ? () async {
                                                                  final newPage =
                                                                      currentPage -
                                                                      1;
                                                                  await _loadKomentari(
                                                                    predstava
                                                                        .id,
                                                                    newPage,
                                                                  );
                                                                }
                                                                : null,
                                                      ),
                                                      Text(
                                                        '$currentPage / $totalPages',
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.arrow_forward,
                                                        ),
                                                        onPressed:
                                                            currentPage <
                                                                    totalPages
                                                                ? () async {
                                                                  final newPage =
                                                                      currentPage +
                                                                      1;
                                                                  await _loadKomentari(
                                                                    predstava
                                                                        .id,
                                                                    newPage,
                                                                  );
                                                                }
                                                                : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            if (!_isLoading && _error == null && _predstave.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed:
                          _currentPage > 1
                              ? () {
                                setState(() {
                                  _currentPage--;
                                });
                                _loadPredstave();
                              }
                              : null,
                      child: const Text('Prethodna'),
                    ),
                    const SizedBox(width: 16),
                    Text('$_currentPage od $_totalPages'),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed:
                          _currentPage < _totalPages
                              ? () {
                                setState(() {
                                  _currentPage++;
                                });
                                _loadPredstave();
                              }
                              : null,
                      child: const Text('Sljedeća'),
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
