import 'dart:async';
import 'dart:convert';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/moje_rezervacije_screen.dart';
import 'package:flutter/material.dart';
import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/services/api_service.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

class PregledKupovineScreen extends StatefulWidget {
  final Predstava predstava;
  final Izvedba izvedba;
  final List<OdabranoSjediste> odabranaSjedista;

  const PregledKupovineScreen({
    super.key,
    required this.predstava,
    required this.izvedba,
    required this.odabranaSjedista,
  });

  @override
  State<PregledKupovineScreen> createState() => _PregledKupovineScreenState();
}

class _PregledKupovineScreenState extends State<PregledKupovineScreen> {
  String _nacinPlacanja = "Gotovina";
  bool _loading = false;
  String? _paypalPaymentId;

  Future<void> _rezervisi() async {
    if (_nacinPlacanja == "PayPal") {
      final success = await startPayPalPayment();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PayPal plaćanje nije uspjelo.')),
        );
        return;
      }
    }

    setState(() => _loading = true);
    final korisnikId = AuthProvider.userId!;
    final odabranaSjedista = widget.odabranaSjedista;

    final request = RezervacijaRequest(
      korisnikId: korisnikId,
      izvedbaId: widget.izvedba.id,
      brojKarata: odabranaSjedista.length,
      odabranaSjedista: odabranaSjedista,
      isUsedTicket: false,
      paymentId: _paypalPaymentId,
    );

    try {
      await ApiService.rezervisiKupovinu(request);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MojeRezervacijeScreen()),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Uspješno ste rezervisali vaše karte i možete ih pronaći u sekciji Moje rezervacije.',
            ),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Greška: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ukupnaCijena =
        widget.izvedba.cijenaKarte * widget.odabranaSjedista.length;

    return MasterScreen(
      "Pregled kupovine",
      Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.predstava.plakat != null)
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: ClipRRect(
                        child: Image.memory(
                          base64Decode(widget.predstava.plakat!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.predstava.naziv,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildDetailRow(
                          "Cijena karte:",
                          "${widget.izvedba.cijenaKarte.toStringAsFixed(2)} KM",
                        ),
                        _buildDetailRow(
                          "Broj karata:",
                          widget.odabranaSjedista.length.toString(),
                        ),
                        _buildDetailRow(
                          "Odabrana sjedista:",
                          widget.odabranaSjedista
                              .map((s) => "(${s.sjedisteId})")
                              .join(", "),
                        ),

                        const Divider(height: 32, thickness: 1),

                        _buildDetailRow(
                          "Ukupna cijena:",
                          "${ukupnaCijena.toStringAsFixed(2)} KM",
                          isBold: true,
                          fontSize: 18,
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "Način plaćanja:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        RadioListTile<String>(
                          value: "Gotovina",
                          groupValue: _nacinPlacanja,
                          title: Row(
                            children: const [
                              Icon(Icons.money, color: Colors.green),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Gotovina",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          onChanged: (value) {
                            setState(() {
                              _nacinPlacanja = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          value: "PayPal",
                          groupValue: _nacinPlacanja,
                          title: Row(
                            children: const [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "PayPal",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          onChanged: (value) {
                            setState(() {
                              _nacinPlacanja = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _rezervisi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _loading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _nacinPlacanja == "PayPal"
                                  ? "Plati"
                                  : "Rezerviši",
                              style: const TextStyle(fontSize: 18),
                            ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: Colors.grey[700],
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> startPayPalPayment() async {
    String? paymentId;
    bool cancel = false;
    var completer = Completer<bool>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (BuildContext context) => UsePaypal(
              sandboxMode: true,
              clientId:
                  "AWwW3Fuc0nmtIMp4pDMuZk5jBT-bw5xRHHKF8pgipgSp_89Tz97GLMSDwohCVDOHvglzOmLAQ2c7j-N-",
              secretKey:
                  "EBIHrq8vvGtHPUNtvV0VQchBEXLApqQ32GWbed50JwqAjgg5wANsR7pejsI-zINuvRRsATHhbeySz9fv",
              returnURL: "https://samplesite.com/return",
              cancelURL: "https://samplesite.com/cancel",
              transactions: [
                {
                  "amount": {
                    "total": double.parse(
                      ((widget.izvedba.cijenaKarte *
                              0.55 *
                              widget.odabranaSjedista.length))
                          .toStringAsFixed(2),
                    ),
                    "currency": "USD",
                  },
                  "description": "Plaćanje za rezervaciju predstave.",
                  "item_list": {
                    "items": [
                      {
                        "name": widget.predstava.naziv,
                        "quantity": widget.odabranaSjedista.length,
                        "price": double.parse(
                          (widget.izvedba.cijenaKarte * 0.55).toStringAsFixed(
                            2,
                          ),
                        ),
                        "currency": "USD",
                      },
                    ],
                  },
                },
              ],
              note: "Kontaktirajte nas za dodatne informacije.",
              onSuccess: (Map params) {
                paymentId = params['paymentId'];
                completer.complete(true);
              },
              onError: (error) {
                completer.complete(false);
              },
              onCancel: (params) {
                cancel = true;
              },
            ),
      ),
    );

    final result = await completer.future;

    if (cancel || !result) return false;

    setState(() {
      _paypalPaymentId = paymentId;
    });

    return true;
  }
}
