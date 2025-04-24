import 'dart:convert';

import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:flutter/material.dart';

class NovostiDetailsScreen extends StatelessWidget {
  final Obavijest obavijest;

  const NovostiDetailsScreen({super.key, required this.obavijest});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Detalji Novosti",
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            obavijest.slika != null &&
                    obavijest.slika!.isNotEmpty &&
                    obavijest.slika != "string"
                ? Image.memory(base64Decode(obavijest.slika!))
                : const SizedBox(
                  height: 150,
                  child: Center(child: Icon(Icons.image, size: 50)),
                ),
            const SizedBox(height: 16),
            Text(
              obavijest.naslov,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Objavljeno: ${obavijest.datumObjave.toLocal()}".split(' ')[0],
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(obavijest.sadrzaj, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
