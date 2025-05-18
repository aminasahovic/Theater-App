import 'dart:convert';
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
  int _pageSize = 3;
  late Future<PagedResult<Izvedba>> _izvedbeFuture;
  List<Sala> _sale = [];

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
    _izvedbeFuture = ApiService().getIzvedbe(
      salaId: _selectedSala?.id,
      nazivPredstave: _nazivController.text,
      datum: _selectedDate,
      page: _currentPage,
      pageSize: _pageSize,
    );
  }

  void _search() {
    setState(() {
      _currentPage = 1;
      _fetchIzvedbe();
    });
  }

  void _clearFilters() {
    setState(() {
      _nazivController.clear();
      _selectedSala = null;
      _selectedDate = null;
      _fetchIzvedbe();
    });
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _fetchIzvedbe();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Izvedbe",
      Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
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
                  return const Center(child: Text('Nema dostupnih izvedbi.'));
                }

                final izvedbe = snapshot.data!.resultList;
                final totalCount = snapshot.data!.count;
                final totalPages = (totalCount / _pageSize).ceil();

                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.65,
                            ),
                        itemCount: izvedbe.length,
                        itemBuilder: (context, index) {
                          final izvedba = izvedbe[index];
                          return _buildIzvedbaCard(izvedba);
                        },
                      ),
                    ),
                    _buildPagination(totalPages),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nazivController,
              decoration: InputDecoration(labelText: 'Naziv predstave'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<Sala>(
              value: _selectedSala,
              onChanged: (value) {
                setState(() {
                  _selectedSala = value;
                });
              },
              items:
                  _sale.map((sala) {
                    return DropdownMenuItem(
                      value: sala,
                      child: Text(sala.naziv),
                    );
                  }).toList(),
              decoration: InputDecoration(labelText: 'Sala'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text(
                _selectedDate == null
                    ? 'Odaberi datum'
                    : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}.',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: _search, icon: const Icon(Icons.search)),
          const SizedBox(width: 8),
          IconButton(onPressed: _clearFilters, icon: const Icon(Icons.clear)),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _openIzvedbaPopup,
            child: const Text('Dodaj izvedbu'),
          ),
        ],
      ),
    );
  }

  Widget _buildIzvedbaCard(Izvedba izvedba) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.white),
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  izvedba.nazivPredstave,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        _openIzvedbaPopup(
                          updateData: izvedba,
                        ); // ili bez parametra za dodavanje
                        setState(() {
                          _fetchIzvedbe(); // osvježi listu nakon zatvaranja popupa
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteIzvedba(izvedba.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        children: List.generate(totalPages, (index) {
          final pageIndex = index + 1;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _currentPage == pageIndex ? Colors.blue : Colors.grey[300],
              foregroundColor:
                  _currentPage == pageIndex ? Colors.white : Colors.black,
              minimumSize: const Size(40, 40),
            ),
            onPressed: () => _goToPage(pageIndex),
            child: Text(pageIndex.toString()),
          );
        }),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}. ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _openIzvedbaPopup({Izvedba? updateData}) async {
    final _formKey = GlobalKey<FormState>();
    PredstavaLov? _selectedPredstava;
    Sala? _selectedSala;
    DateTime? _selectedDateTime;
    final _cijenaController = TextEditingController();
    List<PredstavaLov> _predstave = [];
    List<Sala> _sale = [];

    try {
      _predstave = await ApiService().getPredstaveLov();
      _sale = await ApiService().getSale();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom učitavanja podataka: $e')),
      );
      return;
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

    showDialog(
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
                                : (value) {
                                  setState(() {
                                    _selectedPredstava = value;
                                  });
                                },
                        items:
                            _predstave.map((predstava) {
                              return DropdownMenuItem(
                                value: predstava,
                                child: Text(predstava.naziv),
                              );
                            }).toList(),

                        decoration: InputDecoration(
                          labelText: 'Predstava',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null ? 'Odaberite predstavu' : null,
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<Sala>(
                        value: _selectedSala,
                        onChanged:
                            (value) => setState(() => _selectedSala = value),
                        items:
                            _sale
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.naziv),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          labelText: 'Sala',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator:
                            (value) => value == null ? 'Odaberite salu' : null,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _cijenaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cijena karte',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Unesite cijenu';
                          if (double.tryParse(value) == null)
                            return 'Neispravan broj';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateTime ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() => _selectedDateTime = pickedDate);
                          }
                        },
                        child: Text(
                          _selectedDateTime == null
                              ? 'Odaberi datum'
                              : 'Datum: ${_selectedDateTime!.day}.${_selectedDateTime!.month}.${_selectedDateTime!.year}.',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_selectedDateTime != null) {
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
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prvo odaberite datum'),
                              ),
                            );
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
                    try {
                      if (updateData == null) {
                        // Kreirajte novi objekt za dodavanje
                        final izvedba = IzvedbaInsert(
                          predstavaId: _selectedPredstava!.id,
                          salaId: _selectedSala!.id,
                          cijenaKarte: double.parse(_cijenaController.text),
                          datumVrijeme: _selectedDateTime!.toIso8601String(),
                        );

                        // Pozovite API servis za dodavanje
                        await ApiService.dodajIzvedbu(izvedba);

                        // Prikazivanje poruke o uspjehu
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Izvedba dodana!')),
                        );
                      } else {
                        // Kreirajte objekt za ažuriranje postojeće izvedbe
                        final izvedba = IzvedbaUpdateRequest(
                          predstavaId: _selectedPredstava!.id,
                          salaId: _selectedSala!.id,
                          cijenaKarte: double.parse(_cijenaController.text),
                          datumVrijeme: _selectedDateTime!,
                        );

                        // Pozovite API servis za ažuriranje
                        await ApiService.updateIzvedba(izvedba, updateData.id);

                        // Prikazivanje poruke o uspjehu
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Izvedba ažurirana!')),
                        );
                      }

                      // Zatvaranje popup prozora
                      Navigator.pop(context);

                      // Osvježavanje podataka nakon što su promjene spremljene
                      setState(() {
                        _fetchIzvedbe(); // Pozivanje funkcije za dohvat novih podataka
                      });
                    } catch (e) {
                      // Prikazivanje greške ako nešto pođe po zlu
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

  void _deleteIzvedba(int id) async {
    final result = await ApiService.deleteIzvedba(id);
    if (result) {
      setState(() {
        _fetchIzvedbe();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izvedba uspješno obrisana.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Došlo je do greške pri brisanju.")),
      );
    }
  }
}
