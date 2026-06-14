import 'dart:convert';
import 'package:etheater_mobile/core/api_konstante.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:etheater_mobile/screens/moje_rezervacije_screen.dart';
import 'package:etheater_mobile/screens/novosti_screen.dart';
import 'package:etheater_mobile/screens/profile_screen.dart';
import 'package:etheater_mobile/screens/repertoar_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

const _navTitles = ['Novosti', 'Repertoar', 'Moje rezervacije'];

class MasterScreen extends StatefulWidget {
  final String title;
  final Widget child;
  final int? bottomNavIndex;

  const MasterScreen(this.title, this.child, {super.key, this.bottomNavIndex});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isSending = false;
  bool _chatOpen = false;

  late AnimationController _chatAnim;
  late Animation<double> _chatFade;
  late Animation<Offset> _chatSlide;

  @override
  void initState() {
    super.initState();
    _chatAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _chatFade = CurvedAnimation(parent: _chatAnim, curve: Curves.easeOut);
    _chatSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _chatAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _chatAnim.dispose();
    super.dispose();
  }

  Future<String> _getChatbotResponse(
    String prompt,
    String previousResponse,
  ) async {
    final url = Uri.parse('${ApiKonstante.baseUrl}/api/Chat');
    final payload = {'message': prompt, 'previousResponse': previousResponse};
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        return 'Greška na serveru. (status: ${response.statusCode})';
      }
      final data = jsonDecode(response.body);
      String reply = data['reply'] ?? '';
      return reply.replaceAll('\\n', '\n').replaceAll('\\"', '"');
    } catch (_) {
      return 'Nije moguće uspostaviti vezu sa serverom.';
    }
  }

  void _toggleChat() {
    setState(() => _chatOpen = !_chatOpen);
    if (_chatOpen) {
      _chatAnim.forward();
    } else {
      _chatAnim.reverse();
    }
  }

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final prevBot =
        _messages.lastWhere(
          (m) => m['sender'] == 'bot',
          orElse: () => {'text': ''},
        )['text'] ??
        '';

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _chatController.clear();
      _isSending = true;
      _messages.add({'sender': 'bot', 'text': '...'});
    });
    _scrollChatToBottom();

    final reply = await _getChatbotResponse(text, prevBot);

    setState(() {
      _messages.removeWhere((m) => m['text'] == '...');
      _messages.add({'sender': 'bot', 'text': reply});
      _isSending = false;
    });
    _scrollChatToBottom();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  int get _activeNavIndex {
    if (widget.bottomNavIndex != null) return widget.bottomNavIndex!;
    final idx = _navTitles.indexOf(widget.title);
    return idx < 0 ? 0 : idx;
  }

  void _onNavTap(int index) {
    if (index == _activeNavIndex) return;
    final destinations = [
      () => const NovostiScreen(),
      () => const RepertoarScreen(),
      () => const MojeRezervacijeScreen(),
    ];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destinations[index](),
        transitionsBuilder:
            (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMainScreen = _navTitles.contains(widget.title);

    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(),
          drawer: _buildDrawer(),
          bottomNavigationBar: isMainScreen ? _buildBottomNav() : null,
          body: widget.child,
        ),

        // Chat panel (inline overlay)
        if (_chatOpen)
          Positioned(
            bottom: isMainScreen ? 76 : 16,
            right: 16,
            left: 16,
            child: FadeTransition(
              opacity: _chatFade,
              child: SlideTransition(
                position: _chatSlide,
                child: _buildChatPanel(),
              ),
            ),
          ),

        // Chat FAB
        Positioned(
          bottom: isMainScreen ? 76 : 16,
          right: 16,
          child: _buildChatFab(),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.appBarGradient,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _activeNavIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Novosti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.theaters_outlined),
            activeIcon: Icon(Icons.theaters),
            label: 'Repertoar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Rezervacije',
          ),
        ],
      ),
    );
  }

  Widget _buildChatFab() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        heroTag: 'chatFab',
        onPressed: _toggleChat,
        backgroundColor: _chatOpen ? AppTheme.darkBg2 : AppTheme.primary,
        elevation: 4,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _chatOpen ? Icons.close : Icons.chat_bubble_outline,
            key: ValueKey(_chatOpen),
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppTheme.darkBg2, AppTheme.primary],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'eTheater Asistent',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Uvijek tu za vas',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child:
                  _messages.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 40,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Postavite pitanje o repertoaru\nili pozorištu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        controller: _chatScrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _buildMessage(_messages[i]),
                      ),
            ),

            // Input row
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Unesite poruku...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFfdf7f9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                      : Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, size: 18),
                          color: Colors.white,
                          onPressed: _sendMessage,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, String> m) {
    final isUser = m['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border:
              isUser
                  ? null
                  : Border.all(color: const Color(0xFFf5c2d0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: RichText(
          text: _parseBoldText(
            m['text']!,
            color: isUser ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  TextSpan _parseBoldText(String text, {required Color color}) {
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    int start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(color: color, fontSize: 14),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(color: color, fontSize: 14),
        ),
      );
    }
    return TextSpan(children: spans);
  }

  Widget _buildDrawer() {
    final username = AuthProvider.username ?? 'Gost';
    return Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(username),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.article_outlined,
                    label: 'Novosti',
                    active: widget.title == 'Novosti',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.title != 'Novosti') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NovostiScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.theaters_outlined,
                    label: 'Repertoar',
                    active: widget.title == 'Repertoar',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.title != 'Repertoar') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RepertoarScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Moje rezervacije',
                    active: widget.title == 'Moje rezervacije',
                    onTap: () {
                      Navigator.pop(context);
                      if (widget.title != 'Moje rezervacije') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MojeRezervacijeScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  const SizedBox(height: 8),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    onTap: () {
                      Navigator.pop(context);
                      if (AuthProvider.userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProfileScreen(
                                  korisnikId: AuthProvider.userId!,
                                ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Logout
          Container(
            color: Colors.white,
            child: Column(
              children: [
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppTheme.danger,
                    size: 22,
                  ),
                  title: const Text(
                    'Odjava',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    AuthProvider.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(String username) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(gradient: AppTheme.drawerHeaderGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      AuthProvider.slika != null
                          ? Image.memory(
                            base64Decode(AuthProvider.slika!),
                            fit: BoxFit.cover,
                          )
                          : Container(
                            color: AppTheme.primary.withOpacity(0.6),
                            child: Center(
                              child: Text(
                                username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                ),
              ),
              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (AuthProvider.userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProfileScreen(
                                korisnikId: AuthProvider.userId!,
                              ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'eTheater korisnik',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: active ? AppTheme.primary : AppTheme.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppTheme.primary : AppTheme.textPrimary,
          ),
        ),
        trailing:
            active
                ? Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
                : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        minLeadingWidth: 0,
      ),
    );
  }
}
