import 'package:flutter/material.dart';
import 'package:etheater_admin/models/models.dart';
import 'package:etheater_admin/services/services.dart';

class EditKorisnikaDialog extends StatefulWidget {
  final KorisnikVM korisnik;
  final List<TipKorisnika> tipovi;
  final VoidCallback onUpdate;

  const EditKorisnikaDialog({
    super.key,
    required this.korisnik,
    required this.tipovi,
    required this.onUpdate,
  });

  @override
  State<EditKorisnikaDialog> createState() => _EditKorisnikaDialogState();
}

class _EditKorisnikaDialogState extends State<EditKorisnikaDialog> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _imeController;
  late TextEditingController _prezimeController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _brojTelefonaController;

  TipKorisnika? _odabraniTip;
  bool _isActive = true;

  bool _showPasswordFields = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _imeController = TextEditingController(text: widget.korisnik.ime);
    _prezimeController = TextEditingController(text: widget.korisnik.prezime);
    _emailController = TextEditingController(text: widget.korisnik.email);
    _usernameController = TextEditingController(text: widget.korisnik.username);
    _brojTelefonaController = TextEditingController(
      text: widget.korisnik.brojTelefona,
    );
    _odabraniTip = widget.tipovi.firstWhere(
      (tip) => tip.id == widget.korisnik.tipKorisnikaId,
      orElse: () => widget.tipovi.first,
    );
    _isActive = widget.korisnik.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uredi korisnika'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 400, maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    _imeController,
                    'Ime',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite ime';
                      }
                      if (!RegExp(r"^[A-ZČĆŽŠĐ][a-zčćžšđ]+$").hasMatch(value)) {
                        return 'Ime mora početi velikim slovom i sadržavati samo slova';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _prezimeController,
                    'Prezime',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite prezime';
                      }
                      if (!RegExp(r"^[A-ZČĆŽŠĐ][a-zčćžšđ]+$").hasMatch(value)) {
                        return 'Prezime mora početi velikim slovom i sadržavati samo slova';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _emailController,
                    'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite email';
                      }
                      if (!RegExp(
                        r"^[\w\.-]+@[\w\.-]+\.\w+$",
                      ).hasMatch(value)) {
                        return 'Neispravan format emaila';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _usernameController,
                    'Korisničko ime',
                    readOnly: true,
                  ),
                  _buildTextField(
                    _brojTelefonaController,
                    'Broj telefona',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite broj telefona';
                      }
                      if (!RegExp(r"^\d+$").hasMatch(value)) {
                        return 'Broj telefona mora sadržavati samo cifre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TipKorisnika>(
                    decoration: const InputDecoration(
                      labelText: 'Tip korisnika',
                    ),
                    value: _odabraniTip,
                    items:
                        widget.tipovi
                            .map(
                              (tip) => DropdownMenuItem(
                                value: tip,
                                child: Text(tip.naziv),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _odabraniTip = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Aktivan korisnik'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Promijeni lozinku"),
                      IconButton(
                        icon: Icon(
                          _showPasswordFields
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPasswordFields = !_showPasswordFields;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_showPasswordFields) ...[
                    _buildTextField(
                      _passwordController,
                      'Nova lozinka',
                      obscureText: true,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 3) {
                          return 'Lozinka mora imati barem 3 znaka';
                        }
                        return null;
                      },
                    ),
                    _buildTextField(
                      _confirmPasswordController,
                      'Potvrdi lozinku',
                      obscureText: true,
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty &&
                            value != _passwordController.text) {
                          return 'Lozinke se ne poklapaju';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Otkaži'),
        ),
        ElevatedButton(onPressed: _saveChanges, child: const Text('Spasi')),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        readOnly: readOnly,
      ),
    );
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = KorisnikUpdateRequest(
      ime: _imeController.text,
      prezime: _prezimeController.text,
      email: _emailController.text,
      brojTelefona: _brojTelefonaController.text,
      tipKorisnikaId: _odabraniTip!.id,
      isActive: _isActive,
      password:
          _showPasswordFields && _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
      passwordPotvrda: _confirmPasswordController.text,
    );

    try {
      await _apiService.updateKorisnik(widget.korisnik.id, updatedData);
      widget.onUpdate();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greška: $e')));
    }
  }
}
