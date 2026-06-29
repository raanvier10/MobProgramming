import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/mitra_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import '../../../auth/presentation/pages/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Keluar Akun',
            style:
                AppTextStyles.displaySm.copyWith(color: AppColors.danger500)),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun Ngekos.in ini?',
          style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: Colors.grey.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Batal',
                      style: AppTextStyles.buttonMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger500,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.read<AppState>().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    );
                  },
                  child: Text('Keluar',
                      style: AppTextStyles.buttonMedium
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final properties = appState.mitraProperties;
    final transactions = appState.mitraTransactions;
    final tenants = appState.mitraTenants;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero App Bar ──────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary800,
            expandedHeight: 160,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Keluar',
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final top = constraints.biggest.height;
                final collapsedHeight =
                    MediaQuery.of(context).padding.top + kToolbarHeight;
                double titleOpacity = 0.0;
                if (top < collapsedHeight + 40) {
                  titleOpacity = 1.0 - ((top - collapsedHeight) / 40);
                  if (titleOpacity < 0) titleOpacity = 0.0;
                  if (titleOpacity > 1) titleOpacity = 1.0;
                }

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary800,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned.fill(
                              child: ShaderMask(
                                shaderCallback: (rect) {
                                  return const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black87,
                                      Colors.transparent
                                    ],
                                  ).createShader(rect);
                                },
                                blendMode: BlendMode.dstIn,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?q=80&w=800&auto=format&fit=crop',
                                  fit: BoxFit.cover,
                                  color: AppColors.primary800.withOpacity(0.5),
                                  colorBlendMode: BlendMode.srcOver,
                                ),
                              ),
                            ),
                            SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Dasbor Mitra',
                                                style: AppTextStyles.bodySm
                                                    .copyWith(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Halo, ${appState.currentUser?.name ?? 'Mitra'} 👋',
                                                style: AppTextStyles.displaySm
                                                    .copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                          ),
                                        ),
                                        const SizedBox(width: 42),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Quick stat chips
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _QuickChip(
                                            icon: Icons.meeting_room_rounded,
                                            label: '${properties.length} Kamar',
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          _QuickChip(
                                            icon: Icons.people_rounded,
                                            label: '${tenants.length} Penghuni',
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          _QuickChip(
                                            icon: Icons.check_circle_rounded,
                                            label:
                                                '${appState.mitraAvailableRooms} Tersedia',
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Kelola kamar dan penghuni dengan mudah hari ini.',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (titleOpacity > 0.0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Opacity(
                          opacity: titleOpacity,
                          child: const Center(
                            child: Text(
                              'Dasbor Mitra',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // ── Content ───────────────────────────────────────
          if (_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonPropertyCard(),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Revenue Stats ─────────────────────────
                    _RevenueCard(
                      totalRevenue: appState.mitraTotalRevenue,
                      pendingRevenue: appState.mitraPendingRevenue,
                      cicilanPiutang: appState.mitraCicilanPiutang,
                    ),
                    const SizedBox(height: 20),

                    // ── Property Status Overview ──────────────
                    _PropertyStatusGrid(
                      available: appState.mitraAvailableRooms,
                      full: appState.mitraFullRooms,
                      total: properties.length,
                    ),
                    const SizedBox(height: 24),

                    // ── Gabungan: Properti + Penghuni + Tagihan ──
                    SectionHeader(
                      title: 'Daftar Kamar / Unit',
                      actionLabel: tenants.isNotEmpty ? 'Lihat Semua' : null,
                    ),
                    const SizedBox(height: 12),
                    if (properties.isEmpty)
                      const EmptyState(
                        icon: Icons.meeting_room_outlined,
                        title: 'Belum Ada Kamar',
                        description:
                            'Tambahkan data kamar atau unit Anda di sini.',
                      )
                    else
                      ...properties.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PropertySummaryCard(
                            property: p,
                            tenants: appState.tenantsForProperty(p.id),
                            transactions:
                                appState.transactionsForProperty(p.id),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ── Recent Transactions ───────────────────
                    SectionHeader(title: 'Transaksi Terbaru'),
                    const SizedBox(height: 12),
                    if (transactions.isEmpty)
                      const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum Ada Transaksi',
                        description:
                            'Transaksi dari properti Anda akan muncul di sini.',
                      )
                    else
                      ...transactions.take(5).map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _MitraTransactionMini(transaction: t),
                            ),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Quick Chip (Header) ─────────────────────────────────────
class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.3), width: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Revenue Card ────────────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  final double totalRevenue;
  final double pendingRevenue;
  final double cicilanPiutang;

  const _RevenueCard({
    required this.totalRevenue,
    required this.pendingRevenue,
    required this.cicilanPiutang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary600, AppColors.primary800],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary600.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pendapatan',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(totalRevenue),
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total pembayaran lunas',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RevenueMini(
                  label: 'Menunggu',
                  value: CurrencyFormatter.formatCompact(pendingRevenue),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.15),
              ),
              Expanded(
                child: _RevenueMini(
                  label: 'Piutang Cicilan',
                  value: CurrencyFormatter.formatCompact(cicilanPiutang),
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueMini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _RevenueMini(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

// ── Property Status Grid ─────────────────────────────────────
class _PropertyStatusGrid extends StatelessWidget {
  final int available, full, total;
  const _PropertyStatusGrid({
    required this.available,
    required this.full,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusTile(
          icon: Icons.meeting_room_rounded,
          label: 'Total Kamar / Unit Terdaftar',
          count: total,
          color: AppColors.primary600,
          bgColor: AppColors.primary50,
          isWide: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatusTile(
              icon: Icons.check_circle_outline_rounded,
              label: 'Kamar Tersedia',
              count: available,
              color: AppColors.success500,
              bgColor: AppColors.success50,
            ),
            const SizedBox(width: 12),
            _StatusTile(
              icon: Icons.cancel_outlined,
              label: 'Kamar Penuh',
              count: full,
              color: AppColors.danger500,
              bgColor: AppColors.danger50,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color, bgColor;
  final bool isWide;

  const _StatusTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return isWide ? _buildWide() : Expanded(child: _buildSquare());
  }

  Widget _buildWide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMd
                      .copyWith(color: color.withOpacity(0.8)),
                ),
                Text(
                  '$count',
                  style: AppTextStyles.displayMd
                      .copyWith(color: color, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquare() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: AppTextStyles.displaySm.copyWith(color: color),
          ),
          Text(
            label,
            style:
                AppTextStyles.labelSm.copyWith(color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

// ── Property Summary Card (Gabungan info) ─────────────────────
class _PropertySummaryCard extends StatelessWidget {
  final Property property;
  final List<Tenant> tenants;
  final List<AppTransaction> transactions;

  const _PropertySummaryCard({
    required this.property,
    required this.tenants,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = property.status == RoomStatus.tersedia;
    final pendingTrx =
        transactions.where((t) => t.status == TransactionStatus.pending).length;
    final cicilanTrx =
        transactions.where((t) => t.status == TransactionStatus.cicilan).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.06), // tinted shadow
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    property.type == PropertyType.kos
                        ? Icons.apartment_rounded
                        : Icons.home_rounded,
                    color: AppColors.primary500,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.name,
                        style: AppTextStyles.labelLg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 2),
                          Text(
                            property.area,
                            style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  type: isAvailable ? BadgeType.tersedia : BadgeType.penuh,
                ),
              ],
            ),
          ),

          // Stats row — gabungkan info kamar, penghuni, tagihan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _MiniStat(
                  icon: Icons.people_outline_rounded,
                  label: 'Penghuni',
                  value: '${tenants.length}',
                ),
                _divider(),
                _MiniStat(
                  icon: Icons.payments_outlined,
                  label: 'Harga',
                  value:
                      CurrencyFormatter.formatCompact(property.pricePerMonth),
                ),
                _divider(),
                _MiniStat(
                  icon: Icons.pending_outlined,
                  label: 'Pending',
                  value: '$pendingTrx',
                  valueColor: pendingTrx > 0 ? AppColors.warning500 : null,
                ),
                if (cicilanTrx > 0) ...[
                  _divider(),
                  _MiniStat(
                    icon: Icons.calendar_today_outlined,
                    label: 'Cicilan',
                    value: '$cicilanTrx',
                    valueColor: AppColors.info500,
                  ),
                ],
              ],
            ),
          ),

          // Tenant list mini
          if (tenants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Column(
                children: tenants.take(2).map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary100,
                          child: Text(
                            t.userName[0].toUpperCase(),
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primary500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${t.userName} — ${t.roomNumber}',
                            style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: t.remainingDays < 14
                                ? AppColors.danger50
                                : AppColors.success50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${t.remainingDays}hr',
                            style: AppTextStyles.labelSm.copyWith(
                              color: t.remainingDays < 14
                                  ? AppColors.danger700
                                  : AppColors.success700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.borderDefault,
      );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelMd.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(fontSize: 10),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// ── Mini Transaction Card ────────────────────────────────────
class _MitraTransactionMini extends StatelessWidget {
  final AppTransaction transaction;
  const _MitraTransactionMini({required this.transaction});

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
        return 'Pending';
      case TransactionStatus.cicilan:
        return 'Cicilan ${transaction.paidTermin}/${transaction.totalTermin}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: const [
          BoxShadow(color: Color(0x061C1917), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: _borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.propertyName,
                  style: AppTextStyles.labelMd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      transaction.userName,
                      style: AppTextStyles.bodySm.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatShort(transaction.createdAt),
                      style: AppTextStyles.bodySm.copyWith(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(transaction.totalAmount),
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary500,
                  fontSize: 13,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _borderColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
