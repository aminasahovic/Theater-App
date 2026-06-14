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

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  void _posaljiKomentar() async {
    if (_ocjena == 0 || _komentarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unesite ocjenu i komentar.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.addKomentarPredstava(
        komentar: InsertKomentarPredstava(
          predstavaId: widget.predstavaId,
          ocjena: _ocjena,
          komentar: _komentarController.text.trim(),
          korisnikId: AuthProvider.userId!,
          datum: DateTime.now(),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onKomentarPoslan();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hvala! Vaša ocjena je zabilježena.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header icon badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFfde0e8), Color(0xFFf5c2d0)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.star_outline, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(height: 14),

          const Text(
            'Ocijenite predstavu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Podijelite svoje mišljenje s drugima',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final i = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _ocjena = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i <= _ocjena ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i <= _ocjena
                        ? AppTheme.amber
                        : Colors.grey.shade300,
                    size: 38,
                  ),
                ),
              );
            }),
          ),

          if (_ocjena > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _ratingLabel(_ocjena),
                style: TextStyle(
                  color: AppTheme.amber,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 18),

          // Comment field
          TextField(
            controller: _komentarController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Napišite vaš utisak o predstavi...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _posaljiKomentar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Pošalji ocjenu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int ocjena) {
    switch (ocjena) {
      case 1:
        return 'Loše';
      case 2:
        return 'Ispod prosjeka';
      case 3:
        return 'Prosječno';
      case 4:
        return 'Dobro';
      case 5:
        return 'Odlično!';
      default:
        return '';
    }
  }
}
