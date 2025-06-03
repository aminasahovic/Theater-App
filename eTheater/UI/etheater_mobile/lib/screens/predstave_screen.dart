import 'dart:convert';

import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/screens/master_screen.dart';
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
      final predstava = await ApiService.getPredstava(widget.predstavaId);
      final izvedba = await ApiService.getIzvedba(widget.izvedbaId);
      final glumci = await ApiService.getGlumciZaPredstavu(widget.predstavaId);

      setState(() {
        _predstava = predstava;
        _izvedba = izvedba;
        _glumci = glumci;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Greška: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri učitavanju podataka.')),
      );
    }
  }

  Future<void> _loadKomentari() async {
    if (_loadingKomentari) return;
    setState(() {
      _loadingKomentari = true;
    });

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
      setState(() {
        _loadingKomentari = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Detalji predstave',
      _loading || _predstava == null || _izvedba == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_predstava!.plakat != null &&
                          _predstava!.plakat!.isNotEmpty)
                        Image.memory(
                          base64Decode(_predstava!.plakat!),
                          width: double.infinity,
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _predstava!.naziv,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Datum i vrijeme: ${DateFormat('dd.MM.yyyy. HH:mm').format(_izvedba!.datumVrijemeIzvodjenja)}',
                            ),
                            Text('Trajanje: ${_predstava!.trajanje} min'),
                            Text('Godina: ${_predstava!.godina}'),
                            Text(
                              'Cijena: ${_izvedba!.cijenaKarte.toStringAsFixed(2)} KM',
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Opis:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _predstava!.opis,
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 24),
                            if (_glumci.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Glumci:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 230,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _glumci.length,
                                      itemBuilder: (context, index) {
                                        return _buildGlumacCard(_glumci[index]);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 50),

                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          return OcijeniPredstavuSheet(
                                            predstavaId: widget.predstavaId,
                                            onKomentarPoslan: () {
                                              setState(() {
                                                _komentari.clear();
                                                _currentPage = 1;
                                              });
                                              _loadKomentari();
                                            },
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.star),
                                    label: const Text('Ocijeni predstavu'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[800],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),

                                  SizedBox(height: 50),
                                  if (_komentari.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Komentari:',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ..._komentari.map(
                                          (k) => _buildKomentarCard(k),
                                        ),
                                        if (_komentari.length <
                                            _ukupnoKomentara)
                                          Center(
                                            child: TextButton.icon(
                                              onPressed: _loadKomentari,
                                              icon: const Icon(Icons.comment),
                                              label: const Text(
                                                'Učitaj još komentara',
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OdabirSjedistaScreen(
                                  predstava: _predstava!,
                                  izvedba: _izvedba!,
                                ),
                          ),
                        );
                      },
                      child: const Text(
                        'Rezerviši',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

Widget _buildGlumacCard(GlumacPredstava glumac) {
  return Container(
    width: 150,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child:
              glumac.slika != null && glumac.slika!.isNotEmpty
                  ? Image.memory(
                    base64Decode(glumac.slika!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60),
                  ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                '${glumac.ime} ${glumac.prezime}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                glumac.uloga,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildKomentarCard(KomentarPredstava komentar) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(child: Icon(Icons.person), radius: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${komentar.imeKorisnika} ${komentar.prezimeKorisnika}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(komentar.komentar),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd.MM.yyyy. HH:mm').format(komentar.datum),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class OcijeniPredstavuSheet extends StatefulWidget {
  final int predstavaId;
  final VoidCallback onKomentarPoslan;

  const OcijeniPredstavuSheet({
    super.key,
    required this.predstavaId,
    required this.onKomentarPoslan,
  });

  @override
  State<OcijeniPredstavuSheet> createState() => _OcijeniPredstavuSheetState();
}

class _OcijeniPredstavuSheetState extends State<OcijeniPredstavuSheet> {
  int _ocjena = 0;
  final TextEditingController _komentarController = TextEditingController();
  bool _loading = false;

  void _posaljiKomentar() async {
    if (_ocjena == 0 || _komentarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite ocjenu i komentar.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final komentar = InsertKomentarPredstava(
        predstavaId: widget.predstavaId,
        ocjena: _ocjena,
        komentar: _komentarController.text.trim(),
        korisnikId: AuthProvider.userId!,
        datum: DateTime.now(),
      );

      await ApiService.addKomentarPredstava(komentar: komentar);
      Navigator.of(context).pop();
      widget.onKomentarPoslan();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Komentar uspješno poslan!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ocijeni predstavu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final i = index + 1;
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: i <= _ocjena ? Colors.amber : Colors.grey[400],
                  size: 32,
                ),
                onPressed: () => setState(() => _ocjena = i),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _komentarController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Unesite komentar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _posaljiKomentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pošalji'),
            ),
          ),
        ],
      ),
    );
  }
}
