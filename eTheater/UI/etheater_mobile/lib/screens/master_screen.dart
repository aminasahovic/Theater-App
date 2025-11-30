import 'dart:convert';
import 'package:etheater_mobile/core/api_konstante.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:etheater_mobile/screens/moje_rezervacije_screen.dart';
import 'package:etheater_mobile/screens/novosti_screen.dart';
import 'package:etheater_mobile/screens/profile_screen.dart';
import 'package:etheater_mobile/screens/repertoar_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class MasterScreen extends StatefulWidget {
  final String title;
  final Widget child;

  const MasterScreen(this.title, this.child, {super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  bool _isSending = false;

  Future<String> getChatbotResponse(String prompt) async {
    final url = Uri.parse("${ApiKonstante.baseUrl}/api/Chat");

    final payload = {"message": prompt};

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "accept": "*/*"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      return "Greška na serveru. (status: ${response.statusCode})";
    }

    final data = jsonDecode(response.body);

    String reply = data["reply"] ?? "";

    reply = reply.replaceAll("\\n", "\n").replaceAll("\\\"", "\"");

    return reply;
  }

  void _openChatPopup() {
    setState(() {
      _messages.clear();
    });

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: double.maxFinite,
                height: 430,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      "ChatBot",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),

                    Expanded(
                      child: ListView(
                        children:
                            _messages
                                .map(
                                  (m) => Container(
                                    alignment:
                                        m["sender"] == "user"
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 6,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            m["sender"] == "user"
                                                ? AppTheme.primaryColor
                                                : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: RichText(
                                        text: parseBoldText(
                                          m["text"]!,
                                          color:
                                              m["sender"] == "user"
                                                  ? Colors.white
                                                  : Colors.brown.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            decoration: InputDecoration(
                              hintText: "Unesite poruku...",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            shadowColor: Colors.grey,
                            elevation: 4,
                          ),
                          onPressed:
                              _isSending
                                  ? null
                                  : () async {
                                    final text = _chatController.text.trim();
                                    if (text.isEmpty) return;

                                    setStatePopup(() {
                                      _messages.add({
                                        "sender": "user",
                                        "text": text,
                                      });
                                      _chatController.clear();
                                      _isSending = true;
                                      _messages.add({
                                        "sender": "bot",
                                        "text": "tipka...",
                                      });
                                    });

                                    final previousResponse =
                                        _messages.lastWhere(
                                          (m) => m["sender"] == "bot",
                                          orElse: () => {"text": ""},
                                        )["text"] ??
                                        "";

                                    final botReply =
                                        await getChatbotResponseWithPrevious(
                                          text,
                                          previousResponse,
                                        );

                                    setStatePopup(() {
                                      _messages.removeWhere(
                                        (m) => m["text"] == "tipka...",
                                      );
                                      _messages.add({
                                        "sender": "bot",
                                        "text": botReply,
                                      });
                                      _isSending = false;
                                    });
                                  },
                          child: Icon(Icons.send, color: Colors.brown.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String> getChatbotResponseWithPrevious(
    String prompt,
    String previousResponse,
  ) async {
    final url = Uri.parse("${ApiKonstante.baseUrl}/api/Chat");

    final payload = {"message": prompt, "previousResponse": previousResponse};

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "accept": "*/*"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      return "Greška na serveru. (status: ${response.statusCode})";
    }

    final data = jsonDecode(response.body);
    String reply = data["reply"] ?? "";
    reply = reply.replaceAll("\\n", "\n").replaceAll("\\\"", "\"");

    return reply;
  }

  @override
  Widget build(BuildContext context) {
    final username = AuthProvider.username ?? "Nepoznat korisnik";

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 4,
          ),
          drawer: _buildDrawer(context, username),
          body: widget.child,
        ),

        Positioned(
          bottom: 25,
          right: 25,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _openChatPopup,
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.brown.shade800,
              size: 28,
            ),
            elevation: 6,
          ),
        ),
      ],
    );
  }

  TextSpan parseBoldText(String text, {Color? color}) {
    List<TextSpan> spans = [];
    final regex = RegExp(r"\*\*(.*?)\*\*");
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(color: color),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(text: text.substring(start), style: TextStyle(color: color)),
      );
    }

    return TextSpan(children: spans);
  }

  Widget _buildDrawer(BuildContext context, String username) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _drawerHeader(username),
            const Divider(),
            Expanded(child: _drawerMenu(context)),
            const Divider(),
            _drawerLogout(context),
            _drawerBack(context),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerHeader(String username) {
    return Container(
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
                          ? MemoryImage(base64Decode(AuthProvider.slika!))
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
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerMenu(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          leading: const Icon(Icons.article_outlined),
          title: const Text("Novosti"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NovostiScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.theaters_outlined),
          title: const Text("Repertoar"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RepertoarScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.event_seat_outlined),
          title: const Text("Moje rezervacije"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MojeRezervacijeScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _drawerLogout(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text("Logout", style: TextStyle(color: Colors.red)),
      onTap: () {
        AuthProvider.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }

  Widget _drawerBack(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.arrow_back),
      title: const Text("Nazad"),
      onTap: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }
}
