import 'dart:convert';
import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/screens/pregled_kupovine_screen.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/services/api_service.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OdabirSjedistaScreen extends StatefulWidget {
  final Izvedba izvedba;
  final Predstava predstava;

  const OdabirSjedistaScreen({
    super.key,
    required this.izvedba,
    required this.predstava,
  });

  @override
  State<OdabirSjedistaScreen> createState() => _OdabirSjedistaScreenState();
}

class _OdabirSjedistaScreenState extends State<OdabirSjedistaScreen> {
  List<IzvedbaSjediste> _sjedista = [];
  List<OdabranoSjediste> _selektovanaSjedista = [];
  bool _loading = true;

  // Seat colors
  static const Color colorFree = Color(0xFF1a7a42);
  static const Color colorTaken = Color(0xFFc0001e);
  static const Color colorSelected = Color(0xFF2a5c9a);

  @override
  void initState() {
    super.initState();
    _loadSjedista();
  }

  Future<void> _loadSjedista() async {
    try {
      final data = await ApiService.getSjedistaZaIzvedbu(widget.izvedba.id);
      setState(() {
        _sjedista = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Greška: $e');
      setState(() => _loading = false);
    }
  }

  void _toggleSelection(int sjedisteId, bool isSlobodno) {
    if (!isSlobodno) return;
    setState(() {
      final existing = _selektovanaSjedista.indexWhere(
        (s) => s.sjedisteId == sjedisteId,
      );
      if (existing >= 0) {
        _selektovanaSjedista.removeAt(existing);
      } else {
        _selektovanaSjedista.add(
          OdabranoSjediste(
            sjedisteId: sjedisteId,
            izvedbaId: widget.izvedba.id,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Odabir sjedišta',
      _loading
          ? const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          )
          : Column(
            children: [
              // Poster + info header
              _buildHeader(),

              // Stage label
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.darkBg2, AppTheme.primary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '— POZORNICA —',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ),

              // Seat grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 7,
                    crossAxisSpacing: 7,
                  ),
                  itemCount: _sjedista.length,
                  itemBuilder: (context, index) {
                    final s = _sjedista[index];
                    final isSelected = _selektovanaSjedista.any(
                      (sel) => sel.sjedisteId == s.sjedisteId,
                    );
                    final color =
                        !s.isSlobodno
                            ? colorTaken
                            : isSelected
                            ? colorSelected
                            : colorFree;

                    return GestureDetector(
                      onTap: () => _toggleSelection(s.sjedisteId, s.isSlobodno),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: colorSelected.withOpacity(0.4),
                                      blurRadius: 6,
                                    ),
                                  ]
                                  : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Legend
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _LegendChip(color: colorFree, label: 'Slobodno'),
                    SizedBox(width: 16),
                    _LegendChip(color: colorTaken, label: 'Zauzeto'),
                    SizedBox(width: 16),
                    _LegendChip(color: colorSelected, label: 'Označeno'),
                  ],
                ),
              ),

              // Bottom button
              _buildBottomButton(),
            ],
          ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Poster
        if (widget.predstava.plakat != null)
          Stack(
            children: [
              Image.memory(
                base64Decode(widget.predstava.plakat!),
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
              ),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.pageBackground.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ],
          ),

        // Info bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predstava.naziv,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'dd.MM.yyyy. HH:mm',
                      ).format(widget.izvedba.datumVrijemeIzvodjenja),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.izvedba.cijenaKarte.toStringAsFixed(2)} KM',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selected count bar
        if (_selektovanaSjedista.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: AppTheme.primary.withOpacity(0.06),
            child: Row(
              children: [
                const Icon(Icons.event_seat, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${_selektovanaSjedista.length} sjedišt${_selektovanaSjedista.length == 1 ? 'e' : 'a'} odabrano',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Ukupno: ${(widget.izvedba.cijenaKarte * _selektovanaSjedista.length).toStringAsFixed(2)} KM',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final count = _selektovanaSjedista.length;
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
                count == 0
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PregledKupovineScreen(
                              predstava: widget.predstava,
                              izvedba: widget.izvedba,
                              odabranaSjedista: _selektovanaSjedista,
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
                const Icon(Icons.shopping_cart_checkout_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  count == 0
                      ? 'Odaberite sjedišta'
                      : 'Nastavi ($count sjedišt${count == 1 ? 'e' : 'a'})',
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

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
