import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/services/api_service.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OcijeniPredstavuSheet extends StatefulWidget {
  final int predstavaId;
  final VoidCallback onKomentarPoslan;

  const OcijeniPredstavuSheet({
    super.key,
    required this.predstavaId,
    required this.onKomentarPoslan,
  });

  @override
  State<OcijeniPredstavuSheet> createState() => _OcijeniPredstavuSheetState();
}

class _OcijeniPredstavuSheetState extends State<OcijeniPredstavuSheet> {
  int _ocjena = 0;
  final TextEditingController _komentarController = TextEditingController();
  bool _loading = false;

  void _posaljiKomentar() async {
    if (_ocjena == 0 || _komentarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unesite ocjenu i komentar.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final komentar = InsertKomentarPredstava(
        predstavaId: widget.predstavaId,
        ocjena: _ocjena,
        komentar: _komentarController.text.trim(),
        korisnikId: AuthProvider.userId!,
        datum: DateTime.now(),
      );

      await ApiService.addKomentarPredstava(komentar: komentar);
      Navigator.of(context).pop();
      widget.onKomentarPoslan();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Komentar uspješno poslan!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Greška: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ocijeni predstavu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final i = index + 1;
              return IconButton(
                icon: Icon(
                  Icons.star,
                  color: i <= _ocjena ? Colors.amber : Colors.grey[400],
                  size: 32,
                ),
                onPressed: () => setState(() => _ocjena = i),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _komentarController,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Unesite komentar'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _posaljiKomentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child:
                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pošalji'),
            ),
          ),
        ],
      ),
    );
  }
}
