import 'dart:convert';

import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/novosti_details_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'master_screen.dart';

class NovostiScreen extends StatefulWidget {
  const NovostiScreen({super.key});

  @override
  State<NovostiScreen> createState() => _NovostiScreenState();
}

class _NovostiScreenState extends State<NovostiScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Novost> _novosti = [];
  int _currentPage = 1;
  final int _pageSize = 5;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNovosti();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchNovosti();
      }
    });

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        _searchQuery = query;
        _refreshNovosti();
      }
    });
  }

  Future<void> _fetchNovosti() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getNovosti(
        naslov: _searchQuery,
        page: _currentPage,
        pageSize: _pageSize,
      );
      setState(() {
        if (_currentPage == 1) {
          _novosti = response.resultList;
        } else {
          _novosti.addAll(response.resultList);
        }
        _hasMore = _novosti.length < response.count;
        if (_hasMore) _currentPage++;
      });
    } catch (e) {
      debugPrint('Greška pri učitavanju novosti: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshNovosti() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _novosti = [];
    });
    await _fetchNovosti();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Novosti',
      Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pretraži novosti...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _refreshNovosti,
              child: _novosti.isEmpty && _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _novosti.isEmpty && !_hasMore
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _novosti.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _novosti.length) {
                          return _buildNovostCard(_novosti[index]);
                        }
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                              strokeWidth: 2.5,
                            ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.newspaper_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Nema novosti',
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

  Widget _buildNovostCard(Novost novost) {
    Widget imageWidget;

    if (novost.slika != null && novost.slika!.isNotEmpty) {
      try {
        final bytes = base64Decode(novost.slika!);
        imageWidget = Image.memory(
          bytes,
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imagePlaceholder(),
        );
      } catch (_) {
        imageWidget = _imagePlaceholder();
      }
    } else {
      imageWidget = _imagePlaceholder();
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NovostiDetailsScreen(novost: novost),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: imageWidget,
                ),
                // Date badge on image
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDate(novost.datumObjave),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Text(
                novost.naslov,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                novost.sadrzaj.length > 110
                    ? '${novost.sadrzaj.substring(0, 110)}...'
                    : novost.sadrzaj,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 13,
                          color: AppTheme.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Novost',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Čitaj više',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 11,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 190,
      decoration: const BoxDecoration(
        gradient: AppTheme.placeholderGradient,
      ),
      child: const Center(
        child: Icon(Icons.article_outlined, size: 48, color: Colors.white30),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
