import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/mitra_widgets.dart';
import '../../../../core/widgets/formatters.dart';

class AdminTenantsPage extends StatefulWidget {
  const AdminTenantsPage({super.key});
  @override
  State<AdminTenantsPage> createState() => _AdminTenantsPageState();
}

class _AdminTenantsPageState extends State<AdminTenantsPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final active = appState.mitraTenants;
    final archived = appState.mitraArchivedTenants;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        title: const Text('Penghuni', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'PlusJakartaSans')), 
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary800, elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(49),
          child: Column(children: [
            Container(height: 1, color: AppColors.primary800),
            TabBar(controller: _tabCtrl,
              labelColor: Colors.white, unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white, indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: 'Aktif (${active.length})'),
                Tab(text: 'Arsip (${archived.length})'),
              ]),
          ])),
      ),
      body: _isLoading
          ? ListView(padding: const EdgeInsets.all(16),
              children: List.generate(3, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12), child: SkeletonPropertyCard())))
          : TabBarView(controller: _tabCtrl, children: [
              _buildList(active, isActive: true),
              _buildList(archived, isActive: false),
            ]),
    );
  }

  Widget _buildList(List<Tenant> tenants, {required bool isActive}) {
    if (tenants.isEmpty) {
      return EmptyState(
        icon: isActive ? Icons.people_outline_rounded : Icons.archive_outlined,
        title: isActive ? 'Belum Ada Penghuni' : 'Belum Ada Arsip',
        description: isActive
            ? 'Daftar penghuni aktif akan muncul setelah ada transaksi.'
            : 'Penghuni yang sudah selesai sewa akan tampil di sini.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: tenants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TenantCard(tenant: tenants[i], isActive: isActive));
  }
}

class _TenantCard extends StatefulWidget {
  final Tenant tenant;
  final bool isActive;
  const _TenantCard({required this.tenant, required this.isActive});
  @override
  State<_TenantCard> createState() => _TenantCardState();
}

class _TenantCardState extends State<_TenantCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tenant;
    final isExpiring = t.isActive && t.remainingDays < 14;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: const [BoxShadow(color: Color(0x081C1917), blurRadius: 8, offset: Offset(0, 2))]),
      child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: AppColors.primary100,
            child: Text(t.userName[0].toUpperCase(),
              style: AppTextStyles.displaySm.copyWith(color: AppColors.primary500, fontSize: 18))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.userName, style: AppTextStyles.labelLg),
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.phone_outlined, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(t.userPhone, style: AppTextStyles.bodySm.copyWith(fontSize: 12)),
            ]),
          ])),
          if (widget.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isExpiring ? AppColors.danger50 : AppColors.success50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isExpiring ? AppColors.danger500.withOpacity(0.3) : AppColors.success500.withOpacity(0.3))),
              child: Column(children: [
                Text('${t.remainingDays}', style: AppTextStyles.displaySm.copyWith(
                  fontSize: 16, color: isExpiring ? AppColors.danger700 : AppColors.success700)),
                Text('hari', style: AppTextStyles.labelSm.copyWith(fontSize: 9,
                  color: isExpiring ? AppColors.danger700 : AppColors.success700)),
              ]))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.neutral100, borderRadius: BorderRadius.circular(8)),
              child: Text('Arsip', style: AppTextStyles.labelSm.copyWith(color: AppColors.textTertiary))),
        ])),

        const Divider(height: 1, indent: 16, endIndent: 16),

        // Detail row
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          _DetailCol('Properti', t.propertyName, flex: 2),
          _DetailCol('Kamar', t.roomNumber),
          _DetailCol('Durasi', '${t.durationMonths} bln'),
          _DetailCol('Masuk', DateFormatter.formatShort(t.checkInDate)),
        ])),

        // Action button
        if (widget.isActive)
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(width: double.infinity, child: _isProcessing
              ? const Center(child: SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger500)))
              : AppButton(
                  label: 'Selesai Sewa / Pindah',
                  onPressed: () => _confirmSelesai(context, t),
                  variant: AppButtonVariant.danger, size: AppButtonSize.sm,
                  leadingIcon: Icons.exit_to_app_rounded))),

        if (!widget.isActive && t.archivedDate != null)
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              const Icon(Icons.archive_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text('Diarsipkan: ${DateFormatter.formatShort(t.archivedDate!)}',
                style: AppTextStyles.bodySm.copyWith(fontSize: 11, color: AppColors.textTertiary)),
            ])),
      ]),
    );
  }

  void _confirmSelesai(BuildContext context, Tenant t) {
    showDialog(context: context, builder: (_) => MitraConfirmDialog(
      title: 'Selesai Sewa',
      description: 'Apakah ${t.userName} sudah selesai menyewa dan pindah?\n\nKamar ${t.roomNumber} akan otomatis kembali berstatus "Tersedia".',
      confirmLabel: 'Ya, Selesai',
      isDanger: true,
      icon: Icons.exit_to_app_rounded,
      onConfirm: () async {
        setState(() => _isProcessing = true);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        context.read<AppState>().selesaiSewa(t.id);
        setState(() => _isProcessing = false);
        showMitraToast(context, 'Sewa ${t.userName} selesai. Kamar kembali tersedia.');
      },
    ));
  }
}

class _DetailCol extends StatelessWidget {
  final String label, value;
  final int flex;
  const _DetailCol(this.label, this.value, {this.flex = 1});
  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.labelSm.copyWith(fontSize: 10)),
      const SizedBox(height: 2),
      Text(value, style: AppTextStyles.labelMd.copyWith(fontSize: 12),
        maxLines: 1, overflow: TextOverflow.ellipsis),
    ]));
  }
}
