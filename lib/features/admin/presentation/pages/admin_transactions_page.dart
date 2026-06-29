import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/mitra_widgets.dart';
import '../../../../core/widgets/formatters.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});
  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  TransactionStatus? _filter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allTrx = appState.mitraTransactions;
    final filtered = _filter == null ? allTrx : allTrx.where((t) => t.status == _filter).toList();

    final totalLunas = allTrx.where((t) => t.status == TransactionStatus.lunas).fold(0.0, (s, t) => s + t.totalAmount);
    final totalPending = allTrx.where((t) => t.status == TransactionStatus.pending).length;
    final totalCicilan = allTrx.where((t) => t.status == TransactionStatus.cicilan).length;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true, automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary800, expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.primary900, AppColors.primary700])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Pemantauan Transaksi',
                      style: AppTextStyles.displaySm.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _HeaderStat('Lunas', CurrencyFormatter.formatCompact(totalLunas), AppColors.success500),
                      const SizedBox(width: 8),
                      _HeaderStat('Pending', '$totalPending', AppColors.accent400),
                      const SizedBox(width: 8),
                      _HeaderStat('Cicilan', '$totalCicilan', AppColors.info500),
                    ]),
                  ]))),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _FilterChip('Semua', _filter == null, () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  _FilterChip('Lunas', _filter == TransactionStatus.lunas,
                    () => setState(() => _filter = TransactionStatus.lunas)),
                  const SizedBox(width: 8),
                  _FilterChip('Pending', _filter == TransactionStatus.pending,
                    () => setState(() => _filter = TransactionStatus.pending)),
                  const SizedBox(width: 8),
                  _FilterChip('Cicilan', _filter == TransactionStatus.cicilan,
                    () => setState(() => _filter = TransactionStatus.cicilan)),
                ]),
              ),
            ),
          ),

          // List
          if (_isLoading)
            SliverPadding(padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonPropertyCard()),
                childCount: 3)))
          else if (filtered.isEmpty)
            const SliverFillRemaining(child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Tidak Ada Transaksi',
              description: 'Belum ada transaksi dengan status yang dipilih.'))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionCard(transaction: filtered[i])),
                childCount: filtered.length))),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _HeaderStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)])),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14,
          fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11, color: Colors.white70)),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip(this.label, this.isSelected, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary600 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected 
            ? [BoxShadow(color: AppColors.primary500.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Text(label, style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12,
        fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary)),
    ));
  }
}

class _TransactionCard extends StatelessWidget {
  final AppTransaction transaction;
  const _TransactionCard({required this.transaction});

  Color get _color {
    switch (transaction.status) {
      case TransactionStatus.lunas: return AppColors.success500;
      case TransactionStatus.pending: return AppColors.warning500;
      case TransactionStatus.cicilan: return AppColors.info500;
    }
  }

  String get _statusLabel {
    switch (transaction.status) {
      case TransactionStatus.lunas: return 'Lunas';
      case TransactionStatus.pending: return 'Menunggu Pembayaran';
      case TransactionStatus.cicilan: return 'Cicilan ${transaction.paidTermin}/${transaction.totalTermin}';
    }
  }

  String get _schemeLabel {
    switch (transaction.scheme) {
      case PaymentScheme.penuh: return 'Bayar Penuh';
      case PaymentScheme.dp: return 'DP';
      case PaymentScheme.cicilan: return 'Cicilan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _color.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(transaction.propertyName, style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(transaction.userName, style: AppTextStyles.bodySm.copyWith(fontSize: 12)),
              ]),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(_statusLabel, style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11,
                fontWeight: FontWeight.w600, color: _color))),
          ])),

        const Divider(height: 1, indent: 14, endIndent: 14),

        // Details
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total', style: AppTextStyles.labelSm.copyWith(fontSize: 10)),
            Text(CurrencyFormatter.format(transaction.totalAmount),
              style: AppTextStyles.price.copyWith(fontSize: 16)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(DateFormatter.formatShort(transaction.checkInDate),
                style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
            ]),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary50, borderRadius: BorderRadius.circular(6)),
              child: Text(_schemeLabel, style: AppTextStyles.labelSm.copyWith(
                color: AppColors.primary700, fontSize: 10))),
          ]),
        ])),

        // Cicilan progress
        if (transaction.status == TransactionStatus.cicilan && transaction.totalTermin != null)
          Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Progress Cicilan', style: AppTextStyles.labelSm.copyWith(fontSize: 10)),
                Text('${transaction.paidTermin}/${transaction.totalTermin} termin',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.info700, fontSize: 10)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (transaction.paidTermin ?? 0) / (transaction.totalTermin ?? 1),
                  backgroundColor: AppColors.neutral100, color: AppColors.info500,
                  minHeight: 6)),
            ])),

        // VA number
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgMuted,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
          child: Row(children: [
            const Icon(Icons.receipt_outlined, size: 13, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text('VA: ${transaction.vaNumber}',
              style: AppTextStyles.bodySm.copyWith(fontSize: 11, color: AppColors.textTertiary)),
            const Spacer(),
            Text(DateFormatter.formatShort(transaction.createdAt),
              style: AppTextStyles.bodySm.copyWith(fontSize: 10, color: AppColors.textTertiary)),
          ])),
      ]),
    );
  }
}
