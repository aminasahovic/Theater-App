import 'package:etheater_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';

class PredstavaDetailScreen extends StatefulWidget {
  const PredstavaDetailScreen({super.key});

  @override
  State<PredstavaDetailScreen> createState() => _PredstavaDetailScreenState();
}

class _PredstavaDetailScreenState extends State<PredstavaDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      child: ElevatedButton(
        onPressed: () => {Navigator.of(context).pop()},
        child: Text("Login"),
      ),
      title: "Predstava detalji",
    );
  }
}
