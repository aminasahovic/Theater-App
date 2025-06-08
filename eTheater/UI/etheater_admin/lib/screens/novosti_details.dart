import 'dart:convert';

import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';

class NovostiDetailsScreen extends StatefulWidget {
  final Obavijest obavijest;

  const NovostiDetailsScreen({super.key, required this.obavijest});

  @override
  State<NovostiDetailsScreen> createState() => _NovostiDetailsScreenState();
}

class _NovostiDetailsScreenState extends State<NovostiDetailsScreen> {
  NovostById? novost;
  KorisnikById? autor;
  KorisnikById? uredio;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedNovost = await ApiService().getNovostById(
        widget.obavijest.id,
      );
      final fetchedAutor = await ApiService().getKorisnikById(
        fetchedNovost.korisnikId,
      );

      KorisnikById? urednik;
      if (fetchedNovost.modifyBy != null && fetchedNovost.modifyBy != 0) {
        urednik = await ApiService().getKorisnikById(fetchedNovost.modifyBy!);
      }

      setState(() {
        novost = fetchedNovost;
        autor = fetchedAutor;
        uredio = urednik;
        loading = false;
      });
    } catch (e) {
      print("Greška: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Detalji Novosti",
      loading || novost == null || autor == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ), // padding za sav sadržaj osim slike
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slika "izvucena" iz paddinga
                Container(
                  margin: const EdgeInsets.only(
                    left: -24,
                    right: -24,
                  ), // uklanjamo padding
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        novost!.slika != null &&
                                novost!.slika!.isNotEmpty &&
                                novost!.slika != "string"
                            ? Image.memory(
                              base64Decode(novost!.slika!),
                              height: 400, // viša slika
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                ),
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // Ostatak sadržaja ide sa paddingom od 24
                Text(
                  novost!.naslov,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Objavljeno: ${novost!.datumObjave.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Autor: ${autor!.punoIme}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (novost!.datumUredjivanja != null && uredio != null)
                          Text(
                            "Uređeno: ${novost!.datumUredjivanja!.toLocal().toString().split(' ')[0]} od ${uredio!.punoIme}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      novost!.sadrzaj,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
