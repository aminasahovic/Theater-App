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
  final _formKey = GlobalKey<FormState>();

  Predstava? _predstava;
  late TextEditingController _nazivController;
  late TextEditingController _opisController;
  late TextEditingController _trajanjeController;
  late TextEditingController _godinaController;
  bool _isActive = false;

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
    _nazivController = TextEditingController();
    _opisController = TextEditingController();
    _trajanjeController = TextEditingController();
    _godinaController = TextEditingController();

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
        _isActive = fetchedPredstava.isActive;

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

        setState(() {});
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
    _glumci = await ApiService.fetchGlumciZaPredstavu(_predstava!.id);
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedPredstava = Predstava(
      id: _editedPredstava.id,
      naziv: _nazivController.text,
      opis: _opisController.text,
      trajanje: int.parse(_trajanjeController.text),
      godina: int.parse(_godinaController.text),
      plakat: _plakatBase64 ?? _editedPredstava.plakat,
      isActive: _isActive,
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
    if (_predstava == null) {
      return Center(child: CircularProgressIndicator());
    }

    return MasterScreen(
      'Detalji predstave',
      Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlakat(),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isEditing) _buildEditDeleteButtons(),
                          _buildValidatedInputField(
                            'Naziv',
                            _nazivController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Naziv je obavezan';
                              }
                              if (!RegExp(r'^[A-ZČĆŽŠĐ]').hasMatch(value)) {
                                return 'Naziv mora početi velikim slovom';
                              }
                              return null;
                            },
                          ),
                          _buildValidatedInputField(
                            'Opis',
                            _opisController,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Opis je obavezan';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildValidatedInputField(
                                  'Trajanje',
                                  _trajanjeController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Trajanje je obavezno';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Trajanje mora biti broj';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildValidatedInputField(
                                  'Godina',
                                  _godinaController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Godina je obavezna';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Godina mora biti broj';
                                    }
                                    if (value.length != 4) {
                                      return 'Godina mora imati 4 cifre';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  'Žanr',
                                  _zanrovi,
                                  _editedPredstava.zanrId,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  'Režiser',
                                  _reziseri,
                                  _editedPredstava.reziserId,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          SwitchListTile(
                            title: Text('Aktivna predstava'),
                            value: _isActive,
                            onChanged:
                                _isEditing
                                    ? (bool val) {
                                      setState(() {
                                        _isActive = val;
                                      });
                                    }
                                    : null,
                          ),

                          TextButton.icon(
                            onPressed: _isEditing ? _odaberiSliku : null,
                            icon: Icon(Icons.image),
                            label: Text('Odaberi sliku'),
                          ),
                          if (_isEditing) _buildSaveCancelButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  'Glumačka postava',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children:
                      _glumci.map((glumac) {
                        Uint8List? slikaBytes;
                        if (glumac.slika != null && glumac.slika!.isNotEmpty) {
                          try {
                            slikaBytes = base64Decode(glumac.slika!);
                          } catch (_) {}
                        }

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child:
                                    slikaBytes != null
                                        ? Image.memory(
                                          slikaBytes,
                                          fit: BoxFit.cover,
                                          height: 260,
                                          width: double.infinity,
                                          color: Colors.black.withOpacity(0.1),
                                          colorBlendMode: BlendMode.darken,
                                        )
                                        : Container(
                                          height: 260,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.person_outline,
                                            size: 70,
                                            color: Colors.grey,
                                          ),
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Text(
                                      '${glumac.ime} ${glumac.prezime}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      glumac.uloga,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        enabled: _isEditing,
        validator: validator,
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
      height: 460,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child:
            _slikaBytes != null
                ? Image.memory(_slikaBytes!, fit: BoxFit.cover)
                : Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSaveCancelButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.close_outlined),
            label: const Text('Otkaži'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Sačuvaj'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _spasi,
          ),
        ],
      ),
    );
  }

  Widget _buildEditDeleteButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Obriši'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                _isEditing
                    ? null
                    : () async {
                      await showDeleteConfirmationDialog(
                        context: context,
                        predstavaId: widget.predstavaId,
                        onDeleted: _onPredstavaDeleted,
                      );
                    },
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Uredi'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed:
                _isEditing
                    ? null
                    : () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Nova predstava'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isEditing ? null : _otvoriDodajPredstavuDialog,
          ),
        ],
      ),
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
