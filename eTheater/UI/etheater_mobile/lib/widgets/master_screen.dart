import 'package:etheater_mobile/screens/home.dart';
import 'package:etheater_mobile/widgets/predstava_detail_screen.dart';
import 'package:flutter/material.dart';

class MasterScreenWidget extends StatefulWidget {
  Widget? child;
  String? title;
  MasterScreenWidget({this.child, this.title, Key? key}) : super(key: key);

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? "")),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Predstava"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PredstavaDetailScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Home"),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => const Home()));
              },
            ),
          ],
        ),
      ),
      body: widget.child!,
    );
  }
}
