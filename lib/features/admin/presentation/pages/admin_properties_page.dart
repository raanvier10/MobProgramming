import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/mitra_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import 'admin_add_property_page.dart';

class AdminPropertiesPage extends StatefulWidget {
  const AdminPropertiesPage({super.key});
  @override
  State<AdminPropertiesPage> createState() => _AdminPropertiesPageState();
}

class _AdminPropertiesPageState extends State<AdminPropertiesPage> {
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
    final properties = appState.mitraProperties;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        title: const Text('Properti Saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'PlusJakartaSans')),
        backgroundColor: AppColors.primary800, 
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddPropertyPage())),
            tooltip: 'Tambah Properti'),
        ],
      ),
      body: _isLoading
          ? ListView(padding: const EdgeInsets.all(16),
              children: List.generate(3, (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12), child: SkeletonPropertyCard())))
          : properties.isEmpty
              ? EmptyState(icon: Icons.apartment_outlined,
                  title: 'Belum Ada Properti',
                  description: 'Jadilah yang pertama mendaftarkan properti di sini.',
                  actionLabel: 'Tambah Properti',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddPropertyPage())))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: properties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _PropertyCard(property: properties[i])),
      floatingActionButton: properties.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddPropertyPage())),
              backgroundColor: AppColors.primary500,
              child: const Icon(Icons.add_rounded, color: Colors.white))
          : null,
    );
  }
}

class _PropertyCard extends StatefulWidget {
  final Property property;
  const _PropertyCard({required this.property});
  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _isChangingStatus = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final p = widget.property;
    final isAvailable = p.status == RoomStatus.tersedia;
    final tenants = appState.tenantsForProperty(p.id);
    final hasActiveTrx = appState.hasActiveTransactions(p.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSurface, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withValues(alpha: 0.06), 
            blurRadius: 24, 
            offset: const Offset(0, 12),
          )
        ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary50, 
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(p.imageUrls.isNotEmpty ? p.imageUrls.first : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))
              ]
            )),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(p.name, style: AppTextStyles.labelLg.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                StatusBadge(type: isAvailable ? BadgeType.tersedia : BadgeType.penuh),
              ]
            ),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(child: Text(p.area, style: AppTextStyles.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Text('${CurrencyFormatter.formatCompact(p.pricePerMonth)} / bln',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.primary600)),
          ])),
        ])),

        // Info bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.bgMuted, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            _InfoChip(Icons.people_outline_rounded, '${tenants.length} penghuni'),
            const SizedBox(width: 12),
            if (p.isDpEnabled) const _InfoChip(Icons.payments_outlined, 'DP'),
            if (p.isCicilanEnabled) ...[const SizedBox(width: 8), const _InfoChip(Icons.calendar_today_outlined, 'Cicilan')],
          ])),

        const Divider(height: 20, indent: 14, endIndent: 14),

        // Actions
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: Row(children: [
          // Toggle status
          Expanded(child: _isChangingStatus
            ? const Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary500)))
            : GestureDetector(
                onTap: () {
                  if (hasActiveTrx && isAvailable == false) {
                    showDialog(context: context, builder: (_) => MitraConfirmDialog(
                      title: 'Ada Transaksi Aktif',
                      description: 'Properti ini masih memiliki transaksi aktif (pending/cicilan). Apakah Anda tetap ingin mengubah status?',
                      confirmLabel: 'Ya, Ubah', isDanger: true,
                      icon: Icons.warning_amber_rounded,
                      onConfirm: () => _changeStatus(appState, p, isAvailable)));
                  } else {
                    showDialog(context: context, builder: (_) => MitraConfirmDialog(
                      title: isAvailable ? 'Tandai Penuh?' : 'Tandai Tersedia?',
                      description: isAvailable
                          ? 'Status kamar akan berubah menjadi Penuh. Listing tidak akan muncul di pencari hunian.'
                          : 'Status kamar akan berubah menjadi Tersedia. Listing akan kembali muncul.',
                      confirmLabel: 'Ya, Ubah',
                      icon: isAvailable ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
                      isDanger: isAvailable,
                      onConfirm: () => _changeStatus(appState, p, isAvailable)));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isAvailable ? AppColors.danger50 : AppColors.success50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isAvailable ? AppColors.danger500.withValues(alpha: 0.3) : AppColors.success500.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(color: isAvailable ? AppColors.danger500.withValues(alpha: 0.1) : AppColors.success500.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 3))
                    ]
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(isAvailable ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
                      size: 16, color: isAvailable ? AppColors.danger700 : AppColors.success700),
                    const SizedBox(width: 6),
                    Text(isAvailable ? 'Tandai Penuh' : 'Tandai Tersedia',
                      style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600,
                        color: isAvailable ? AppColors.danger700 : AppColors.success700)),
                  ])),
              )),
          const SizedBox(width: 12),
          // Edit button
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAddPropertyPage(property: p))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary200),
                boxShadow: [
                  BoxShadow(color: AppColors.primary500.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 3))
                ]
              ),
              child: const Row(children: [
                Icon(Icons.edit_outlined, size: 16, color: AppColors.primary600),
                SizedBox(width: 6),
                Text('Edit', style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary600)),
              ]))),
          const SizedBox(width: 8),
          // Delete button
          GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (_) => MitraConfirmDialog(
                title: 'Hapus Properti?',
                description: 'Properti ini akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
                confirmLabel: 'Ya, Hapus',
                icon: Icons.delete_outline_rounded,
                isDanger: true,
                onConfirm: () {
                  appState.deleteProperty(p.id);
                  showMitraToast(context, 'Properti berhasil dihapus');
                }));
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger50, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger500.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger700),
            ),
          ),
        ])),
      ]),
    );
  }

  void _changeStatus(AppState appState, Property p, bool isAvailable) async {
    setState(() => _isChangingStatus = true);
    await Future.delayed(const Duration(milliseconds: 400));
    appState.setRoomStatus(p.id, isAvailable ? RoomStatus.penuh : RoomStatus.tersedia);
    if (mounted) {
      setState(() => _isChangingStatus = false);
      showMitraToast(context, isAvailable
          ? 'Status diubah menjadi Penuh'
          : 'Status diubah menjadi Tersedia');
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textTertiary),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
    ]);
  }
}
