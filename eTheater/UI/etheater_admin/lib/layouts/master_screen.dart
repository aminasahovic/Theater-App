import 'package:etheater_admin/screens/predstava_details_screen.dart';
import 'package:etheater_admin/screens/predstava_list_screen.dart';
import 'package:etheater_admin/screens/user_list_screen.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  MasterScreen(this.title, this.child, {super.key});
  String title;
  Widget child;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Back"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Detalji"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PredstavaDetailsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text("Korisnici"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Proizvodi"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PredstavaListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
