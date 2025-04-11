import 'package:etheater_admin/services/services.dart';
import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required int predstavaId,
  required VoidCallback onDeleted,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Potvrda brisanja"),
          content: Text(
            "Da li ste sigurni da želite da obrišete ovu predstavu?",
          ),
          actions: [
            TextButton(
              child: Text("Otkaži"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Obriši"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
  );

  if (confirmed == true) {
    try {
      await ApiService.deletePredstava(predstavaId);
      onDeleted();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Predstava je uspješno obrisana.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri brisanju: ${e.toString()}")),
      );
    }
  }
}
