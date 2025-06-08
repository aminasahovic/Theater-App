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
  int _pageSize = 10;
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
            onPressed: () async {
              _openIzvedbaPopup();
              setState(() {
                _fetchIzvedbe();
              });
            },
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
                      decoration: const BoxDecoration(color: Colors.grey),
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
                        _openIzvedbaPopup(updateData: izvedba);
                        setState(() {
                          _fetchIzvedbe();
                        });
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Potvrda"),
                              content: const Text(
                                "Da li ste sigurni da želite obrisati ovu izvedbu?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Otkaži"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await ApiService.deleteIzvedba(izvedba.id);
                                    setState(() {
                                      _fetchIzvedbe();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Izvedba uspješno obrisana.",
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Obriši",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed:
              _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('Prethodna'),
        ),
        const SizedBox(width: 16),
        Text('$_currentPage od $totalPages'),
        const SizedBox(width: 16),
        TextButton(
          onPressed:
              _currentPage < totalPages
                  ? () => _goToPage(_currentPage + 1)
                  : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('Sljedeća'),
        ),
      ],
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

                        decoration: InputDecoration(labelText: 'Predstava'),
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
                        decoration: InputDecoration(labelText: 'Sala'),
                        validator:
                            (value) => value == null ? 'Odaberite salu' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cijenaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cijena karte (KM)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Unesite cijenu';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Unesite validan broj';
                          }
                          if (number < 0) {
                            return 'Cijena ne može biti negativna';
                          }
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
                        final izvedba = IzvedbaInsert(
                          predstavaId: _selectedPredstava!.id,
                          salaId: _selectedSala!.id,
                          cijenaKarte: double.parse(_cijenaController.text),
                          datumVrijeme: _selectedDateTime!.toIso8601String(),
                        );

                        await ApiService.dodajIzvedbu(izvedba);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Izvedba dodana!')),
                        );
                      } else {
                        final izvedba = IzvedbaUpdateRequest(
                          predstavaId: _selectedPredstava!.id,
                          salaId: _selectedSala!.id,
                          cijenaKarte: double.parse(_cijenaController.text),
                          datumVrijeme: _selectedDateTime!,
                        );

                        await ApiService.updateIzvedba(izvedba, updateData.id);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Izvedba ažurirana!')),
                        );
                      }
                      Navigator.pop(context);
                      setState(() => _fetchIzvedbe());
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
