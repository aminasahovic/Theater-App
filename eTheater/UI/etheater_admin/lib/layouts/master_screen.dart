import 'package:etheater_admin/screens/predstava_list_screen.dart';
import 'package:etheater_admin/screens/user_list_screen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
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
              title: Text("Administracija Korisnika"),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
            ),
            ListTile(
              title: Text("Predstave"),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PredstaveScreen()),
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
