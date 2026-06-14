import 'dart:convert';
import 'package:etheater_admin/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';

class IzvedbaScreen extends StatefulWidget {
  const IzvedbaScreen({super.key});

  @override
  State<IzvedbaScreen> createState() => _IzvedbaScreenState();
}

class _IzvedbaScreenState extends State<IzvedbaScreen> {
  final TextEditingController _nazivController = TextEditingController();
  Sala? _selectedSala;
  DateTime? _selectedDate;
  int _currentPage = 1;
  final int _pageSize = 12;
  late Future<PagedResult<Izvedba>> _izvedbeFuture;
  List<Sala> _sale = [];
  bool _showFilterPopup = false;

  @override
  void initState() {
    super.initState();
    _fetchSale();
    _fetchIzvedbe();
  }

  void _fetchSale() async {
    final sale = await ApiService().getSale();
    setState(() {
      _sale = sale;
    });
  }

  void _fetchIzvedbe() {
    setState(() {
      _izvedbeFuture = ApiService().getIzvedbe(
        salaId: _selectedSala?.id,
        nazivPredstave: _nazivController.text,
        datum: _selectedDate,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });
  }

  void _search() {
    _currentPage = 1;
    _fetchIzvedbe();
  }

  void _clearFilters() {
    _nazivController.clear();
    _selectedSala = null;
    _selectedDate = null;
    _currentPage = 1;
    _fetchIzvedbe();
  }

  void _goToPage(int page) {
    _currentPage = page;
    _fetchIzvedbe();
  }

  Widget _buildFilterPopup() {
    return Positioned(
      right: 0,
      top: 55,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _showFilterPopup ? 1 : 0,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Sala>(
                  value: _selectedSala,
                  decoration: const InputDecoration(labelText: 'Sala'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Sve sale'),
                    ),
                    ..._sale.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.naziv)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedSala = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  decoration: InputDecoration(
                    labelText: 'Datum',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    hintText:
                        _selectedDate == null
                            ? 'Odaberi datum'
                            : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}.',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSala = null;
                          _selectedDate = null;
                        });
                        _search();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF800020),
                          width: 1.3,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Resetuj'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _search();
                        setState(() => _showFilterPopup = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Primijeni'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Izvedbe",
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
                        onChanged: (_) => _search(),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ), // isto kao grid
                      child: Align(
                        alignment:
                            Alignment
                                .centerLeft, // ili Alignment.centerRight ako želiš desno
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800020),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final result = await _openIzvedbaPopup();
                            if (result == true) _fetchIzvedbe();
                          },
                          child: const Text('Dodaj izvedbu'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<PagedResult<Izvedba>>(
                    future: _izvedbeFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Greška: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.resultList.isEmpty) {
                        return const Center(
                          child: Text('Nema dostupnih izvedbi.'),
                        );
                      }

                      final izvedbe = snapshot.data!.resultList;
                      final totalPages =
                          (snapshot.data!.count / _pageSize).ceil();

                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 250,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.55,
                                  ),
                              itemCount: izvedbe.length,
                              itemBuilder:
                                  (context, index) =>
                                      _buildIzvedbaCard(izvedbe[index]),
                            ),
                          ),

                          const SizedBox(height: 12), // razmak iznad paginacije

                          _buildPagination(totalPages),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_showFilterPopup) _buildFilterPopup(),
        ],
      ),
    );
  }

  Widget _buildIzvedbaCard(Izvedba izvedba) {
    return InkWell(
      onTap: () async {
        final result = await _openIzvedbaPopup(updateData: izvedba);
        if (result == true) _fetchIzvedbe();
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child:
                  izvedba.predstavaSlika.isNotEmpty
                      ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.memory(
                          base64Decode(izvedba.predstavaSlika),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      izvedba.nazivPredstave,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sala: ${izvedba.salaNaziv}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cijena: ${izvedba.cijenaKarte} KM',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Datum: ${_formatDate(izvedba.datumVrijeme)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await _openIzvedbaPopup(
                              updateData: izvedba,
                            );
                            if (result == true) _fetchIzvedbe();
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Color(0xFF800020),
                          ),
                          label: const Text(
                            'Uredi',
                            style: TextStyle(color: Color(0xFF800020)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Potvrda'),
                                    content: const Text(
                                      'Da li ste sigurni da želite obrisati ovu izvedbu?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Otkaži'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Obriši',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await ApiService.deleteIzvedba(izvedba.id);
                              _fetchIzvedbe();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Izvedba uspješno obrisana.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Obriši',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
          child: const Text('Prethodna'),
        ),
        const SizedBox(width: 16),
        Text('Stranica $_currentPage od $totalPages'),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed:
              _currentPage < totalPages
                  ? () => _goToPage(_currentPage + 1)
                  : null,
          child: const Text('Sljedeća'),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}. ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  // --- Pop-up za dodavanje/uređivanje izvedbe ostaje isti ---
  Future<bool?> _openIzvedbaPopup({Izvedba? updateData}) async {
    final _formKey = GlobalKey<FormState>();
    PredstavaLov? _selectedPredstava;
    Sala? _selectedSala;
    DateTime? _selectedDateTime;
    final _cijenaController = TextEditingController();
    List<PredstavaLov> _predstave = [];
    List<Sala> _sale = [];

    try {
      final predstave = await ApiService.getPredstaveLov();
      _predstave = predstave.resultList;
      _sale = await ApiService().getSale();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom učitavanja podataka: $e')),
      );
    }

    if (updateData != null) {
      _selectedPredstava = _predstave.firstWhere(
        (p) => p.id == updateData.predstavaId,
        orElse: () => _predstave.first,
      );
      _selectedSala = _sale.firstWhere(
        (s) => s.id == updateData.salaId,
        orElse: () => _sale.first,
      );
      _selectedDateTime = updateData.datumVrijeme;
      _cijenaController.text = updateData.cijenaKarte.toString();
    }

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                updateData == null ? 'Dodaj novu izvedbu' : 'Uredi izvedbu',
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<PredstavaLov>(
                        value: _selectedPredstava,
                        onChanged:
                            updateData != null
                                ? null
                                : (v) => setState(() => _selectedPredstava = v),
                        items:
                            _predstave
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.naziv),
                                  ),
                                )
                                .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Predstava',
                        ),
                        validator:
                            (v) => v == null ? 'Odaberite predstavu' : null,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Sala>(
                        value: _selectedSala,
                        onChanged: (v) => setState(() => _selectedSala = v),
                        items:
                            _sale
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.naziv),
                                  ),
                                )
                                .toList(),
                        decoration: const InputDecoration(labelText: 'Sala'),
                        validator: (v) => v == null ? 'Odaberite salu' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cijenaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cijena karte (KM)',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Unesite cijenu';
                          final n = double.tryParse(v);
                          if (n == null) return 'Unesite validan broj';
                          if (n < 0) return 'Cijena ne može biti negativna';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateTime ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null)
                            setState(() => _selectedDateTime = picked);
                        },
                        child: Text(
                          _selectedDateTime == null
                              ? 'Odaberi datum'
                              : 'Datum: ${_selectedDateTime!.day}.${_selectedDateTime!.month}.${_selectedDateTime!.year}.',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_selectedDateTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prvo odaberite datum'),
                              ),
                            );
                            return;
                          }
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              _selectedDateTime!,
                            ),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _selectedDateTime = DateTime(
                                _selectedDateTime!.year,
                                _selectedDateTime!.month,
                                _selectedDateTime!.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        },
                        child: Text(
                          _selectedDateTime == null
                              ? 'Odaberi vrijeme'
                              : 'Vrijeme: ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Odustani'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate() ||
                        _selectedDateTime == null)
                      return;
                    try {
                      if (updateData == null) {
                        await ApiService.dodajIzvedbu(
                          IzvedbaInsert(
                            predstavaId: _selectedPredstava!.id,
                            salaId: _selectedSala!.id,
                            cijenaKarte: double.parse(_cijenaController.text),
                            datumVrijeme: _selectedDateTime!.toIso8601String(),
                          ),
                        );
                      } else {
                        await ApiService.updateIzvedba(
                          IzvedbaUpdateRequest(
                            predstavaId: _selectedPredstava!.id,
                            salaId: _selectedSala!.id,
                            cijenaKarte: double.parse(_cijenaController.text),
                            datumVrijeme: _selectedDateTime!,
                          ),
                          updateData.id,
                        );
                      }
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Greška: $e')));
                    }
                  },
                  child: Text(updateData == null ? 'Dodaj' : 'Spasi'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
