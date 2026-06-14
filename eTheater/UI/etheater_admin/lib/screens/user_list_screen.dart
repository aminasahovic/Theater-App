import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/delete_utils.dart';
import 'package:etheater_admin/screens/dodaj_korisnika_dialog.dart';
import 'package:etheater_admin/screens/edit_korisnika_dialog.dart';
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
  Map<int, String> _tipKorisnikaMapa = {};

  bool? _isActive;
  TipKorisnika? _odabraniTip;
  bool _isLoading = false;
  int _currentPage = 0;
  int _rowsPerPage = 4;
  int _totalCount = 0;

  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _usernameController = TextEditingController();

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
        _tipKorisnikaMapa = {for (var tip in tipovi) tip.id: tip.naziv};
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju tipova korisnika: $e");
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
        isActive: _isActive,
        page: _currentPage + 1,
        pageSize: _rowsPerPage,
      );
      setState(() {
        _korisnici = korisnici;
        _totalCount = count;
      });
    } catch (e) {
      debugPrint("Greška pri dohvaćanju korisnika: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() => _currentPage = 0);
    _fetchKorisnici();
  }

  void _resetFilters() {
    setState(() {
      _imeController.clear();
      _prezimeController.clear();
      _usernameController.clear();
      _odabraniTip = null;
      _isActive = null;
    });
    _fetchKorisnici();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Administracija korisnika",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildTopBar(context),
          const SizedBox(height: 20),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _korisnici.isEmpty
                    ? const Center(
                      child: Text(
                        "Nema rezultata.",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _korisnici.length,
                      itemBuilder: (context, index) {
                        final korisnik = _korisnici[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${korisnik.ime} ${korisnik.prezime}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Username: ${korisnik.username}\nTelefon: ${korisnik.brojTelefona}\nTip: ${_tipKorisnikaMapa[korisnik.tipKorisnikaId] ?? '-'}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final korisnikById = await _apiService
                                            .getByIdKorisnik(korisnik.id);
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => EditKorisnikaDialog(
                                                korisnik: korisnikById,
                                                tipovi: _tipoviKorisnika,
                                                onUpdate: _resetAndFetch,
                                              ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text("Uredi"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    ElevatedButton.icon(
                                      onPressed: () {
                                        prikaziBrisanjeKorisnikaDialog(
                                          context,
                                          korisnik.id,
                                          _resetAndFetch,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                      label: const Text("Obriši"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF800020,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(height: 12),
          _buildPagination(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Pretraži po korisničkom imenu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF800020),
                    width: 1.4,
                  ),
                ),
              ),
              onChanged: (_) => _fetchKorisnici(),
            ),
          ),
          const SizedBox(width: 12),
          _buildAdvancedFiltersButton(context),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () async {
              await showDialog(
                context: context,
                builder:
                    (_) =>
                        DodajKorisnikaDialog(onKorisnikDodan: _resetAndFetch),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800020),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            label: const Text("Dodaj korisnika"),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFiltersButton(BuildContext context) {
    final key = GlobalKey();

    return IconButton(
      key: key,
      icon: const Icon(
        Icons.filter_alt_outlined,
        color: Color(0xFF800020), // bordo ikonica
      ),
      onPressed: () => _showAdvancedFilters(context, key),
      splashRadius: 26,
    );
  }

  Future<void> _showAdvancedFilters(BuildContext context, GlobalKey key) async {
    final RenderBox button =
        key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height + 4,
        position.dx + button.size.width,
        0,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            width: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFieldNoBorder(_imeController, 'Ime'),
                const SizedBox(height: 12),
                _buildTextFieldNoBorder(_prezimeController, 'Prezime'),
                const SizedBox(height: 12),
                DropdownButtonFormField<TipKorisnika>(
                  value: _odabraniTip,
                  decoration: const InputDecoration(
                    labelText: 'Tip korisnika',
                    border: InputBorder.none,
                  ),
                  items:
                      _tipoviKorisnika
                          .map(
                            (tip) => DropdownMenuItem(
                              value: tip,
                              child: Text(tip.naziv),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _odabraniTip = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool?>(
                  value: _isActive,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Svi')),
                    DropdownMenuItem(value: true, child: Text('Aktivni')),
                    DropdownMenuItem(value: false, child: Text('Neaktivni')),
                  ],
                  onChanged: (value) => setState(() => _isActive = value),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF800020),
                          width: 1.3,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Resetuj",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Primijeni",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldNoBorder(
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    int totalPages = (_totalCount / _rowsPerPage).ceil();
    int currentPageDisplay = _currentPage + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              currentPageDisplay > 1
                  ? () {
                    setState(() => _currentPage--);
                    _fetchKorisnici();
                  }
                  : null,
          child: const Text('Prethodna'),
        ),

        const SizedBox(width: 16),

        Text('Stranica $currentPageDisplay od $totalPages'),

        const SizedBox(width: 16),

        OutlinedButton(
          onPressed:
              currentPageDisplay < totalPages
                  ? () {
                    setState(() => _currentPage++);
                    _fetchKorisnici();
                  }
                  : null,
          child: const Text('Sljedeća'),
        ),
      ],
    );
  }

  void _resetAndFetch() {
    _currentPage = 0;
    _fetchKorisnici();
  }
}
