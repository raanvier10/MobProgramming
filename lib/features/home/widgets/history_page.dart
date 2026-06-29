import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import '../../booking/presentation/pages/booking_page.dart';
import '../../payment/presentation/pages/payment_installment_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TransactionStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final allTransactions = context.watch<AppState>().myTransactions;
    final transactions = _filter == null ? allTransactions : allTransactions.where((t) => t.status == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── KUSTOM APPBAR MODERN DENGAN GRADASI ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 70.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary500,
            title: Text(
              'Riwayat Transaksi',
              style: AppTextStyles.displayMd.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary600,
                      AppColors.primary500,
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // ── KUSTOM FILTER CHIPS ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('Semua', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Menunggu', TransactionStatus.pending),
                    const SizedBox(width: 8),
                    _buildFilterChip('Lunas', TransactionStatus.lunas),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cicilan', TransactionStatus.cicilan),
                  ],
                ),
              ),
            ),
          ),

          // ── KONTEN HALAMAN ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: transactions.isEmpty
                ? const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Belum Ada Transaksi',
                      description: 'Mulai cari hunian dan ajukan sewa pertamamu.',
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final trx = transactions[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TransactionCard(transaction: trx),
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionStatus? status) {
    final isSelected = _filter == status;
    return GestureDetector(
      onTap: () => setState(() => _filter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary600 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.primary500.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(label, style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13,
          fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final AppTransaction transaction;
  final bool showUserName;
  const TransactionCard({super.key, required this.transaction, this.showUserName = false});

  Color get _borderColor {
    switch (transaction.status) {
      case TransactionStatus.lunas:
        return AppColors.success500;
      case TransactionStatus.pending:
        return AppColors.warning500;
      case TransactionStatus.cicilan:
        return AppColors.info500;
    }
  }

  String get _statusLabel {
    switch (transaction.status) {
      case TransactionStatus.lunas:
        return 'Lunas';
      case TransactionStatus.pending:
        return 'Menunggu Pembayaran';
      case TransactionStatus.cicilan:
        return 'Cicilan ${transaction.paidTermin}/${transaction.totalTermin}';
    }
  }

  Color get _statusColor {
    switch (transaction.status) {
      case TransactionStatus.lunas:
        return AppColors.success700;
      case TransactionStatus.pending:
        return AppColors.warning700;
      case TransactionStatus.cicilan:
        return AppColors.info700;
    }
  }

  String get _schemeLabel {
    switch (transaction.scheme) {
      case PaymentScheme.penuh:
        return 'Bayar Penuh';
      case PaymentScheme.dp:
        return 'DP';
      case PaymentScheme.cicilan:
        return 'Cicilan';
    }
  }

  String get _paymentLabel {
    switch (transaction.scheme) {
      case PaymentScheme.penuh: return 'Total Pembayaran';
      case PaymentScheme.dp: return 'Pembayaran DP';
      case PaymentScheme.cicilan: return 'Cicilan per Termin';
    }
  }

  double get _amountPaid {
    switch (transaction.scheme) {
      case PaymentScheme.penuh: return transaction.totalAmount;
      case PaymentScheme.dp: return transaction.amountPerTermin ?? 0;
      case PaymentScheme.cicilan: return transaction.amountPerTermin ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral500.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BAGIAN ATAS (JUDUL & BADGE STATUS) ──────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _borderColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    transaction.propertyName,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _borderColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel,
                    style: AppTextStyles.labelSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider pemisah tengah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.borderDefault.withOpacity(0.6)),
          ),

          // ── BAGIAN TENGAH (DETAIL INFO) ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showUserName) ...[
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        transaction.userName, 
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Masuk: ${DateFormatter.formatShort(transaction.checkInDate)}',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      '${transaction.durationMonths} bulan', 
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── BAGIAN BAWAH (HARGA & FOOTER VA) ────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary50.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _paymentLabel, 
                            style: AppTextStyles.labelSm.copyWith(color: AppColors.textTertiary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(_amountPaid),
                            style: AppTextStyles.priceLg.copyWith(
                              fontSize: 18, 
                              color: AppColors.primary600,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Skema', 
                          style: AppTextStyles.labelSm.copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary100.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _schemeLabel,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.receipt_outlined, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'VA: ',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textTertiary),
                    ),
                    Text(
                      transaction.vaNumber,
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                // Progress Cicilan
                if (transaction.status == TransactionStatus.cicilan && transaction.totalTermin != null) ...[
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Progress Cicilan', style: AppTextStyles.labelSm.copyWith(fontSize: 11)),
                    Text('${transaction.paidTermin}/${transaction.totalTermin} termin',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.info700, fontSize: 11)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (transaction.paidTermin ?? 0) / (transaction.totalTermin ?? 1),
                      backgroundColor: AppColors.neutral200, color: AppColors.info500,
                      minHeight: 8)),
                ],

                // Aksi tombol
                if (transaction.status == TransactionStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan Dibatalkan')));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger700, side: BorderSide(color: AppColors.danger500.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Batalkan', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menuju halaman upload bukti...')));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary500, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text('Bayar Sekarang', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else if (transaction.status == TransactionStatus.cicilan) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentInstallmentPage(transaction: transaction),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment_rounded, size: 16),
                      label: const Text('Bayar Tagihan Selanjutnya', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info500, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ] else if (transaction.status == TransactionStatus.lunas) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunduh kwitansi...')));
                          },
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Kwitansi', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary600, side: const BorderSide(color: AppColors.primary200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final appState = context.read<AppState>();
                            final property = appState.allProperties.firstWhere(
                              (p) => p.id == transaction.propertyId,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingPage(property: property),
                              ),
                            );
                          },
                          icon: const Icon(Icons.autorenew_rounded, size: 16),
                          label: const Text('Perpanjang', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success500, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}