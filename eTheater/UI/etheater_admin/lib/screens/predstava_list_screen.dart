import 'dart:convert';
import 'dart:typed_data';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/delete_utils.dart';
import 'package:etheater_admin/screens/dodaj_predstavu_dialog.dart';
import 'package:etheater_admin/screens/predstava_details_screen.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class PredstaveScreen extends StatefulWidget {
  const PredstaveScreen({super.key});

  @override
  State<PredstaveScreen> createState() => _PredstaveScreenState();
}

class _PredstaveScreenState extends State<PredstaveScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Predstava> _svePredstave = [];
  List<Predstava> _filtriranePredstave = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterPredstave);
  }

  Future<void> _fetchData() async {
    try {
      final data = await _apiService.getPredstave();
      setState(() {
        _svePredstave = data;
        _filtriranePredstave = data;
      });
    } catch (e) {
      print('Greška prilikom dohvaćanja predstava: $e');
    }
  }

  void _filterPredstave() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtriranePredstave =
          _svePredstave
              .where((p) => p.naziv.toLowerCase().contains(query))
              .toList();
    });
  }

  Widget _buildPlakat(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      return Container(
        width: 200,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey[700],
        ),
      );
    }

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          base64Decode(base64Image),
          width: 200,
          height: 350,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey[700]),
      );
    }
  }

  Widget _buildPredstavaCard(Predstava predstava) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlakat(predstava.plakat),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    predstava.naziv,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    predstava.opis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.brown),
                      const SizedBox(width: 4),
                      Text('${predstava.trajanje} min'),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 16, color: Colors.brown),
                      const SizedBox(width: 4),
                      Text('${predstava.godina}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        predstava.isActive ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: predstava.isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(predstava.isActive ? 'Aktivna' : 'Neaktivna'),
                    ],
                  ),
                  const SizedBox(height: 180),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PredstavaDetailsScreen(
                                    predstava: predstava,
                                  ),
                            ),
                          );
                        },
                        icon: Icon(Icons.info_outline, color: Colors.blue),
                        label: Text('Detalji'),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed:
                            () => showDeleteConfirmationDialog(
                              context: context,
                              predstavaId: predstava.id!,
                              onDeleted: _fetchData,
                            ),
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        label: Text('Obriši'),
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Pregled Predstava',
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pretraži predstave...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => _filterPredstave(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _otvoriDodajPredstavuDialog,
                  child: const Text('Dodaj predstavu'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _filtriranePredstave.isEmpty
                      ? const Center(child: Text('Nema pronađenih predstava.'))
                      : ListView.builder(
                        itemCount: _filtriranePredstave.length,
                        itemBuilder: (context, index) {
                          return _buildPredstavaCard(
                            _filtriranePredstave[index],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _otvoriDodajPredstavuDialog() async {
    final bool? dodano = await showDialog<bool>(
      context: context,
      builder: (context) => const DodajPredstavuDialog(),
    );

    if (dodano == true) {
      await _fetchData();
    }
  }
}
