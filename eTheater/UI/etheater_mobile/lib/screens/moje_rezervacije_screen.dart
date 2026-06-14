import 'dart:convert';
import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/ocijeni_predstavu_sheet.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MojeRezervacijeScreen extends StatefulWidget {
  const MojeRezervacijeScreen({super.key});

  @override
  State<MojeRezervacijeScreen> createState() => _MojeRezervacijeScreenState();
}

class _MojeRezervacijeScreenState extends State<MojeRezervacijeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<MojaRezervacija> _rezervacije = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _filterNaziv = '';
  bool _filterAktivne = true;
  String? _errorMessage;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy. HH:mm');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetAndLoad();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) _loadRezervacije();
      }
    });

    _searchController.addListener(() {
      final filter = _searchController.text.trim();
      if (filter != _filterNaziv) {
        _filterNaziv = filter;
        _resetAndLoad();
      }
    });
  }

  Future<void> _resetAndLoad() async {
    setState(() {
      _rezervacije.clear();
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = null;
    });
    await _loadRezervacije();
  }

  Future<void> _loadRezervacije() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getMojeRezervacije(
        korisnikId: AuthProvider.userId ?? 0,
        nazivPredstave: _filterNaziv,
        aktivne: _filterAktivne,
        isUsedTicket: !_filterAktivne,
        page: _currentPage,
        pageSize: 4,
      );

      setState(() {
        _errorMessage = null;
        _rezervacije = [..._rezervacije, ...result.resultList];
        _currentPage++;
        _hasMore = _rezervacije.length < result.count;
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('Greška pri učitavanju rezervacija: $e\n$st');

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildPoster(String? plakatUrl) {
    if (plakatUrl != null && plakatUrl.isNotEmpty) {
      try {
        final raw =
            plakatUrl.contains(',') ? plakatUrl.split(',')[1] : plakatUrl;
        final bytes = base64Decode(raw);
        return Image.memory(bytes, fit: BoxFit.cover, width: 110, height: 160);
      } catch (_) {}
    }
    return Container(
      width: 110,
      height: 160,
      decoration: const BoxDecoration(gradient: AppTheme.placeholderGradient),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white30, size: 32),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            const Text(
              'Greška pri učitavanju',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _resetAndLoad,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      ),
    );
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
      'Moje rezervacije',
      Column(
        children: [
          // Filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Pretraži po nazivu predstave...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Toggle active/past
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pageBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _ToggleTab(
                        label: 'Aktivne',
                        icon: Icons.event_available_outlined,
                        active: _filterAktivne,
                        onTap: () {
                          if (!_filterAktivne) {
                            setState(() => _filterAktivne = true);
                            _resetAndLoad();
                          }
                        },
                      ),
                      _ToggleTab(
                        label: 'Iskorištene',
                        icon: Icons.history_outlined,
                        active: !_filterAktivne,
                        onTap: () {
                          if (_filterAktivne) {
                            setState(() => _filterAktivne = false);
                            _resetAndLoad();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child:
                _isLoading && _rezervacije.isEmpty
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                    : _errorMessage != null
                    ? _buildErrorState(_errorMessage!)
                    : _rezervacije.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: _rezervacije.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _rezervacije.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }
                        return _buildRezervacijaCard(_rezervacije[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildRezervacijaCard(MojaRezervacija rez) {
    final bool isPast = rez.isUsedTicket;
    final bool canCancel =
        rez.datumVrijemeIzvedbe.isAfter(DateTime.now()) && !rez.isKupljeno;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster strip - fiksna visina i širina
          SizedBox(width: 110, height: 200, child: _buildPoster(rez.plakatUrl)),

          // Dashed separator - fiksna visina
          SizedBox(
            width: 1,
            height: 200,
            child: CustomPaint(painter: _DashPainter()),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status chip
                  Row(
                    children: [
                      _StatusChip(
                        label: isPast ? 'Iskorištena' : 'Aktivna',
                        color: isPast ? AppTheme.textMuted : AppTheme.success,
                        bg: isPast ? Colors.grey.shade100 : AppTheme.successBg,
                      ),
                      if (rez.isKupljeno) ...[
                        const SizedBox(width: 6),
                        _StatusChip(
                          label: 'Plaćena',
                          color: AppTheme.primary,
                          bg: AppTheme.accentTint,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    rez.naziv ?? 'Nepoznata predstava',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Details
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _dateFormat.format(rez.datumVrijemeIzvedbe),
                  ),
                  const SizedBox(height: 3),
                  _InfoRow(
                    icon: Icons.place_outlined,
                    text: rez.nazivSale ?? '-',
                  ),
                  const SizedBox(height: 3),
                  _InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    text:
                        '${rez.brojKarata} kart${rez.brojKarata == 1 ? 'a' : 'e'}',
                  ),

                  // Actions
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (rez.isKupljeno && _filterAktivne)
                        _ActionButton(
                          label: 'QR kod',
                          icon: Icons.qr_code_2,
                          onTap: () => _showQrDialog(rez.id.toString()),
                        ),
                      if (isPast)
                        _ActionButton(
                          label: 'Ocijeni',
                          icon: Icons.star_outline,
                          onTap:
                              () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder:
                                    (_) => OcijeniPredstavuSheet(
                                      predstavaId: rez.predstavaId,
                                      onKomentarPoslan: () {},
                                    ),
                              ),
                        ),
                      if (canCancel)
                        _ActionButton(
                          label: 'Otkaži',
                          icon: Icons.cancel_outlined,
                          danger: true,
                          onTap: () => _confirmCancel(rez),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(MojaRezervacija rez) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Otkazati rezervaciju?'),
            content: Text(
              'Jeste li sigurni da želite otkazati rezervaciju za "${rez.naziv}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ne'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Da, otkaži'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      try {
        final success = await ApiService.obrisiRezervaciju(rez.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Rezervacija uspješno otkazana.'
                    : 'Neuspjelo otkazivanje rezervacije.',
              ),
              backgroundColor: success ? AppTheme.success : AppTheme.danger,
            ),
          );
        }
        if (success) _resetAndLoad();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Greška: $e'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    }
  }

  void _showQrDialog(String id) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accentTint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Vaš QR kod',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pokažite ga na ulazu u pozorište',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: QrImageView(
                      data: id,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Zatvori'),
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
          Icon(
            Icons.confirmation_number_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            _filterAktivne
                ? 'Nemate aktivnih rezervacija'
                : 'Nema iskorištenih karata',
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

class _ToggleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow:
                active
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppTheme.primary : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? AppTheme.primary : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.textMuted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
                danger
                    ? AppTheme.danger.withOpacity(0.08)
                    : AppTheme.accentTint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  danger
                      ? AppTheme.danger.withOpacity(0.3)
                      : AppTheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: danger ? AppTheme.danger : AppTheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: danger ? AppTheme.danger : AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 6.0;
    const gap = 4.0;
    final paint =
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 1.5;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashH), paint);
      y += dashH + gap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
