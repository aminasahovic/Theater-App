import 'package:etheater_admin/layouts/master_screen.dart';
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
  int _rowsPerPage = 4;
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
    return MasterScreen(
      "Administracija Kosinika",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child: Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _korisnici.length,
                          itemBuilder: (context, index) {
                            final korisnik = _korisnici[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.white,
                              // ignore: deprecated_member_use
                              shadowColor: Colors.black.withOpacity(
                                0.2,
                              ), // Sjena sa većom transparentnošću
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(
                                  16,
                                ), // Povećan razmak oko sadržaja
                                title: Text(
                                  '${korisnik.ime} ${korisnik.prezime}',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold, // Bold za ime i prezime
                                    fontSize: 16, // Povećan font
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Username: ${korisnik.username}'),
                                    const SizedBox(height: 4),
                                    Text('Telefon: ${korisnik.brojTelefona}'),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tip: ${korisnik.tipKorisnika ?? '-'}',
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color:
                                            Colors
                                                .black, // Prilagođena boja za edit ikonu
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => EditKorisnikaDialog(
                                                korisnik: korisnik,
                                                tipovi: _tipoviKorisnika,
                                                onUpdate: _resetAndFetch,
                                              ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        prikaziBrisanjeKorisnikaDialog(
                                          context,
                                          korisnik.id,
                                          _resetAndFetch,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed:
                                _currentPage > 0
                                    ? () {
                                      setState(() => _currentPage--);
                                      _fetchKorisnici();
                                    }
                                    : null,
                            child: const Text("Prethodna"),
                          ),
                          const SizedBox(width: 20),
                          Text('Stranica ${_currentPage + 1}'),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed:
                                (_currentPage + 1) * _rowsPerPage < _totalCount
                                    ? () {
                                      setState(() => _currentPage++);
                                      _fetchKorisnici();
                                    }
                                    : null,
                            child: const Text("Sljedeća"),
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

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildFilterField(_imeController, 'Ime'),
                const SizedBox(width: 12),
                _buildFilterField(_prezimeController, 'Prezime'),
                const SizedBox(width: 12),
                _buildFilterField(_usernameController, 'Korisničko ime'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<TipKorisnika>(
                    decoration: InputDecoration(
                      labelText: 'Tip korisnika',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                    value: _odabraniTip,
                    items:
                        _tipoviKorisnika.map((tip) {
                          return DropdownMenuItem(
                            value: tip,
                            child: Text(tip.naziv),
                          );
                        }).toList(),
                    onChanged: (value) => setState(() => _odabraniTip = value),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _applyFilters,
                color: Colors.blueGrey,
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _resetFilters,
                color: Colors.grey,
              ),
            ],
          ),

          ElevatedButton.icon(
            onPressed: () async {
              await showDialog(
                context: context,
                builder:
                    (_) =>
                        DodajKorisnikaDialog(onKorisnikDodan: _resetAndFetch),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Dodaj korisnika"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800020),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterField(TextEditingController controller, String label) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  void _resetAndFetch() {
    _currentPage = 0;
    _fetchKorisnici();
  }
}

// ignore: unused_element
class _KorisniciDataSource extends DataTableSource {
  final List<Korisnik> korisnici;
  final BuildContext context;
  final VoidCallback onDelete;
  final int totalCount;

  _KorisniciDataSource(
    this.korisnici,
    this.context,
    this.onDelete,
    this.totalCount,
  );

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
                icon: const Icon(Icons.edit, color: Colors.black),
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
  int get rowCount => totalCount;
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
      email: 'dumyy',
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
