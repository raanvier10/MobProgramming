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

class PaymentInstallmentPage extends StatefulWidget {
  final AppTransaction transaction;

  const PaymentInstallmentPage({super.key, required this.transaction});

  @override
  State<PaymentInstallmentPage> createState() => _PaymentInstallmentPageState();
}

class _PaymentInstallmentPageState extends State<PaymentInstallmentPage> {
  bool _isConfirming = false;
  PaymentMethod _selectedMethod = PaymentMethod.va;

  // Countdown 30 minutes
  late Timer _timer;
  int _remainingSeconds = 30 * 60;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.transaction.method;
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

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _confirmPayment() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.read<AppState>().payInstallment(widget.transaction.id);
    _timer.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReceiptPage(transaction: widget.transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final terminTarget = (widget.transaction.paidTermin ?? 0) + 1;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: Text(widget.transaction.scheme == PaymentScheme.dp ? 'Pelunasan Sisa Pembayaran' : 'Pembayaran Tagihan'),
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

            // ── Payment Detail ──────────────────────────────
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
                  Text('Rincian Tagihan', style: AppTextStyles.labelLg),
                  const Divider(height: 16),
                  InfoRow(
                      icon: Icons.apartment_rounded,
                      label: 'Properti',
                      value: widget.transaction.propertyName),
                  InfoRow(
                    icon: Icons.numbers_rounded,
                    label: 'Tagihan Ke',
                    value: '$terminTarget dari ${widget.transaction.totalTermin}',
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
                        CurrencyFormatter.format(
                          (widget.transaction.scheme == PaymentScheme.dp && terminTarget == 2)
                              ? widget.transaction.totalAmount - (widget.transaction.amountPerTermin ?? 0)
                              : (widget.transaction.amountPerTermin ?? 0)
                        ),
                        style: AppTextStyles.priceLg,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Payment Method Selection ─────────────────────────
            Text('Metode Pembayaran', style: AppTextStyles.displaySm.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MethodCard(
                    method: PaymentMethod.va,
                    selected: _selectedMethod,
                    icon: Icons.account_balance_outlined,
                    label: 'Virtual Account',
                    onTap: () => setState(() => _selectedMethod = PaymentMethod.va),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MethodCard(
                    method: PaymentMethod.qris,
                    selected: _selectedMethod,
                    icon: Icons.qr_code_2_rounded,
                    label: 'QRIS',
                    onTap: () => setState(() => _selectedMethod = PaymentMethod.qris),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _selectedMethod == PaymentMethod.va
                ? _VAPaymentCard(vaNumber: widget.transaction.vaNumber)
                : const _QRISPaymentCard(),

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
    if (_selectedMethod == PaymentMethod.va) {
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

class _MethodCard extends StatelessWidget {
  final PaymentMethod method, selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MethodCard({
    required this.method,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? AppColors.primary500 : AppColors.textTertiary),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: isSelected ? AppColors.primary500 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/qris_demo.png',
                  fit: BoxFit.cover,
                ),
              ),
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


