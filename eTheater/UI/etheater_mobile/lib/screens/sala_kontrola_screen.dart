import 'package:flutter/material.dart';

class SalaKontrolaScreen extends StatelessWidget {
  const SalaKontrolaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontrola ulaza i popunjenosti sale')),
      body: const Center(
        child: Text(
          'Ovdje ide funkcionalnost za skeniranje karata i praćenje sale.',
        ),
      ),
    );
  }
}
