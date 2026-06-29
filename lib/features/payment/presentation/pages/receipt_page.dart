import 'package:flutter/material.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import '../../../home/presentation/pages/main_shell.dart';

class ReceiptPage extends StatelessWidget {
  final AppTransaction transaction;
  const ReceiptPage({super.key, required this.transaction});

  String get _paymentLabel {
    switch (transaction.scheme) {
      case PaymentScheme.penuh: return 'Total Pembayaran';
      case PaymentScheme.dp: return 'Pembayaran DP';
      case PaymentScheme.cicilan: return 'Cicilan Termin 1';
    }
  }

  double get _amountPaid {
    switch (transaction.scheme) {
      case PaymentScheme.penuh: return transaction.totalAmount;
      case PaymentScheme.dp: return transaction.amountPerTermin ?? 0;
      case PaymentScheme.cicilan: return transaction.amountPerTermin ?? 0;
    }
  }

  String get _statusLabel {
    switch (transaction.scheme) {
      case PaymentScheme.penuh: return 'Lunas';
      case PaymentScheme.dp: return 'DP Dibayar';
      case PaymentScheme.cicilan: return 'Termin Dibayar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ── Success Header ────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary700, AppColors.primary500],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 64),
                          const SizedBox(height: 12),
                          Text(
                            'Pembayaran Berhasil!',
                            style: AppTextStyles.displayMd.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kamu kini terdaftar sebagai penghuni aktif.',
                            style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Receipt ───────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.borderDefault, style: BorderStyle.solid)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.apartment_rounded, color: AppColors.primary500, size: 24),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ngekos.in', style: AppTextStyles.displaySm.copyWith(fontSize: 18, color: AppColors.primary500)),
                                    Text('KUITANSI RESMI', style: AppTextStyles.labelSm.copyWith(color: AppColors.textTertiary)),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  '#${transaction.id.length > 8 ? transaction.id.substring(transaction.id.length - 6).toUpperCase() : transaction.id.toUpperCase()}',
                                  style: AppTextStyles.labelMd.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),

                          // Dashed divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: List.generate(
                                40,
                                (i) => Expanded(
                                  child: Container(
                                    height: 1,
                                    color: i.isEven ? AppColors.borderDefault : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                InfoRow(icon: Icons.apartment_outlined, label: 'Properti', value: transaction.propertyName),
                                InfoRow(icon: Icons.person_outline_rounded, label: 'Nama', value: transaction.userName),
                                InfoRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Check-in',
                                  value: DateFormatter.formatShort(transaction.checkInDate),
                                ),
                                InfoRow(
                                  icon: Icons.access_time_rounded,
                                  label: 'Durasi',
                                  value: '${transaction.durationMonths} bulan',
                                ),
                                InfoRow(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'Check-out',
                                  value: DateFormatter.formatShort(
                                    DateTime(
                                      transaction.checkInDate.year,
                                      transaction.checkInDate.month + transaction.durationMonths,
                                      transaction.checkInDate.day,
                                    ),
                                  ),
                                ),
                                InfoRow(
                                  icon: Icons.payments_outlined,
                                  label: 'Skema',
                                  value: transaction.scheme == PaymentScheme.penuh
                                      ? 'Bayar Penuh'
                                      : transaction.scheme == PaymentScheme.dp
                                          ? 'Down Payment'
                                          : 'Cicilan',
                                ),
                                InfoRow(
                                  icon: transaction.method == PaymentMethod.va
                                      ? Icons.account_balance_outlined
                                      : Icons.qr_code_2_rounded,
                                  label: 'Metode',
                                  value: transaction.method == PaymentMethod.va ? 'Virtual Account' : 'QRIS',
                                ),
                              ],
                            ),
                          ),

                          // Dashed divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: List.generate(
                                40,
                                (i) => Expanded(
                                  child: Container(
                                    height: 1,
                                    color: i.isEven ? AppColors.borderDefault : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Total
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_paymentLabel, style: AppTextStyles.labelSm),
                                      Text(
                                        CurrencyFormatter.format(_amountPaid),
                                        style: AppTextStyles.priceLg.copyWith(fontSize: 22),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.success50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppColors.success500, size: 16),
                                      const SizedBox(width: 4),
                                      Text(_statusLabel, style: const TextStyle(color: AppColors.success700, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.bgMuted,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                            ),
                            child: Center(
                              child: Text(
                                'Diterbitkan oleh Ngekos.in • ${DateFormatter.formatShort(transaction.createdAt)}',
                                style: AppTextStyles.labelSm.copyWith(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Unduh',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kuitansi sedang diunduh...')),
                              );
                            },
                            variant: AppButtonVariant.outline,
                            leadingIcon: Icons.download_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            label: 'Bagikan',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kuitansi siap dibagikan')),
                              );
                            },
                            variant: AppButtonVariant.outline,
                            leadingIcon: Icons.share_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: AppButton(
                label: 'Kembali ke Beranda',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                  (_) => false,
                ),
                variant: AppButtonVariant.brand,
                size: AppButtonSize.lg,
                leadingIcon: Icons.home_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
