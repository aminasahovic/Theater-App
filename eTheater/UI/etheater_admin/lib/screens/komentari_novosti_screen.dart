import 'dart:async';

import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/screens/komentari_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';

class KomentariNovostiScreen extends StatefulWidget {
  const KomentariNovostiScreen({super.key});

  @override
  State<KomentariNovostiScreen> createState() => _KomentariNovostiScreenState();
}

class _KomentariNovostiScreenState extends State<KomentariNovostiScreen> {
  final ApiService _apiService = ApiService();
  Timer? _debounce;
  int _currentPage = 1;
  int _totalCount = 0;
  int _pageSize = 6;
  bool isExpanded = false;
  final TextEditingController _naslovController = TextEditingController();

  List<Obavijest> _obavijesti = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchObavijesti();
  }

  Future<void> _fetchObavijesti() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.getObavijesti(
        page: _currentPage,
        pageSize: _pageSize,
        naslov: _naslovController.text,
      );
      setState(() {
        _obavijesti = result['data'];
        _totalCount = result['count'];
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > (_totalCount / _pageSize).ceil()) return;
    setState(() {
      _currentPage = page;
    });
    _fetchObavijesti();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_totalCount / _pageSize).ceil();

    return MasterScreen(
      "Komentari na obavijesti",
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _naslovController,
                  decoration: InputDecoration(
                    labelText: 'Pretraga po naslovu',
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
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      setState(() {
                        _currentPage = 1;
                      });
                      _fetchObavijesti();
                    });
                  },
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _obavijesti.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final obavijest = _obavijesti[index];
                    return StatefulBuilder(
                      builder: (context, setStateCard) {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.date_range,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      // ignore: unnecessary_null_comparison
                                      obavijest.datumObjave != null
                                          ? DateFormat(
                                            'dd.MM.yyyy',
                                          ).format(obavijest.datumObjave)
                                          : 'Nepoznat datum',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton.icon(
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.comment,
                                    ),
                                    label: Text(
                                      isExpanded
                                          ? "Sakrij komentare"
                                          : "Prikaži komentare",
                                    ),
                                    onPressed:
                                        () => setStateCard(() {
                                          isExpanded = !isExpanded;
                                        }),
                                  ),
                                ),
                                if (isExpanded)
                                  KomentariListWidget(
                                    obavijestId: obavijest.id,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed:
                            _currentPage > 1
                                ? () => _goToPage(_currentPage - 1)
                                : null,
                        child: const Text("Prethodna"),
                      ),
                      Text("Stranica $_currentPage od $totalPages"),
                      TextButton(
                        onPressed:
                            _currentPage < totalPages
                                ? () => _goToPage(_currentPage + 1)
                                : null,
                        child: const Text("Sljedeća"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
    );
  }
}
