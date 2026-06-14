import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/izvedba_predstava_screen.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
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
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getRepertoar(
        page: _currentPage,
        pageSize: _pageSize,
        naziv: _searchNaziv,
      );
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
      setState(() => _isLoading = false);
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

  String _formatDate(DateTime dt) =>
      DateFormat('dd.MM.yyyy.').format(dt);

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Repertoar',
      Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pretraži repertoar...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: () async {
                _currentPage = 1;
                await _loadRepertoar();
              },
              child: _repertoari.isEmpty && _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : _repertoari.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _repertoari.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _repertoari.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        return _buildRepertoarCard(_repertoari[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepertoarCard(Repertoar r) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IzvedbaPredstavaScreen(repertoarId: r.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFfde0e8), Color(0xFFf5c2d0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.theater_comedy,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.naziv,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(r.pocetakDatum)} – ${_formatDate(r.krajDatum)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accentTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.theaters_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Nema repertoara',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
