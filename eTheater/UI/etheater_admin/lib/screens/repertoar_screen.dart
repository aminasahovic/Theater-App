import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/predstava_details_screen.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../layouts/master_screen.dart';

class RepertoarScreen extends StatefulWidget {
  const RepertoarScreen({super.key});

  @override
  State<RepertoarScreen> createState() => _RepertoarScreenState();
}

class _RepertoarScreenState extends State<RepertoarScreen> {
  final _apiService = ApiService();
  List<Repertoar> _repertoari = [];
  int _totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 6;
  List<RepertoarIzvedba> _repertoarIzvedbe = [];

  String? _nazivFilter;
  DateTime? _datumFilter;

  final TextEditingController _nazivController = TextEditingController();
  int? _expandedRepertoarId;

  Future<void> _loadData() async {
    final response = await _apiService.getRepertoar(
      page: _currentPage,
      pageSize: _pageSize,
      naziv: _nazivFilter,
      pocetakDatum: _datumFilter,
    );
    setState(() {
      _repertoari = response['data'];
      _totalCount = response['count'];
    });
  }

  Future<void> _loadRepertoarDetails(int repertoarId) async {
    final response = await _apiService.getRepertoarIzvedbe(repertoarId);
    setState(() {
      _repertoarIzvedbe = response;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _resetFilters() {
    _nazivController.clear();
    _datumFilter = null;
    _nazivFilter = null;
    _currentPage = 1;
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      'Repertoar',
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nazivController,
                    decoration: const InputDecoration(labelText: 'Naziv'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _datumFilter = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _datumFilter == null
                        ? 'Datum'
                        : DateFormat('dd.MM.yyyy').format(_datumFilter!),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _nazivFilter = _nazivController.text;
                    _currentPage = 1;
                    _loadData();
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await showAddRepertoarDialog(context);
                    _loadData();
                  },
                  icon: Icon(Icons.add),
                  label: const Text("Dodaj Repertoar"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _repertoari.length,
                itemBuilder: (context, index) {
                  final repertoar = _repertoari[index];
                  bool isExpanded = _expandedRepertoarId == repertoar.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            repertoar.naziv,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                "Od: ${DateFormat('dd.MM.yyyy').format(repertoar.pocetakDatum)}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Do: ${DateFormat('dd.MM.yyyy').format(repertoar.krajDatum)}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.black,
                                ),
                                tooltip:
                                    isExpanded
                                        ? 'Sakrij detalje'
                                        : 'Prikaži detalje',
                                onPressed: () {
                                  setState(() {
                                    if (_expandedRepertoarId == repertoar.id) {
                                      _expandedRepertoarId = null;
                                    } else {
                                      _expandedRepertoarId = repertoar.id;
                                      _loadRepertoarDetails(repertoar.id);
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                                tooltip: 'Uredi',
                                onPressed: () async {
                                  await showEditRepertoarDialog(
                                    context,
                                    repertoar,
                                    _loadData,
                                  );
                                  _loadData();
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.black,
                                ),
                                tooltip: 'Obriši',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Potvrda'),
                                          content: const Text(
                                            'Da li ste sigurni da želite obrisati ovaj repertoar?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text('Ne'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text('Da'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    await ApiService.deleteRepertoar(
                                      repertoar.id,
                                    );
                                    _loadData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Repertoar je uspješno obrisan.',
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Detalji repertoara:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_repertoarIzvedbe.isNotEmpty)
                                  Column(
                                    children:
                                        _repertoarIzvedbe.map((izvedba) {
                                          return ListTile(
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    izvedba.nazivPredstave,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.visibility,
                                                    color: Color(0xFFB71C1C),
                                                  ),
                                                  tooltip:
                                                      'Pregledaj predstavu',
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => PredstavaDetailsScreen(
                                                              predstavaId:
                                                                  izvedba
                                                                      .predstavaId,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.description,
                                                    color: Color(0xFFB71C1C),
                                                  ),
                                                  tooltip: 'Prikaži izveštaj',
                                                  onPressed: () {
                                                    _showSalesReportDialog(
                                                      izvedba,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            subtitle: Text(
                                              'Datum: ${DateFormat('dd.MM.yyyy').format(izvedba.datumVrijemeIzvedbe)}',
                                            ),
                                          );
                                        }).toList(),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_totalCount > _pageSize)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed:
                        _currentPage > 1
                            ? () {
                              setState(() {
                                _currentPage--;
                                _loadData();
                              });
                            }
                            : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Stranica $_currentPage',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    onPressed:
                        (_currentPage * _pageSize) < _totalCount
                            ? () {
                              setState(() {
                                _currentPage++;
                                _loadData();
                              });
                            }
                            : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> showAddRepertoarDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nazivController = TextEditingController();
    DateTime? _pocetakDatum;
    DateTime? _krajDatum;
    List<IzvedbaPeriodModel> _izvedbe = [];
    List<IzvedbaPeriodModel> _odabraneIzvedbe = [];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dodaj Repertoar'),
          content: Container(
            width: 600,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nazivController,
                            decoration: InputDecoration(labelText: 'Naziv'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Unesite naziv';
                              }
                              if (!RegExp(r'^[A-Z]').hasMatch(value)) {
                                return 'Naziv mora počinjati velikim slovom';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _pocetakDatum = picked;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.date_range),
                                  label: Text(
                                    _pocetakDatum == null
                                        ? 'Početni datum'
                                        : 'Početak: ${DateFormat('dd.MM.yyyy').format(_pocetakDatum!)}',
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _krajDatum = picked;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.date_range),
                                  label: Text(
                                    _krajDatum == null
                                        ? 'Krajnji datum'
                                        : 'Kraj: ${DateFormat('dd.MM.yyyy').format(_krajDatum!)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed:
                                (_pocetakDatum != null && _krajDatum != null)
                                    ? () async {
                                      final izvedbe = await ApiService()
                                          .getIzvedbeByDatum(
                                            datumOd: _pocetakDatum!,
                                            datumDo: _krajDatum!,
                                          );
                                      setState(() {
                                        _izvedbe = izvedbe;
                                      });
                                    }
                                    : null,
                            icon: Icon(Icons.search),
                            label: Text('Učitaj izvedbe'),
                          ),
                          SizedBox(height: 16),
                          if (_izvedbe.isNotEmpty)
                            MultiSelectDialogField<IzvedbaPeriodModel>(
                              items:
                                  _izvedbe
                                      .map(
                                        (e) => MultiSelectItem<
                                          IzvedbaPeriodModel
                                        >(
                                          e,
                                          '${e.nazivPredstave} - ${DateFormat('dd.MM.yyyy HH:mm').format(e.datumVrijemeIzvodjenja)}',
                                        ),
                                      )
                                      .toList(),
                              title: Text("Izvedbe"),
                              selectedColor: Theme.of(context).primaryColor,
                              buttonText: Text("Odaberite izvedbe"),
                              buttonIcon: Icon(Icons.event_available),
                              listType: MultiSelectListType.CHIP,
                              onConfirm: (selected) {
                                _odabraneIzvedbe = selected;
                              },
                              validator: (values) {
                                if (values == null || values.isEmpty) {
                                  return 'Odaberite barem jednu izvedbu';
                                }
                                return null;
                              },
                            ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_pocetakDatum!.isAfter(_krajDatum!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Datum početka mora biti prije datuma kraja',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final repertoarId = await ApiService().dodajRepertoar(
                    naziv: _nazivController.text,
                    pocetakDatum: _pocetakDatum!,
                    krajDatum: _krajDatum!,
                  );

                  if (repertoarId != null) {
                    for (var izvedba in _odabraneIzvedbe) {
                      await ApiService().dodajRepertoarIzvedba(
                        repertoarId: repertoarId,
                        izvedbaId: izvedba.izvedbaId,
                      );
                    }

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Repertoar uspješno dodan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: Text('Sačuvaj'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditRepertoarDialog(
    BuildContext context,
    Repertoar repertoar,
    VoidCallback onRefresh,
  ) async {
    final _apiService = ApiService();
    final _nazivController = TextEditingController(text: repertoar.naziv);
    DateTime pocetakDatum = repertoar.pocetakDatum;
    DateTime krajDatum = repertoar.krajDatum;

    List<IzvedbaPeriodModel> dostupneIzvedbe = [];
    List<RepertoarIzvedba> dodijeljeneIzvedbe = [];

    final selectedIzvedbeIds = <int>{};

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text("Uredi Repertoar"),
                content: SizedBox(
                  width: 600,
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _nazivController,
                          decoration: const InputDecoration(labelText: 'Naziv'),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                DateFormat(
                                  'dd.MM.yyyy. HH:mm',
                                ).format(pocetakDatum),
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: pocetakDatum,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setState(() {
                                    pocetakDatum = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      0,
                                      0,
                                    );
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                DateFormat(
                                  'dd.MM.yyyy. HH:mm',
                                ).format(krajDatum),
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: krajDatum,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setState(() {
                                    krajDatum = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      23,
                                      59,
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            dostupneIzvedbe = await _apiService
                                .getIzvedbeByDatum(
                                  datumOd: pocetakDatum,
                                  datumDo: krajDatum,
                                );
                            dodijeljeneIzvedbe = await _apiService
                                .getRepertoarIzvedbe(repertoar.id);
                            selectedIzvedbeIds.clear();
                            selectedIzvedbeIds.addAll(
                              dodijeljeneIzvedbe.map((e) => e.izvedbaId),
                            );
                            setState(() {});
                          },
                          child: const Text("Učitaj izvedbe"),
                        ),
                        const SizedBox(height: 10),
                        ...dostupneIzvedbe.map((izvedba) {
                          final formattedDate = DateFormat(
                            'dd.MM.yyyy. HH:mm',
                          ).format(izvedba.datumVrijemeIzvodjenja);
                          return CheckboxListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  izvedba.nazivPredstave,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            value: selectedIzvedbeIds.contains(
                              izvedba.izvedbaId,
                            ),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedIzvedbeIds.add(izvedba.izvedbaId);
                                } else {
                                  selectedIzvedbeIds.remove(izvedba.izvedbaId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Otkaži"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      if (_nazivController.text.isEmpty ||
                          !_nazivController.text[0].contains(
                            RegExp(r'[A-ZŠĐČĆŽ]'),
                          )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Naziv mora počinjati velikim slovom.",
                            ),
                          ),
                        );
                        return;
                      }
                      if (pocetakDatum.isBefore(now)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Početni datum mora biti u budućnosti.",
                            ),
                          ),
                        );
                        return;
                      }

                      if (krajDatum.isBefore(pocetakDatum)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Krajnji datum mora biti nakon početnog.",
                            ),
                          ),
                        );
                        return;
                      }
                      await _apiService.updateRepertoar(repertoar.id, {
                        'naziv': _nazivController.text,
                        'pocetakDatum': pocetakDatum.toIso8601String(),
                        'krajDatum': krajDatum.toIso8601String(),
                      });

                      final postojeceIds =
                          dodijeljeneIzvedbe.map((e) => e.izvedbaId).toSet();

                      final zaDodati = selectedIzvedbeIds.difference(
                        postojeceIds,
                      );
                      for (final izvedbaId in zaDodati) {
                        await _apiService.dodajRepertoarIzvedba(
                          repertoarId: repertoar.id,
                          izvedbaId: izvedbaId,
                        );
                      }

                      final zaObrisati = postojeceIds.difference(
                        selectedIzvedbeIds,
                      );
                      for (final izvedbaId in zaObrisati) {
                        final repIzv = dodijeljeneIzvedbe.firstWhere(
                          (e) => e.izvedbaId == izvedbaId,
                        );
                        await _apiService.deleteRepertoarIzvedba(
                          repIzv.repertoarIzvedbaId,
                        );
                      }
                      Navigator.of(context).pop();
                      _loadRepertoarDetails(repertoar.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Repertoar je uspješno ažuriran.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      onRefresh();
                    },
                    child: const Text("Spremi"),
                  ),
                ],
              ),
        );
      },
    );
  }

  Future<void> _showSalesReportDialog(RepertoarIzvedba izvedba) async {
    try {
      final report = await _apiService.getTicketSalesReport(izvedba.izvedbaId);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.description, color: Color(0xFFB71C1C)),
                  SizedBox(width: 8),
                  Text('Izveštaj za ${izvedba.nazivPredstave}'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.confirmation_number),
                              title: Text('Izvedba ID'),
                              subtitle: Text('${report.izvedbaId}'),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.theater_comedy),
                              title: Text('Naziv predstave'),
                              subtitle: Text(report.nazivPredstave),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text('Datum i vreme'),
                              subtitle: Text(
                                DateFormat(
                                  'dd.MM.yyyy HH:mm',
                                ).format(report.datumVrijeme),
                              ),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.people),
                              title: Text('Ukupno rezervacija'),
                              subtitle: Text('${report.ukupnoRezervacija}'),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.attach_money),
                              title: Text('Ukupni prihod'),
                              subtitle: Text('${report.ukupniPrihod} BAM'),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.event_seat),
                              title: Text('Popunjenost sale'),
                              subtitle: Text(
                                '${report.zauzetaMjesta}/${report.ukupnoMjesta} mesta',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Popunjenost sale:',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: report.zauzetaMjesta.toDouble(),
                                color: Colors.blue,
                                title: '${report.zauzetaMjesta}',
                                radius: 70,
                                titleStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value:
                                    (report.ukupnoMjesta - report.zauzetaMjesta)
                                        .toDouble(),
                                color: Colors.grey[300]!,
                                title:
                                    '${report.ukupnoMjesta - report.zauzetaMjesta}',
                                radius: 70,
                                titleStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend(color: Colors.blue, label: 'Zauzeto'),
                          SizedBox(width: 16),
                          _buildLegend(
                            color: Colors.grey[300]!,
                            label: 'Slobodno',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Zatvori'),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.print),
                  label: Text('Štampaj'),
                  onPressed: () async {
                    await _printSalesReport(report);
                  },
                ),
              ],
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška prilikom dohvata izveštaja: $e')),
      );
    }
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Future<void> _printSalesReport(TicketSalesReportDTO report) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Izvestaj o prodaji karata',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Izvedba ID: ${report.izvedbaId}'),
                pw.Text('Naziv predstave: ${report.nazivPredstave}'),
                pw.Text(
                  'Datum i vreme: ${DateFormat('dd.MM.yyyy HH:mm').format(report.datumVrijeme)}',
                ),
                pw.Text('Ukupno rezervacija: ${report.ukupnoRezervacija}'),
                pw.Text('Ukupni prihod: ${report.ukupniPrihod} BAM'),
                pw.Text(
                  'Popunjenost sale: ${report.zauzetaMjesta}/${report.ukupnoMjesta} mesta',
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
