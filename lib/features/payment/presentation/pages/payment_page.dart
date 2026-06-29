import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import '../pages/receipt_page.dart';

class PaymentPage extends StatefulWidget {
  final Property property;
  final DateTime checkInDate;
  final int durationMonths;
  final PaymentScheme scheme;
  final PaymentMethod method;

  const PaymentPage({
    super.key,
    required this.property,
    required this.checkInDate,
    required this.durationMonths,
    required this.scheme,
    required this.method,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late AppTransaction _transaction;
  bool _isCreated = false;
  bool _isConfirming = false;

  // Countdown 30 minutes
  late Timer _timer;
  int _remainingSeconds = 30 * 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _createTransaction());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _createTransaction() {
    final appState = context.read<AppState>();
    try {
      _transaction = appState.createTransaction(
        property: widget.property,
        checkInDate: widget.checkInDate,
        durationMonths: widget.durationMonths,
        scheme: widget.scheme,
        method: widget.method,
      );
      setState(() => _isCreated = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat transaksi: $e')),
      );
    }
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _amountToPay {
    switch (widget.scheme) {
      case PaymentScheme.penuh:
        return CurrencyFormatter.format(
            widget.property.pricePerMonth * widget.durationMonths);
      case PaymentScheme.dp:
        return CurrencyFormatter.format(widget.property.dpAmount);
      case PaymentScheme.cicilan:
        final total = widget.property.pricePerMonth * widget.durationMonths;
        return CurrencyFormatter.format(total / widget.property.maxTermin);
    }
  }

  void _confirmPayment() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.read<AppState>().confirmPayment(_transaction.id);
    _timer.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReceiptPage(transaction: _transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Timer ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _remainingSeconds < 300
                    ? AppColors.danger50
                    : AppColors.warning50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _remainingSeconds < 300
                      ? AppColors.danger500
                      : AppColors.warning500,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: _remainingSeconds < 300
                        ? AppColors.danger500
                        : AppColors.warning700,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selesaikan pembayaran dalam',
                      style: AppTextStyles.bodySm.copyWith(
                        color: _remainingSeconds < 300
                            ? AppColors.danger700
                            : AppColors.warning700,
                      ),
                    ),
                  ),
                  Text(
                    _timerText,
                    style: AppTextStyles.displaySm.copyWith(
                      color: _remainingSeconds < 300
                          ? AppColors.danger500
                          : AppColors.warning700,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Property Summary ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Pesanan', style: AppTextStyles.labelLg),
                  const Divider(height: 16),
                  InfoRow(
                      icon: Icons.apartment_rounded,
                      label: 'Properti',
                      value: widget.property.name),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Check-in',
                    value: DateFormatter.formatShort(widget.checkInDate),
                  ),
                  InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Durasi',
                    value: '${widget.durationMonths} bulan',
                  ),
                  InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Skema',
                    value: widget.scheme == PaymentScheme.penuh
                        ? 'Bayar Penuh'
                        : widget.scheme == PaymentScheme.dp
                            ? 'DP'
                            : 'Cicilan',
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.receipt_outlined,
                          size: 18, color: AppColors.textTertiary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Jumlah Bayar',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Text(
                        _amountToPay,
                        style: AppTextStyles.priceLg,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Payment Method Detail ─────────────────────────
            widget.method == PaymentMethod.va
                ? _VAPaymentCard(vaNumber: _transaction.vaNumber)
                : _QRISPaymentCard(),

            const SizedBox(height: 24),

            // ── Instructions ──────────────────────────────────
            Text('Cara Pembayaran',
                style: AppTextStyles.displaySm.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            ..._getInstructions().asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Text(e.value,
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: AppColors.textSecondary))),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── Bottom CTA ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: AppButton(
          label: 'Konfirmasi Pembayaran',
          onPressed: _isConfirming ? null : _confirmPayment,
          isLoading: _isConfirming,
          variant: AppButtonVariant.primary,
          size: AppButtonSize.lg,
          leadingIcon: Icons.check_circle_outline_rounded,
        ),
      ),
    );
  }

  List<String> _getInstructions() {
    if (widget.method == PaymentMethod.va) {
      return [
        'Buka aplikasi mobile banking atau ATM Anda',
        'Pilih menu Transfer atau Bayar → Virtual Account',
        'Masukkan nomor VA yang tertera di atas',
        'Periksa detail pembayaran, pastikan nominal sesuai',
        'Konfirmasi pembayaran dan tekan tombol di bawah',
      ];
    } else {
      return [
        'Buka aplikasi e-wallet atau mobile banking',
        'Pilih menu Scan QR / QRIS',
        'Scan QR Code yang tertera di atas',
        'Periksa detail dan nominal pembayaran',
        'Konfirmasi pembayaran dan tekan tombol di bawah',
      ];
    }
  }
}

// ── VA Card ───────────────────────────────────────────────────
class _VAPaymentCard extends StatelessWidget {
  final String vaNumber;
  const _VAPaymentCard({required this.vaNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_outlined,
                  color: AppColors.primary500, size: 22),
              const SizedBox(width: 8),
              Text('Virtual Account', style: AppTextStyles.labelLg),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Bank BCA',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Nomor Virtual Account', style: AppTextStyles.labelSm),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    vaNumber,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: vaNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nomor VA disalin')),
                    );
                  },
                  child: const Icon(Icons.copy_rounded,
                      color: AppColors.primary500, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── QRIS Card ─────────────────────────────────────────────────
class _QRISPaymentCard extends StatelessWidget {
  const _QRISPaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded,
                  color: AppColors.primary500, size: 22),
              const SizedBox(width: 8),
              Text('QRIS', style: AppTextStyles.labelLg),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderDefault),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: CustomPaint(painter: _QRDemoPainter()),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan QR di atas dengan aplikasi e-wallet atau mobile banking Anda',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QRDemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;

    // Draw simple demo QR pattern
    const s = 8.0;
    final cols = (size.width / s).floor();
    final rows = (size.height / s).floor();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if ((r + c) % 3 == 0 || (r * c) % 5 == 0) {
          canvas.drawRect(Rect.fromLTWH(c * s, r * s, s - 1, s - 1), paint);
        }
      }
    }
    // Corner markers
    final markerPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const markerSize = 40.0;
    for (final pos in [
      const Offset(4, 4),
      Offset(size.width - markerSize - 4, 4),
      Offset(4, size.height - markerSize - 4),
    ]) {
      canvas.drawRect(
          Rect.fromLTWH(pos.dx, pos.dy, markerSize, markerSize), markerPaint);
      canvas.drawRect(
        Rect.fromLTWH(pos.dx + 8, pos.dy + 8, markerSize - 16, markerSize - 16),
        Paint()..color = AppColors.textPrimary,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
