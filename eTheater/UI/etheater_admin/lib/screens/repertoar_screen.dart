import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/screens/predstava_details_screen.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:pdf/pdf.dart';
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
                // 1. TextField - popunjava sav prostor do kraja
                Expanded(
                  child: TextField(
                    controller: _nazivController,
                    decoration: InputDecoration(
                      labelText: 'Naziv',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) {
                      _nazivFilter = _nazivController.text;
                      _currentPage = 1;
                      _loadData();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // 2. Datum picker - fiksna širina
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _datumFilter ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _datumFilter = picked;
                          _currentPage = 1;
                          _loadData();
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      _datumFilter == null
                          ? 'Datum'
                          : DateFormat('dd.MM.yyyy').format(_datumFilter!),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Search i Clear - mali gumbi
                IconButton(
                  onPressed: () {
                    _nazivFilter = _nazivController.text;
                    _currentPage = 1;
                    _loadData();
                  },
                  icon: const Icon(Icons.search, size: 20),
                  tooltip: 'Pretraži',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(10),
                  ),
                ),

                const SizedBox(width: 4),

                IconButton(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear, size: 20),
                  tooltip: 'Očisti filtere',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    padding: const EdgeInsets.all(10),
                  ),
                ),

                // OVO JE KLJUČNO: Spacer gura "Dodaj" na KRAJ
                const Spacer(),

                // 4. Dodaj Repertoar - fiksni gumb
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await showAddRepertoarDialog(context);
                    _loadData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj Repertoar"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _repertoari.length,
                  itemBuilder: (context, index) {
                    final repertoar = _repertoari[index];
                    final isExpanded = _expandedRepertoarId == repertoar.id;

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ExpansionTile(
                          collapsedBackgroundColor: Colors.transparent,
                          backgroundColor: Colors.grey[50],
                          leading: CircleAvatar(
                            backgroundColor: const Color(
                              0xFFB71C1C,
                            ).withOpacity(0.1),
                            child: const Icon(
                              Icons.theater_comedy_outlined,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                          title: Text(
                            repertoar.naziv,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB71C1C),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.date_range_outlined,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${DateFormat('dd.MM.yyyy').format(repertoar.pocetakDatum)} - ${DateFormat('dd.MM.yyyy').format(repertoar.krajDatum)}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          childrenPadding: const EdgeInsets.all(16),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          onExpansionChanged: (expanded) {
                            if (expanded && !isExpanded) {
                              _expandedRepertoarId = repertoar.id;
                              _loadRepertoarDetails(repertoar.id);
                            } else if (!expanded) {
                              _expandedRepertoarId = null;
                            }
                            setState(() {});
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Uredi',
                                onPressed:
                                    () => showEditRepertoarDialog(
                                      context,
                                      repertoar,
                                      _loadData,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Obriši',
                                onPressed: () => {},
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.expand_more),
                              ),
                            ],
                          ),
                          children: [
                            if (_repertoarIzvedbe.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Nema izvedbi u ovom periodu.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              ..._repertoarIzvedbe.map(
                                (izvedba) => _buildIzvedbaCard(izvedba),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_totalCount > _pageSize) _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildIzvedbaCard(RepertoarIzvedba izvedba) {
    return Card(
      elevation: 0,
      color: Colors.grey[50], // Svijetlo siva pozadina
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!, width: 1), // Suptilna ivica
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          Icons.event_available_outlined,
          color: Colors.grey[700], // Tamnija siva za ikonicu
        ),
        title: Text(
          izvedba.nazivPredstave,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Datum: ${DateFormat('dd.MM.yyyy HH:mm').format(izvedba.datumVrijemeIzvedbe)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.visibility_outlined,
                color: Color(0xFFB71C1C),
              ),
              tooltip: 'Pregledaj predstavu',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PredstavaDetailsScreen(
                          predstavaId: izvedba.predstavaId,
                        ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.bar_chart_outlined,
                color: Color(0xFFB71C1C),
              ),
              tooltip: 'Izveštaj prodaje',
              onPressed: () => _showSalesReportDialog(izvedba),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    int totalPages = (_totalCount / _pageSize).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed:
              _currentPage > 1
                  ? () {
                    setState(() {
                      _currentPage--;
                      _loadData();
                    });
                  }
                  : null,
          child: const Text('Prethodna'),
        ),
        const SizedBox(width: 16),
        Text('Stranica $_currentPage od $totalPages'),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed:
              _currentPage < totalPages
                  ? () {
                    setState(() {
                      _currentPage++;
                      _loadData();
                    });
                  }
                  : null,
          child: const Text('Sljedeća'),
        ),
      ],
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
      final GlobalKey _chartKey = GlobalKey();

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
                      RepaintBoundary(
                        key: _chartKey,
                        child: SizedBox(
                          height: 300,
                          child: PieChart(
                            PieChartData(
                              sections:
                                  report.zauzetaMjesta == 0
                                      ? [
                                        PieChartSectionData(
                                          value: report.ukupnoMjesta.toDouble(),
                                          color: Colors.grey[300]!,
                                          title: '${report.ukupnoMjesta}',
                                          radius: 90,
                                          titleStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]
                                      : [
                                        PieChartSectionData(
                                          value:
                                              report.zauzetaMjesta.toDouble(),
                                          color: Colors.blue,
                                          title: '${report.zauzetaMjesta}',
                                          radius: 90,
                                          titleStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value:
                                              (report.ukupnoMjesta -
                                                      report.zauzetaMjesta)
                                                  .toDouble(),
                                          color: Colors.grey[300]!,
                                          title:
                                              '${report.ukupnoMjesta - report.zauzetaMjesta}',
                                          radius: 90,
                                          titleStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend(
                            color:
                                report.zauzetaMjesta == 0
                                    ? Colors.grey[300]!
                                    : Colors.blue,
                            label:
                                report.zauzetaMjesta == 0
                                    ? 'Slobodno'
                                    : 'Zauzeto',
                          ),
                          if (report.zauzetaMjesta != 0) ...[
                            SizedBox(width: 16),
                            _buildLegend(
                              color: Colors.grey[300]!,
                              label: 'Slobodno',
                            ),
                          ],
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
                    final chartImage = await _captureChartImage(_chartKey);
                    await _printSalesReport(report, chartImage);
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

  Future<Uint8List?> _captureChartImage(GlobalKey chartKey) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      RenderRepaintBoundary? boundary =
          chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('RenderRepaintBoundary not found');
        return null;
      }
      ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing chart image: $e');
      return null;
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

  Future<void> _printSalesReport(
    TicketSalesReportDTO report,
    Uint8List? chartImage,
  ) async {
    final pdf = pw.Document();
    final logoImage = await DefaultAssetBundle.of(
      context,
    ).load('assets/images/logo.png').then((data) => data.buffer.asUint8List());

    final timesFont = pw.Font.times();
    final timesBoldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        header:
            (pw.Context context) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(pw.MemoryImage(logoImage), width: 80, height: 80),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'E-Theater',
                      style: pw.TextStyle(
                        font: timesBoldFont,
                        fontSize: 24,
                        color: PdfColor.fromHex('#B71C1C'),
                      ),
                    ),
                    pw.Text(
                      'Izvestaj o prodaji karata',
                      style: pw.TextStyle(font: timesBoldFont, fontSize: 18),
                    ),
                    pw.Text(
                      'Datum izvestaja: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(font: timesFont, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
        footer:
            (pw.Context context) => pw.Container(
              alignment: pw.Alignment.center,
              margin: pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Stranica ${context.pageNumber} | E-Theater © ${DateTime.now().year}',
                style: pw.TextStyle(
                  font: timesFont,
                  fontSize: 10,
                  color: PdfColors.grey,
                ),
              ),
            ),
        build:
            (pw.Context context) => [
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              // Report Details Table
              pw.Text(
                'Detalji izvedbe',
                style: pw.TextStyle(font: timesBoldFont, fontSize: 16),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#EEEEEE'),
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Polje',
                          style: pw.TextStyle(
                            font: timesBoldFont,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Vrednost',
                          style: pw.TextStyle(
                            font: timesBoldFont,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Izvedba ID',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${report.izvedbaId}',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Naziv predstave',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          report.nazivPredstave,
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Datum i vreme',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          DateFormat(
                            'dd.MM.yyyy HH:mm',
                          ).format(report.datumVrijeme),
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Ukupno rezervacija',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${report.ukupnoRezervacija}',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Ukupni prihod',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${report.ukupniPrihod} BAM',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Popunjenost sale',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${report.zauzetaMjesta}/${report.ukupnoMjesta} mesta',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              // Pie Chart Section
              if (chartImage != null) ...[
                pw.Text(
                  'Popunjenost sale',
                  style: pw.TextStyle(font: timesBoldFont, fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Image(pw.MemoryImage(chartImage), width: 300, height: 300),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 16,
                          height: 16,
                          color: PdfColor.fromInt(
                            report.zauzetaMjesta == 0
                                ? Colors.grey[300]!.value
                                : Colors.blue.value,
                          ),
                        ),
                        pw.SizedBox(width: 4),
                        pw.Text(
                          report.zauzetaMjesta == 0 ? 'Slobodno' : 'Zauzeto',
                          style: pw.TextStyle(font: timesFont, fontSize: 12),
                        ),
                      ],
                    ),
                    if (report.zauzetaMjesta != 0) ...[
                      pw.SizedBox(width: 16),
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 16,
                            height: 16,
                            color: PdfColor.fromInt(Colors.grey[300]!.value),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Text(
                            'Slobodno',
                            style: pw.TextStyle(font: timesFont, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
