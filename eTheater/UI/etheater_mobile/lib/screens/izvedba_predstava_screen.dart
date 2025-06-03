import 'dart:convert';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadIzvedbe();
  }

  Future<void> _loadIzvedbe() async {
    setState(() => _isLoading = true);
    try {
      final izvedbe = await ApiService.getIzvedbePoRepertoaru(
        widget.repertoarId,
      );
      setState(() {
        _izvedbe = izvedbe;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Izvedbe predstava'),
        backgroundColor: const Color(0xFF6A1B1B),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _izvedbe.isEmpty
              ? const Center(child: Text('Nema izvedbi za ovaj repertoar'))
              : RefreshIndicator(
                onRefresh: _loadIzvedbe,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: _izvedbe.length,
                  itemBuilder: (context, index) {
                    final izvedba = _izvedbe[index];

                    Widget plakatWidget;
                    if (izvedba.plakat != null && izvedba.plakat!.isNotEmpty) {
                      try {
                        final bytes = base64Decode(izvedba.plakat!);
                        plakatWidget = Image.memory(bytes, fit: BoxFit.cover);
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    _formatDate(izvedba.datumVrijemeIzvedbe),
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
    );
  }
}
