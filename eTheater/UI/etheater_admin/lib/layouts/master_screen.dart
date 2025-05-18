import 'package:etheater_admin/screens/glumci_screen.dart';
import 'package:etheater_admin/screens/izvedba_screen.dart';
import 'package:etheater_admin/screens/novosti_screen.dart';
import 'package:etheater_admin/screens/repertoar_screen.dart';
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
  bool _repertoarExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text("Nazad", style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context, true);
                Navigator.pop(context, true);
              },
            ),
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
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text(
                "Novosti",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NovostiScreen(),
                  ),
                );
              },
            ),
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
            ExpansionTile(
              leading: const Icon(Icons.event, color: Colors.black),
              title: const Text(
                "Repertoar",
                style: TextStyle(color: Colors.black),
              ),
              initiallyExpanded: _repertoarExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _repertoarExpanded = expanded;
                });
              },
              children: [
                ListTile(
                  leading: const Icon(Icons.event_available, size: 20),
                  title: const Text("Izvedbe"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const IzvedbaScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_music, size: 20),
                  title: const Text("Repertoar"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RepertoarScreen(),
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
