import 'package:etheater_admin/providers/auth_providers.dart';
import 'package:etheater_admin/screens/glumci_screen.dart';
import 'package:etheater_admin/screens/izvedba_screen.dart';
import 'package:etheater_admin/screens/komentari_novosti_screen.dart';
import 'package:etheater_admin/screens/komentari_predstave_screen.dart';
import 'package:etheater_admin/screens/login_screen.dart';
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
  bool _komentariExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: const Text(
                      "Nazad",
                      style: TextStyle(color: Colors.black),
                    ),
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
                        MaterialPageRoute(
                          builder: (context) => UserListScreen(),
                        ),
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
                        MaterialPageRoute(
                          builder: (context) => PredstaveScreen(),
                        ),
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
                  ExpansionTile(
                    leading: const Icon(Icons.comment, color: Colors.black),
                    title: const Text(
                      "Upravljanje komentarima",
                      style: TextStyle(color: Colors.black),
                    ),
                    initiallyExpanded: _komentariExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _komentariExpanded = expanded;
                      });
                    },
                    children: [
                      ListTile(
                        leading: const Icon(Icons.theater_comedy, size: 20),
                        title: const Text("Komentari na predstave"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => KomentariPredstaveScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.announcement, size: 20),
                        title: const Text("Komentari na obavijesti"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => KomentariNovostiScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  bool? potvrda = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Odjava'),
                        content: const Text(
                          'Da li ste sigurni da se želite odjaviti?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Otkaži'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('Odjavi se'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );

                  if (potvrda == true) {
                    AuthProvider.logout();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),

      body: widget.child,
    );
  }
}
