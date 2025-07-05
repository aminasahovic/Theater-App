import 'dart:convert';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/predstave_screen.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška pri učitavanju izvedbi')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd.MM.yyyy. HH:mm').format(dt);
  }

  void _applyFilter() {
    _nazivFilter = _nazivController.text.trim();
    _loadIzvedbe();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Izvedbe predstava',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _nazivController,
              decoration: const InputDecoration(
                labelText: 'Pretraga po nazivu predstave',
                isDense: true,
              ),
              onChanged: (value) {
                _applyFilter();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                const Text(
                  'Izvedbe:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _zanrId,
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
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _zanrId = value);
                      _applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _izvedbe.isEmpty
                    ? const Center(
                      child: Text('Nema izvedbi za ovaj repertoar'),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadIzvedbe,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.6,
                            ),
                        itemCount: _izvedbe.length,
                        itemBuilder: (context, index) {
                          final izvedba = _izvedbe[index];
                          Widget plakatWidget;
                          if (izvedba.plakat != null &&
                              izvedba.plakat!.isNotEmpty) {
                            try {
                              final bytes = base64Decode(izvedba.plakat!);
                              plakatWidget = Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                              );
                            } catch (_) {
                              plakatWidget = Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              );
                            }
                          } else {
                            plakatWidget = Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image, size: 50),
                            );
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PredstavaScreen(
                                        predstavaId: izvedba.predstavaId,
                                        izvedbaId: izvedba.izvedbaId,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 3,
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: double.infinity,
                                    child: plakatWidget,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      12,
                                      12,
                                      16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          izvedba.nazivPredstave,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.brown.shade700,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(
                                            izvedba.datumVrijemeIzvedbe,
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
}
