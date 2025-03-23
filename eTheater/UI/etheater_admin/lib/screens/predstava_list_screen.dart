import 'package:etheater_admin/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class PredstavaListScreen extends StatelessWidget {
  const PredstavaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Lista proizvoda",
      Column(
        children: [
          Text("Lista predstava placeholder"),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Nazad"),
          ),
        ],
      ),
    );
  }
}
