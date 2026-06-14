import 'dart:convert';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/predstave_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/model.dart';
import '../services/api_service.dart';

class IzvedbaPredstavaScreen extends StatefulWidget {
  final int repertoarId;

  const IzvedbaPredstavaScreen({required this.repertoarId, super.key});

  @override
  State<IzvedbaPredstavaScreen> createState() => _IzvedbaPredstavaScreenState();
}

class _IzvedbaPredstavaScreenState extends State<IzvedbaPredstavaScreen> {
  List<IzvedbaPredstava> _izvedbe = [];
  List<Zanr> _zanrovi = [];
  String _nazivFilter = '';
  int? _zanrId;
  bool _isLoading = false;

  final _nazivController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadZanrovi();
    _loadIzvedbe();
  }

  Future<void> _loadZanrovi() async {
    try {
      final zanrovi = await ApiService.getZanrovi();
      setState(() => _zanrovi = zanrovi);
    } catch (e) {
      debugPrint('Greška pri dohvaćanju žanrova: $e');
    }
  }

  Future<void> _loadIzvedbe() async {
    setState(() => _isLoading = true);
    try {
      final rezultat = await ApiService.getIzvedbePoRepertoaru(
        widget.repertoarId,
        naziv: _nazivFilter,
        zanrId: _zanrId,
      );
      setState(() => _izvedbe = rezultat.resultList);
    } catch (e) {
      debugPrint('Greška pri učitavanju izvedbi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška pri učitavanju izvedbi')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime dt) => DateFormat('dd.MM.yyyy. HH:mm').format(dt);

  void _applyFilter() {
    _nazivFilter = _nazivController.text.trim();
    _loadIzvedbe();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Izvedbe predstava',
      Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _nazivController,
                  decoration: const InputDecoration(
                    hintText: 'Pretraži po nazivu...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (_) => _applyFilter(),
                ),
                const SizedBox(height: 10),

                // Genre dropdown
                DropdownButtonFormField<int>(
                  value: _zanrId,
                  decoration: const InputDecoration(
                    hintText: 'Svi žanrovi',
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Svi žanrovi'),
                    ),
                    ..._zanrovi.map(
                      (z) => DropdownMenuItem<int>(
                        value: z.id,
                        child: Text(z.naziv),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _zanrId = value);
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                    : _izvedbe.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: _loadIzvedbe,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.62,
                            ),
                        itemCount: _izvedbe.length,
                        itemBuilder:
                            (context, index) =>
                                _buildIzvedbaCard(_izvedbe[index]),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildIzvedbaCard(IzvedbaPredstava izvedba) {
    Widget plakatWidget;

    if (izvedba.plakat != null && izvedba.plakat!.isNotEmpty) {
      try {
        final bytes = base64Decode(izvedba.plakat!);
        plakatWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (_) {
        plakatWidget = _posterPlaceholder();
      }
    } else {
      plakatWidget = _posterPlaceholder();
    }

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PredstavaScreen(
                    predstavaId: izvedba.predstavaId,
                    izvedbaId: izvedba.izvedbaId,
                  ),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  plakatWidget,
                  // Date badge overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(izvedba.datumVrijemeIzvedbe),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      izvedba.nazivPredstave,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.placeholderGradient),
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 40, color: Colors.white24),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Nema izvedbi za ovaj repertoar',
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
