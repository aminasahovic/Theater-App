import 'dart:convert';

import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/novosti_details_screen.dart';
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
    });
    await _fetchNovosti();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildNovostCard(Novost novost) {
    Widget imageWidget;

    if (novost.slika != null && novost.slika!.isNotEmpty) {
      try {
        final bytes = base64Decode(novost.slika!);
        imageWidget = ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40),
                ),
          ),
        );
      } catch (e) {
        imageWidget = Container(
          height: 160,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        );
      }
    } else {
      imageWidget = Container(
        height: 160,
        color: Colors.grey[300],
        child: const Icon(Icons.article_outlined, size: 40),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NovostiDetailsScreen(novost: novost),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                novost.naslov,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                novost.sadrzaj.length > 120
                    ? '${novost.sadrzaj.substring(0, 120)}...'
                    : novost.sadrzaj,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Objavljeno: ${_formatDate(novost.datumObjave)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Novosti",
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pretraži po naslovu',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNovosti,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _novosti.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _novosti.length) {
                    return _buildNovostCard(_novosti[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
