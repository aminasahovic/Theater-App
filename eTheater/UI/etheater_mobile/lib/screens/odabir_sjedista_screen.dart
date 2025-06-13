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
      "Odabir sjedišta",
      _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              if (widget.predstava.plakat != null)
                Image.memory(
                  base64Decode(widget.predstava.plakat!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predstava.naziv,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vrijeme: ${DateFormat('dd.MM.yyyy. HH:mm').format(widget.izvedba.datumVrijemeIzvodjenja)}',
                    ),
                    Text(
                      'Cijena: ${widget.izvedba.cijenaKarte.toStringAsFixed(2)} KM',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _LegendBox(color: Colors.green, label: "Slobodno"),
                        _LegendBox(color: Colors.red, label: "Zauzeto"),
                        _LegendBox(color: Colors.blue, label: "Označeno"),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _sjedista.length,
                  itemBuilder: (context, index) {
                    final sjediste = _sjedista[index];
                    final isSelected = _selektovanaSjedista.any(
                      (s) => s.sjedisteId == sjediste.sjedisteId,
                    );

                    Color color;
                    if (!sjediste.isSlobodno) {
                      color = Colors.red;
                    } else if (isSelected) {
                      color = Colors.blue;
                    } else {
                      color = Colors.green;
                    }

                    return GestureDetector(
                      onTap:
                          () => _toggleSelection(
                            sjediste.sjedisteId,
                            sjediste.isSlobodno,
                          ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PregledKupovineScreen(
                              predstava: widget.predstava,
                              izvedba: widget.izvedba,
                              odabranaSjedista: _selektovanaSjedista,
                            ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Rezervisi"),
                ),
              ),
            ],
          ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 20, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
