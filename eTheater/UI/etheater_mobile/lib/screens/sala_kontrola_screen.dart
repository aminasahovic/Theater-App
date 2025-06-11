import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import '../services/api_service.dart'; // Prilagodi putanju ako je drugačija

class SalaKontrolaScreen extends StatefulWidget {
  const SalaKontrolaScreen({super.key});

  @override
  State<SalaKontrolaScreen> createState() => _SalaKontrolaScreenState();
}

class _SalaKontrolaScreenState extends State<SalaKontrolaScreen> {
  String _scanResult = 'Nema rezultata';
  bool _isProcessing = false;

  Future<void> _handleScan(String tekst) async {
    setState(() {
      _scanResult = tekst;
      _isProcessing = true;
    });

    try {
      final rezervacijaId = int.parse(tekst.trim());
      await ApiService.useTicket(rezervacijaId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karta uspješno skenirana!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

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
                if (!_isProcessing) {
                  final tekst = result.text ?? 'Nepoznat sadržaj';
                  _handleScan(tekst);
                }
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
