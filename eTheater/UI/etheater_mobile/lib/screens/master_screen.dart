import 'dart:convert';

import 'package:etheater_mobile/screens/moje_rezervacije_screen.dart';
import 'package:etheater_mobile/screens/novosti_screen.dart';
import 'package:etheater_mobile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:etheater_mobile/screens/repertoar_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class MasterScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const MasterScreen(this.title, this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final username = AuthProvider.username ?? "Nepoznat korisnik";

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 250,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            backgroundImage:
                                AuthProvider.slika != null
                                    ? MemoryImage(
                                      base64Decode(AuthProvider.slika!),
                                    )
                                    : null,
                            child:
                                AuthProvider.slika == null
                                    ? Text(
                                      username.isNotEmpty
                                          ? username[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontSize: 48,
                                        color: Colors.white,
                                      ),
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProfileScreen(
                                          korisnikId: AuthProvider.userId!,
                                        ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: const Text("Novosti"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NovostiScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.theaters_outlined),
                      title: const Text("Repertoar"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RepertoarScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event_seat_outlined),
                      title: const Text("Moje rezervacije"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MojeRezervacijeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  AuthProvider.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text("Nazad"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
