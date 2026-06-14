import 'dart:async';
import 'dart:convert';
import 'package:etheater_mobile/screens/master_screen.dart';
import 'package:etheater_mobile/screens/moje_rezervacije_screen.dart';
import 'package:etheater_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:etheater_mobile/models/model.dart';
import 'package:etheater_mobile/providers/auth_provider.dart';
import 'package:etheater_mobile/services/api_service.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:intl/intl.dart';

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
  String _nacinPlacanja = 'Gotovina';
  bool _loading = false;
  String? _paypalPaymentId;

  Future<void> _rezervisi() async {
    if (_nacinPlacanja == 'PayPal') {
      final success = await _startPayPalPayment();
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PayPal plaćanje nije uspjelo.'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
        return;
      }
    }

    await ApiService.posaljiPotvrdu(
      korisnikId: AuthProvider.userId,
      nazivPredstave: widget.predstava.naziv,
      datumPrikazivanja: widget.izvedba.datumVrijemeIzvodjenja,
      sala: 'Velika sala',
      brojKarata: widget.odabranaSjedista.length,
      ukupnaCijena: widget.odabranaSjedista.length * widget.izvedba.cijenaKarte,
      isRezervacija: _nacinPlacanja == 'Gotovina',
    );

    setState(() => _loading = true);

    final request = RezervacijaRequest(
      korisnikId: AuthProvider.userId!,
      izvedbaId: widget.izvedba.id,
      brojKarata: widget.odabranaSjedista.length,
      odabranaSjedista: widget.odabranaSjedista,
      isUsedTicket: false,
      paymentId: _paypalPaymentId,
    );

    try {
      await ApiService.rezervisiKupovinu(request);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MojeRezervacijeScreen()),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Uspješno ste rezervisali karte! Pronađite ih u "Moje rezervacije".',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.odabranaSjedista.length;
    final ukupno = widget.izvedba.cijenaKarte * count;

    return MasterScreen(
      'Pregled kupovine',
      Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  if (widget.predstava.plakat != null)
                    Stack(
                      children: [
                        Image.memory(
                          base64Decode(widget.predstava.plakat!),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.pageBackground.withOpacity(0.95),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show name
                        Text(
                          widget.predstava.naziv,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat(
                            'dd.MM.yyyy. HH:mm',
                          ).format(widget.izvedba.datumVrijemeIzvodjenja),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Summary card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              _DetailRow(
                                label: 'Cijena po karti',
                                value:
                                    '${widget.izvedba.cijenaKarte.toStringAsFixed(2)} KM',
                              ),
                              const SizedBox(height: 10),
                              _DetailRow(label: 'Broj karata', value: '$count'),
                              const SizedBox(height: 10),
                              _DetailRow(
                                label: 'Sjedišta',
                                value: widget.odabranaSjedista
                                    .map((s) => '#${s.sjedisteId}')
                                    .join(', '),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Ukupno',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${ukupno.toStringAsFixed(2)} KM',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Payment method
                        const Text(
                          'NAČIN PLAĆANJA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _PaymentOption(
                          value: 'Gotovina',
                          groupValue: _nacinPlacanja,
                          icon: Icons.payments_outlined,
                          iconColor: AppTheme.success,
                          label: 'Gotovina na blagajni',
                          description: 'Platite pri preuzimanju karata',
                          onChanged: (v) => setState(() => _nacinPlacanja = v!),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOption(
                          value: 'PayPal',
                          groupValue: _nacinPlacanja,
                          icon: Icons.account_balance_wallet_outlined,
                          iconColor: const Color(0xFF0070BA),
                          label: 'PayPal',
                          description: 'Sigurno online plaćanje',
                          onChanged: (v) => setState(() => _nacinPlacanja = v!),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _rezervisi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _nacinPlacanja == 'PayPal'
                                    ? Icons.payment_outlined
                                    : Icons.check_circle_outline,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _nacinPlacanja == 'PayPal'
                                    ? 'Plati putem PayPal-a'
                                    : 'Potvrdi rezervaciju',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _startPayPalPayment() async {
    String? paymentId;
    bool cancel = false;
    final completer = Completer<bool>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => UsePaypal(
              sandboxMode: true,
              clientId:
                  'AWwW3Fuc0nmtIMp4pDMuZk5jBT-bw5xRHHKF8pgipgSp_89Tz97GLMSDwohCVDOHvglzOmLAQ2c7j-N-',
              secretKey:
                  'EBIHrq8vvGtHPUNtvV0VQchBEXLApqQ32GWbed50JwqAjgg5wANsR7pejsI-zINuvRRsATHhbeySz9fv',
              returnURL: 'https://samplesite.com/return',
              cancelURL: 'https://samplesite.com/cancel',
              transactions: [
                {
                  'amount': {
                    'total': double.parse(
                      (widget.izvedba.cijenaKarte *
                              0.55 *
                              widget.odabranaSjedista.length)
                          .toStringAsFixed(2),
                    ),
                    'currency': 'USD',
                  },
                  'description': 'Plaćanje za rezervaciju predstave.',
                  'item_list': {
                    'items': [
                      {
                        'name': widget.predstava.naziv,
                        'quantity': widget.odabranaSjedista.length,
                        'price': double.parse(
                          (widget.izvedba.cijenaKarte * 0.55).toStringAsFixed(
                            2,
                          ),
                        ),
                        'currency': 'USD',
                      },
                    ],
                  },
                },
              ],
              note: 'Kontaktirajte nas za dodatne informacije.',
              onSuccess: (Map params) {
                paymentId = params['paymentId'];
                completer.complete(true);
              },
              onError: (_) => completer.complete(false),
              onCancel: (_) {
                cancel = true;
              },
            ),
      ),
    );

    final result = await completer.future;
    if (cancel || !result) return false;

    setState(() => _paypalPaymentId = paymentId);
    return true;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentTint : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFe8e8e8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
