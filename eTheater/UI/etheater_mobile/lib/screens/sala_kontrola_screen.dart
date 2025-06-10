import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class SalaKontrolaScreen extends StatefulWidget {
  const SalaKontrolaScreen({super.key});

  @override
  State<SalaKontrolaScreen> createState() => _SalaKontrolaScreenState();
}

class _SalaKontrolaScreenState extends State<SalaKontrolaScreen> {
  String _scanResult = 'Nema rezultata';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontrola ulaza i popunjenosti sale')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRCodeDartScanView(
              scanInvertedQRCode: true,
              typeScan: TypeScan.live,
              onCapture: (result) {
                setState(() {
                  _scanResult = result.text ?? 'Nepoznat sadržaj';
                });
              },
              onCameraError: (error) {
                debugPrint('Greška kamere: $error');
              },
              imageDecodeOrientation: ImageDecodeOrientation.portrait,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Rezultat: $_scanResult',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
