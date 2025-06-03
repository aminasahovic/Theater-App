import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/izvedba_predstava_screen.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class RepertoarScreen extends StatefulWidget {
  const RepertoarScreen({super.key});

  @override
  State<RepertoarScreen> createState() => _RepertoarScreenState();
}

class _RepertoarScreenState extends State<RepertoarScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Repertoar> _repertoari = [];
  int _currentPage = 1;
  final int _pageSize = 6;
  int _totalCount = 0;
  bool _isLoading = false;
  String? _searchNaziv;

  @override
  void initState() {
    super.initState();
    _loadRepertoar();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _repertoari.length < _totalCount) {
        _currentPage++;
        _loadRepertoar(append: true);
      }
    });
  }

  Future<void> _loadRepertoar({bool append = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getRepertoar(
        page: _currentPage,
        pageSize: _pageSize,
        naziv: _searchNaziv,
      );
      print(result.count);
      setState(() {
        _totalCount = result.count;
        if (append) {
          _repertoari.addAll(result.resultList);
        } else {
          _repertoari = result.resultList;
        }
      });
    } catch (e) {
      debugPrint('Error loading repertoar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _currentPage = 1;
    _searchNaziv = _searchController.text.trim();
    _loadRepertoar();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd.MM.yyyy.').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Repertoar',
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pretraži po nazivu predstave',
              ),
              onChanged: (value) {
                _onSearchChanged();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _currentPage = 1;
                await _loadRepertoar();
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _repertoari.length + (_isLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == _repertoari.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final r = _repertoari[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: Colors.grey.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      leading: const Icon(
                        Icons.theater_comedy,
                        color: Color(0xFF800000),
                      ),
                      title: Text(
                        r.naziv,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Početak: ${_formatDate(r.pocetakDatum)} - Kraj: ${_formatDate(r.krajDatum)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF800000),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    IzvedbaPredstavaScreen(repertoarId: r.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
