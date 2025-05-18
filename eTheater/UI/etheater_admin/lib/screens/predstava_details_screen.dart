import 'dart:convert';
import 'dart:typed_data';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/delete_utils.dart';
import 'package:etheater_admin/screens/dodaj_predstavu_dialog.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PredstavaDetailsScreen extends StatefulWidget {
  final int predstavaId;

  const PredstavaDetailsScreen({super.key, required this.predstavaId});

  @override
  // ignore: library_private_types_in_public_api
  _PredstavaDetailsScreenState createState() => _PredstavaDetailsScreenState();
}

class _PredstavaDetailsScreenState extends State<PredstavaDetailsScreen> {
  bool _isLoading = true;
  Predstava? _predstava;
  late TextEditingController _nazivController;
  late TextEditingController _opisController;
  late TextEditingController _trajanjeController;
  late TextEditingController _godinaController;

  bool _isEditing = false;
  String? _plakatBase64;
  Uint8List? _slikaBytes;

  late Predstava _editedPredstava;

  List<Zanr> _zanrovi = [];
  List<Reziser> _reziseri = [];
  List<GlumacPredstava> _glumci = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedPredstava = await ApiService().getPredstavaById(
        widget.predstavaId,
      );

      setState(() {
        _predstava = fetchedPredstava;
        _nazivController = TextEditingController(text: fetchedPredstava.naziv);
        _opisController = TextEditingController(text: fetchedPredstava.opis);
        _trajanjeController = TextEditingController(
          text: fetchedPredstava.trajanje.toString(),
        );
        _godinaController = TextEditingController(
          text: fetchedPredstava.godina.toString(),
        );
        _plakatBase64 = fetchedPredstava.plakat;

        if (_plakatBase64 != null && _plakatBase64!.isNotEmpty) {
          try {
            _slikaBytes = base64Decode(_plakatBase64!);
          } catch (_) {}
        }

        _editedPredstava = Predstava(
          id: fetchedPredstava.id,
          naziv: fetchedPredstava.naziv,
          opis: fetchedPredstava.opis,
          trajanje: fetchedPredstava.trajanje,
          godina: fetchedPredstava.godina,
          plakat: fetchedPredstava.plakat,
          isActive: fetchedPredstava.isActive,
          zanrId: fetchedPredstava.zanrId,
          reziserId: fetchedPredstava.reziserId,
        );

        setState(() {
          _isLoading = false;
        });
      });

      await _fetchZanrovi();
      await _fetchReziseri();
      await _fetchGlumci();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri učitavanju predstave')),
      );
    }
  }

  @override
  void dispose() {
    _nazivController.dispose();
    _opisController.dispose();
    _trajanjeController.dispose();
    _godinaController.dispose();
    super.dispose();
  }

  Future<void> _fetchZanrovi() async {
    _zanrovi = await ApiService.fetchZanrovi();
    setState(() {});
  }

  Future<void> _fetchReziseri() async {
    _reziseri = await ApiService.fetchReziseri();
    setState(() {});
  }

  Future<void> _fetchGlumci() async {
    if (_predstava == null) return;
    _glumci = await ApiService.fetchGlumciZaPredstavu(_predstava!.id!);
    setState(() {});
  }

  Future<void> _odaberiSliku() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      setState(() {
        _slikaBytes = bytes;
        _plakatBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _spasi() async {
    final updatedPredstava = Predstava(
      id: _editedPredstava.id,
      naziv: _nazivController.text,
      opis: _opisController.text,
      trajanje: int.tryParse(_trajanjeController.text) ?? 0,
      godina: int.tryParse(_godinaController.text) ?? 0,
      plakat: _plakatBase64 ?? _editedPredstava.plakat,
      isActive: _editedPredstava.isActive,
      zanrId: _editedPredstava.zanrId,
      reziserId: _editedPredstava.reziserId,
    );

    try {
      await ApiService.updatePredstava(updatedPredstava);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Podaci su uspešno ažurirani')));
      setState(() {
        _isEditing = false;
        _editedPredstava = updatedPredstava;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greška pri ažuriranju')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Detalji predstave',
      Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlakat(),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isEditing) _buildEditDeleteButtons(),
                        _buildInputField('Naziv', _nazivController),
                        _buildInputField('Opis', _opisController, maxLines: 3),
                        _buildInputField('Trajanje', _trajanjeController),
                        _buildInputField('Godina', _godinaController),
                        _buildDropdown(
                          'Žanr',
                          _zanrovi,
                          _editedPredstava.zanrId,
                        ),
                        _buildDropdown(
                          'Režiser',
                          _reziseri,
                          _editedPredstava.reziserId,
                        ),
                        SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _isEditing ? _odaberiSliku : null,
                          icon: Icon(Icons.image),
                          label: Text('Odaberi sliku'),
                        ),
                        SizedBox(height: 20),
                        if (_isEditing) _buildSaveCancelButtons(),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Glumačka postava',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    _glumci.map((glumac) {
                      final slika = glumac.slika;
                      Uint8List? slikaBytes;
                      if (slika != null && slika.isNotEmpty) {
                        try {
                          slikaBytes = base64Decode(slika);
                        } catch (_) {}
                      }

                      return Container(
                        width: 150,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child:
                                    slikaBytes != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8),
                                          ),
                                          child: Image.memory(
                                            slikaBytes,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '${glumac.ime} ${glumac.prezime}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      glumac.uloga,
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildDropdown(String label, List<dynamic> items, int selectedId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        value: selectedId,
        decoration: InputDecoration(labelText: label),
        items:
            items.map<DropdownMenuItem<int>>((item) {
              return DropdownMenuItem<int>(
                value: item.id,
                child: Text(
                  label == 'Žanr' ? item.naziv : '${item.ime} ${item.prezime}',
                ),
              );
            }).toList(),
        onChanged:
            _isEditing
                ? (value) {
                  if (value == null) return;
                  setState(() {
                    _editedPredstava = Predstava(
                      id: _editedPredstava.id,
                      naziv: _editedPredstava.naziv,
                      opis: _editedPredstava.opis,
                      trajanje: _editedPredstava.trajanje,
                      godina: _editedPredstava.godina,
                      plakat: _editedPredstava.plakat,
                      isActive: _editedPredstava.isActive,
                      zanrId: label == 'Žanr' ? value : _editedPredstava.zanrId,
                      reziserId:
                          label == 'Režiser'
                              ? value
                              : _editedPredstava.reziserId,
                    );
                  });
                }
                : null,
      ),
    );
  }

  Widget _buildPlakat() {
    return Container(
      width: 320,
      height: 450,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.grey[200],
      ),
      child:
          _slikaBytes != null
              ? Image.memory(_slikaBytes!, fit: BoxFit.cover)
              : Center(child: Icon(Icons.image_not_supported, size: 40)),
    );
  }

  Widget _buildSaveCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _isEditing = false;
              _plakatBase64 = _editedPredstava.plakat;
              _slikaBytes =
                  (_plakatBase64 != null && _plakatBase64!.isNotEmpty)
                      ? base64Decode(_plakatBase64!)
                      : null;
            });
          },
          child: Text('Otkaži'),
        ),
        SizedBox(width: 10),
        ElevatedButton(onPressed: _spasi, child: Text('Spasi')),
      ],
    );
  }

  Widget _buildEditDeleteButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.black),
          onPressed: () async {
            final confirmed = await showDeleteConfirmationDialog(
              context: context,
              predstavaId: widget.predstavaId,
              onDeleted: _onPredstavaDeleted,
            );
          },
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.black),

          onPressed: () => setState(() => _isEditing = true),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.add, color: Colors.black),

          onPressed: _otvoriDodajPredstavuDialog,
        ),
      ],
    );
  }

  void _otvoriDodajPredstavuDialog() async {
    final bool? dodano = await showDialog<bool>(
      context: context,
      builder: (context) => const DodajPredstavuDialog(),
    );
  }

  void _onPredstavaDeleted() {
    Navigator.of(context).pop();
  }
}
