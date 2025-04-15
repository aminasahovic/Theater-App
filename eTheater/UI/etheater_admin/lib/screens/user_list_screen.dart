import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/delete_utils.dart';
import 'package:etheater_admin/screens/dodaj_korisnika_dialog.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  List<Korisnik> _korisnici = [];
  List<TipKorisnika> _tipoviKorisnika = [];

  int _currentPage = 0;
  int _rowsPerPage = 5;
  int _totalCount = 0;

  final TextEditingController _imeController = TextEditingController();
  final TextEditingController _prezimeController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  TipKorisnika? _odabraniTip;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTipoviKorisnika();
    _fetchKorisnici();
  }

  void _loadTipoviKorisnika() async {
    try {
      final tipovi = await _apiService.getTipoviKorisnika();
      setState(() {
        _tipoviKorisnika = tipovi;
      });
    } catch (e) {
      print("Greška pri učitavanju tipova korisnika: $e");
    }
  }

  void _fetchKorisnici() async {
    setState(() => _isLoading = true);
    try {
      final (korisnici, count) = await _apiService.getKorisniciFiltered(
        ime: _imeController.text,
        prezime: _prezimeController.text,
        username: _usernameController.text,
        tipKorisnikaId: _odabraniTip?.id,
        page: _currentPage + 1,
        pageSize: _rowsPerPage,
      );
      setState(() {
        _korisnici = korisnici;
        _totalCount = count;
      });
    } catch (e) {
      print("Greška pri dohvaćanju korisnika: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 0;
    });
    _fetchKorisnici();
  }

  void _resetFilters() {
    setState(() {
      _imeController.clear();
      _prezimeController.clear();
      _usernameController.clear();
      _odabraniTip = null;
    });
    _fetchKorisnici();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administracija korisnika')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                  child: SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: const Text("Lista korisnika"),
                      rowsPerPage: _rowsPerPage,
                      availableRowsPerPage: const [5, 10, 20],
                      onRowsPerPageChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _rowsPerPage = value;
                            _currentPage = 0;
                          });
                          _fetchKorisnici();
                        }
                      },
                      onPageChanged: (start) {
                        final newPage = (start / _rowsPerPage).floor();
                        if (newPage != _currentPage) {
                          setState(() {
                            _currentPage = newPage;
                          });
                          _fetchKorisnici();
                        }
                      },
                      columns: const [
                        DataColumn(label: Text('Ime')),
                        DataColumn(label: Text('Prezime')),
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Telefon')),
                        DataColumn(label: Text('Tip')),
                        DataColumn(label: Text('Akcije')),
                      ],
                      source: _KorisniciDataSource(
                        _korisnici,
                        context,
                        _resetAndFetch,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Korisnici',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Dodaj korisnika"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF800020),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await showDialog(
              context: context,
              builder:
                  (_) => DodajKorisnikaDialog(onKorisnikDodan: _resetAndFetch),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildFilterField(_imeController, 'Ime'),
        _buildFilterField(_prezimeController, 'Prezime'),
        _buildFilterField(_usernameController, 'Korisničko ime'),
        SizedBox(
          width: 250,
          child: DropdownButtonFormField<TipKorisnika>(
            decoration: const InputDecoration(
              labelText: 'Tip korisnika',
              border: OutlineInputBorder(),
            ),
            value: _odabraniTip,
            items:
                _tipoviKorisnika.map((tip) {
                  return DropdownMenuItem(
                    value: tip,
                    child: Text(
                      tip.naziv,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _odabraniTip = value),
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.search),
              label: const Text("Pretraži"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.clear),
              label: const Text("Resetuj filtere"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController controller, String label) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _resetAndFetch() {
    _currentPage = 0;
    _fetchKorisnici();
  }
}

class _KorisniciDataSource extends DataTableSource {
  final List<Korisnik> korisnici;
  final BuildContext context;
  final VoidCallback onDelete;

  _KorisniciDataSource(this.korisnici, this.context, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= korisnici.length) return null;
    final korisnik = korisnici[index];

    return DataRow(
      cells: [
        DataCell(Text(korisnik.ime)),
        DataCell(Text(korisnik.prezime)),
        DataCell(Text(korisnik.username)),
        DataCell(Text(korisnik.brojTelefona)),
        DataCell(Text(korisnik.tipKorisnika ?? '-')),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => EditKorisnikaDialog(
                          korisnik: korisnik,
                          tipovi:
                              (context
                                  .findAncestorStateOfType<
                                    _UserListScreenState
                                  >()
                                  ?._tipoviKorisnika) ??
                              [],
                          onUpdate: onDelete,
                        ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  prikaziBrisanjeKorisnikaDialog(
                    context,
                    korisnik.id,
                    onDelete,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => korisnici.length;
  @override
  int get selectedRowCount => 0;
}

class EditKorisnikaDialog extends StatefulWidget {
  final Korisnik korisnik;
  final List<TipKorisnika> tipovi;
  final VoidCallback onUpdate;

  const EditKorisnikaDialog({
    super.key,
    required this.korisnik,
    required this.tipovi,
    required this.onUpdate,
  });

  @override
  State<EditKorisnikaDialog> createState() => _EditKorisnikaDialogState();
}

class _EditKorisnikaDialogState extends State<EditKorisnikaDialog> {
  late TextEditingController _imeController;
  late TextEditingController _prezimeController;
  late TextEditingController _usernameController;
  late TextEditingController _brojTelefonaController;
  TipKorisnika? _odabraniTip;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _imeController = TextEditingController(text: widget.korisnik.ime);
    _prezimeController = TextEditingController(text: widget.korisnik.prezime);
    _usernameController = TextEditingController(text: widget.korisnik.username);
    _brojTelefonaController = TextEditingController(
      text: widget.korisnik.brojTelefona,
    );

    if (widget.tipovi.isNotEmpty) {
      try {
        _odabraniTip = widget.tipovi.firstWhere(
          (tip) => tip.naziv == widget.korisnik.tipKorisnika,
        );
      } catch (e) {
        _odabraniTip = widget.tipovi.first;
      }
    } else {
      _odabraniTip = null;
    }
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _usernameController.dispose();
    _brojTelefonaController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final updated = KorisniciInsert(
      ime: _imeController.text,
      prezime: _prezimeController.text,
      username: _usernameController.text,
      brojTelefona: _brojTelefonaController.text,
      password: 'dummy',
      passwordPotvrda: 'dummy',
      isActive: _isActive,
      tipKorisnikaId: _odabraniTip?.id,
    );

    try {
      await ApiService().updateKorisnik(widget.korisnik.id, updated);
      Navigator.of(context).pop();
      widget.onUpdate();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greška pri ažuriranju: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Uredi korisnika"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _imeController,
              decoration: const InputDecoration(labelText: "Ime"),
            ),
            TextField(
              controller: _prezimeController,
              decoration: const InputDecoration(labelText: "Prezime"),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _brojTelefonaController,
              decoration: const InputDecoration(labelText: "Telefon"),
            ),
            DropdownButtonFormField<TipKorisnika>(
              value: _odabraniTip,
              items:
                  widget.tipovi
                      .map(
                        (tip) => DropdownMenuItem(
                          value: tip,
                          child: Text(tip.naziv),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _odabraniTip = value),
              decoration: const InputDecoration(labelText: "Tip korisnika"),
            ),
            SwitchListTile(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              title: const Text("Aktivan"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Otkaži"),
        ),
        ElevatedButton(onPressed: _saveChanges, child: const Text("Sačuvaj")),
      ],
    );
  }
}
