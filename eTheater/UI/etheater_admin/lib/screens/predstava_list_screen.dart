import 'dart:convert';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/delete_utils.dart';
import 'package:etheater_admin/screens/dodaj_predstavu_dialog.dart';
import 'package:etheater_admin/screens/predstava_details_screen.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';

class PredstaveScreen extends StatefulWidget {
  const PredstaveScreen({super.key});

  @override
  State<PredstaveScreen> createState() => _PredstaveScreenState();
}

class _PredstaveScreenState extends State<PredstaveScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nazivController = TextEditingController();

  int _trenutnaStranica = 1;
  final int _pageSize = 12;
  int _ukupnoRezultata = 0;

  List<Predstava> _filtriranePredstave = [];
  List<Zanr> _zanrovi = [];
  List<Reziser> _reziseri = [];
  Zanr? _odabraniZanr;
  Reziser? _odabraniReziser;
  String? _odabranaGodina;
  bool? _isActiveFilter;

  bool _showFilterPopup = false;

  @override
  void initState() {
    super.initState();
    _ucitajFilterPodatke();
    _fetchData();
  }

  Future<void> _ucitajFilterPodatke() async {
    final zanrovi = await ApiService.fetchZanrovi();
    final reziseri = await ApiService.fetchReziseri();
    setState(() {
      _zanrovi = zanrovi;
      _reziseri = reziseri;
    });
  }

  Future<void> _fetchData() async {
    final result = await _apiService.getPredstave(
      naziv: _nazivController.text,
      zanrId: _odabraniZanr?.id,
      reziserId: _odabraniReziser?.id,
      godina: _odabranaGodina != null ? int.tryParse(_odabranaGodina!) : null,
      isActive: _isActiveFilter,
      page: _trenutnaStranica,
      pageSize: _pageSize,
    );
    setState(() {
      _ukupnoRezultata = result.count;
      _filtriranePredstave = result.resultList;
    });
  }

  void _primijeniFiltere() {
    setState(() => _trenutnaStranica = 1);
    _fetchData();
  }

  Widget _buildFilterPopup() {
    return Positioned(
      right: 130,
      top: 65,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Zanr>(
                value: _odabraniZanr,
                decoration: const InputDecoration(labelText: 'Žanr'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Svi žanrovi'),
                  ),
                  ..._zanrovi.map(
                    (z) => DropdownMenuItem(value: z, child: Text(z.naziv)),
                  ),
                ],
                onChanged: (v) => setState(() => _odabraniZanr = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Reziser>(
                value: _odabraniReziser,
                decoration: const InputDecoration(labelText: 'Režiser'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Svi režiseri'),
                  ),
                  ..._reziseri.map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text('${r.ime} ${r.prezime}'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _odabraniReziser = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _odabranaGodina,
                decoration: const InputDecoration(labelText: 'Godina'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sve godine'),
                  ),
                  ...List.generate(
                    50,
                    (i) => (DateTime.now().year - i).toString(),
                  ).map((y) => DropdownMenuItem(value: y, child: Text(y))),
                ],
                onChanged: (v) => setState(() => _odabranaGodina = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<bool>(
                value: _isActiveFilter,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Svi')),
                  DropdownMenuItem(value: true, child: Text('Aktivne')),
                  DropdownMenuItem(value: false, child: Text('Neaktivne')),
                ],
                onChanged: (v) => setState(() => _isActiveFilter = v),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _odabraniZanr = null;
                        _odabraniReziser = null;
                        _odabranaGodina = null;
                        _isActiveFilter = null;
                      });
                      _primijeniFiltere();
                    },
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
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _showFilterPopup = false);
                      _primijeniFiltere();
                    },
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
    );
  }

  Widget _buildPredstavaCard(Predstava p) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PredstavaDetailsScreen(predstavaId: p.id),
          ),
        );
        if (result == true) _fetchData();
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slika predstave
            Expanded(
              flex: 6,
              child:
                  p.plakat == null || p.plakat!.isEmpty
                      ? Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 30,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.memory(
                          base64Decode(p.plakat!),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            // Tekst i status
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // automatsko smanjenje fonta ako je prostor manji
                    double titleFontSize = constraints.maxWidth < 150 ? 12 : 14;
                    double descFontSize = constraints.maxWidth < 150 ? 9 : 11;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Naslov predstave
                        Text(
                          p.naziv,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Status indikator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    p.isActive
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      p.isActive
                                          ? Colors.green[300]!
                                          : Colors.red[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    p.isActive
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        p.isActive
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p.isActive ? 'Aktivna' : 'Neaktivna',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          p.isActive
                                              ? Colors.green[800]
                                              : Colors.red[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Opis predstave
                        Text(
                          p.opis,
                          style: TextStyle(
                            fontSize: descFontSize,
                            color: Colors.grey[700],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // Dugme za brisanje na dnu
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed:
                                () => showDeleteConfirmationDialog(
                                  context: context,
                                  predstavaId: p.id,
                                  onDeleted: _fetchData,
                                ),
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.brown[800],
                            ),
                            label: Text(
                              'Obriši',
                              style: TextStyle(
                                color: Colors.brown[800],
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.brown[800]!),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(80, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // identično kao Dodaj predstavu
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    int totalPages = (_ukupnoRezultata / _pageSize).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              _trenutnaStranica > 1
                  ? () {
                    setState(() => _trenutnaStranica--);
                    _fetchData();
                  }
                  : null,
          child: const Text('Prethodna'),
        ),
        const SizedBox(width: 16),
        Text('Stranica $_trenutnaStranica od $totalPages'),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed:
              _trenutnaStranica < totalPages
                  ? () {
                    setState(() => _trenutnaStranica++);
                    _fetchData();
                  }
                  : null,
          child: const Text('Sljedeća'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Pregled Predstava',
      Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nazivController,
                        decoration: InputDecoration(
                          hintText: 'Pretraži po nazivu...',
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
                        onChanged: (_) => _primijeniFiltere(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Color(0xFF800020),
                      ),
                      tooltip: 'Napredno filtriranje',
                      onPressed:
                          () => setState(
                            () => _showFilterPopup = !_showFilterPopup,
                          ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final dodano = await showDialog<bool>(
                          context: context,
                          builder: (_) => const DodajPredstavuDialog(),
                        );
                        if (dodano == true) _fetchData();
                      },
                      child: const Text('Dodaj predstavu'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      _filtriranePredstave.isEmpty
                          ? const Center(
                            child: Text('Nema pronađenih predstava.'),
                          )
                          : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.55,
                                ),

                            itemCount: _filtriranePredstave.length,
                            itemBuilder:
                                (context, i) => _buildPredstavaCard(
                                  _filtriranePredstave[i],
                                ),
                          ),
                ),
                const SizedBox(height: 12),
                _buildPagination(),
              ],
            ),
          ),
          if (_showFilterPopup) _buildFilterPopup(),
        ],
      ),
    );
  }
}
