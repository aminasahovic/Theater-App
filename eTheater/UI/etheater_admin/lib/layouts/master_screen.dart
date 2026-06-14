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
  final String title;
  final Widget child;

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
      body: Row(
        children: [
          // --- Sidebar (fixed) ---
          Container(
            width: 250,
            color: Colors.white,
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
                        leading: const Icon(Icons.people),
                        title: const Text("Administracija Korisnika"),
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => UserListScreen()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.theaters),
                        title: const Text("Predstave"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PredstaveScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.newspaper),
                        title: const Text("Novosti"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NovostiScreen(),
                            ),
                          );
                        },
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.group),
                        title: const Text("Administracija Osoblja"),
                        initiallyExpanded: _osobljeExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _osobljeExpanded = expanded);
                        },
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person, size: 20),
                            title: const Text("Glumci"),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const GlumciScreen(),
                                  ),
                                ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.video_camera_back,
                              size: 20,
                            ),
                            title: const Text("Režiseri"),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ReziseriScreen(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.event),
                        title: const Text("Repertoar"),
                        initiallyExpanded: _repertoarExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _repertoarExpanded = expanded);
                        },
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.event_available,
                              size: 20,
                            ),
                            title: const Text("Izvedbe"),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const IzvedbaScreen(),
                                  ),
                                ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.library_music, size: 20),
                            title: const Text("Repertoar"),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RepertoarScreen(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.comment),
                        title: const Text("Upravljanje komentarima"),
                        initiallyExpanded: _komentariExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _komentariExpanded = expanded);
                        },
                        children: [
                          ListTile(
                            leading: const Icon(Icons.theater_comedy, size: 20),
                            title: const Text("Komentari na predstave"),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => KomentariPredstaveScreen(),
                                  ),
                                ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.announcement, size: 20),
                            title: const Text("Komentari na obavijesti"),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => KomentariNovostiScreen(),
                                  ),
                                ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          bool? potvrda = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Odjava'),
                                  content: const Text(
                                    'Da li ste sigurni da se želite odjaviti?',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Otkaži'),
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Odjavi se'),
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                    ),
                                  ],
                                ),
                          );

                          if (potvrda == true) {
                            AuthProvider.logout();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Glavni sadržaj ---
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
