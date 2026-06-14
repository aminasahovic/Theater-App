import 'dart:convert';
import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/ocijeni_predstavu_sheet.dart';
import 'package:etheater_mobile/screens/odabir_sjedista_screen.dart';
import 'package:etheater_mobile/services/api_service.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PredstavaScreen extends StatefulWidget {
  final int predstavaId;
  final int izvedbaId;

  const PredstavaScreen({
    required this.predstavaId,
    required this.izvedbaId,
    super.key,
  });

  @override
  State<PredstavaScreen> createState() => _PredstavaDetaljiScreenState();
}

class _PredstavaDetaljiScreenState extends State<PredstavaScreen> {
  Predstava? _predstava;
  Izvedba? _izvedba;
  bool _loading = true;
  List<GlumacPredstava> _glumci = [];

  int _currentPage = 1;
  final int _pageSize = 3;
  bool _loadingKomentari = false;
  List<KomentarPredstava> _komentari = [];
  int _ukupnoKomentara = 0;

  @override
  void initState() {
    super.initState();
    _loadPodaci().then((_) => _loadKomentari());
  }

  Future<void> _loadPodaci() async {
    try {
      final results = await Future.wait([
        ApiService.getPredstava(widget.predstavaId),
        widget.izvedbaId != 0
            ? ApiService.getIzvedba(widget.izvedbaId)
            : Future.value(null),
        ApiService.getGlumciZaPredstavu(widget.predstavaId),
      ]);
      setState(() {
        _predstava = results[0] as Predstava;
        _izvedba = results[1] as Izvedba?;
        _glumci = results[2] as List<GlumacPredstava>;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Greška: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Greška pri učitavanju podataka.')),
        );
      }
    }
  }

  Future<void> _loadKomentari() async {
    if (_loadingKomentari) return;
    setState(() => _loadingKomentari = true);
    try {
      final response = await ApiService.getKomentariZaPredstavu(
        widget.predstavaId,
        _currentPage,
        _pageSize,
      );
      setState(() {
        _komentari.addAll(response.resultList);
        _ukupnoKomentara = response.count;
        _currentPage++;
      });
    } catch (e) {
      debugPrint('Greška pri učitavanju komentara: $e');
    } finally {
      setState(() => _loadingKomentari = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Detalji predstave',
      _loading || _predstava == null
          ? const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          )
          : Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero poster
                    _buildHeroPoster(),

                    // Info section
                    _buildInfoSection(),

                    // Divider
                    const Divider(height: 1, indent: 20, endIndent: 20),

                    // Actors
                    if (_glumci.isNotEmpty) _buildActorsSection(),

                    // Rating button
                    _buildRatingButton(),

                    // Comments
                    if (_komentari.isNotEmpty) _buildCommentsSection(),
                  ],
                ),
              ),

              // Sticky bottom button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(),
              ),
            ],
          ),
    );
  }

  Widget _buildHeroPoster() {
    if (_predstava!.plakat == null || _predstava!.plakat!.isEmpty) {
      return Container(
        height: 280,
        decoration: const BoxDecoration(gradient: AppTheme.placeholderGradient),
        child: const Center(
          child: Icon(Icons.movie_outlined, size: 64, color: Colors.white24),
        ),
      );
    }

    return Stack(
      children: [
        Image.memory(
          base64Decode(_predstava!.plakat!),
          width: double.infinity,
          height: 320,
          fit: BoxFit.cover,
        ),
        // Bottom fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.pageBackground.withOpacity(0.9),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _predstava!.naziv,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Info chips row
          if (_izvedba != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: DateFormat(
                    'dd.MM.yyyy. HH:mm',
                  ).format(_izvedba!.datumVrijemeIzvodjenja),
                ),
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: '${_predstava!.trajanje} min',
                ),
                _InfoChip(
                  icon: Icons.movie_creation_outlined,
                  label: '${_predstava!.godina}',
                ),
                _InfoChip(
                  icon: Icons.local_activity_outlined,
                  label: '${_izvedba!.cijenaKarte.toStringAsFixed(2)} KM',
                  highlight: true,
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFfff0f0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 15, color: AppTheme.danger),
                  SizedBox(width: 6),
                  Text(
                    'Trenutno nije na repertoaru',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Description
          const Text(
            'Opis',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _predstava!.opis,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildActorsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Text(
              'Glumci',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _glumci.length,
              padding: const EdgeInsets.only(right: 20),
              itemBuilder: (_, i) => _buildGlumacCard(_glumci[i]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGlumacCard(GlumacPredstava glumac) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Photo
          glumac.slika != null && glumac.slika!.isNotEmpty
              ? Image.memory(
                base64Decode(glumac.slika!),
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              )
              : Container(
                height: 110,
                decoration: const BoxDecoration(
                  gradient: AppTheme.placeholderGradient,
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white38,
                ),
              ),
          // Name & role
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              children: [
                Text(
                  '${glumac.ime} ${glumac.prezime}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  glumac.uloga,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: OutlinedButton.icon(
        onPressed:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder:
                  (_) => OcijeniPredstavuSheet(
                    predstavaId: widget.predstavaId,
                    onKomentarPoslan: () {
                      setState(() {
                        _komentari.clear();
                        _currentPage = 1;
                      });
                      _loadKomentari();
                    },
                  ),
            ),
        icon: const Icon(Icons.star_outline, size: 18),
        label: const Text('Ocijeni predstavu'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.amber,
          side: BorderSide(color: AppTheme.amber.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(
            'Komentari (${_ukupnoKomentara})',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._komentari.map((k) => _buildKomentarCard(k)),
          if (_komentari.length < _ukupnoKomentara)
            _loadingKomentari
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
                : Center(
                  child: TextButton.icon(
                    onPressed: _loadKomentari,
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Učitaj još komentara'),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildKomentarCard(KomentarPredstava komentar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accentTint,
            child: Text(
              komentar.imeKorisnika.isNotEmpty
                  ? komentar.imeKorisnika[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${komentar.imeKorisnika} ${komentar.prezimeKorisnika}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  komentar.komentar,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd.MM.yyyy. HH:mm').format(komentar.datum),
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                _izvedba == null
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => OdabirSjedistaScreen(
                              predstava: _predstava!,
                              izvedba: _izvedba!,
                            ),
                      ),
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_seat_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  _izvedba == null ? 'Nije na repertoaru' : 'Rezerviši kartu',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.accentTint : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: highlight ? AppTheme.primary : AppTheme.textMuted,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
