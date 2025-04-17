import 'package:etheater_admin/screens/glumci_screen.dart';
import 'package:etheater_admin/screens/reziseri_screen.dart';
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
  bool _osobljeExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Gornji logo dio sa centriranom slikom
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  height: 100,
                  width: 100,
                ),
              ),
            ),

            // Nazad
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text("Nazad", style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),

            // Korisnici
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text(
                "Administracija Korisnika",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => UserListScreen()),
                );
              },
            ),

            // Predstave
            ListTile(
              leading: const Icon(Icons.theaters),
              title: const Text(
                "Predstave",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PredstaveScreen()),
                );
              },
            ),

            // Expandable: Administracija Osoblja
            ExpansionTile(
              leading: const Icon(Icons.group, color: Colors.black),
              title: const Text(
                "Administracija Osoblja",
                style: TextStyle(color: Colors.black),
              ),
              initiallyExpanded: _osobljeExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _osobljeExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  leading: const Icon(Icons.person, size: 20),
                  title: const Text("Glumci"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GlumciScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_camera_back, size: 20),
                  title: const Text("Režiseri"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReziseriScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
