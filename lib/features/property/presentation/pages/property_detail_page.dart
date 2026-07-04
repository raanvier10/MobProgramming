import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import '../../../booking/presentation/pages/booking_page.dart';

String normalizePhoneNumber(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) return raw;
  if (digits.startsWith('0')) return '+62${digits.substring(1)}';
  if (digits.startsWith('62')) return '+$digits';
  return digits;
}

class PropertyDetailPage extends StatefulWidget {
  final Property property;
  const PropertyDetailPage({super.key, required this.property});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;
    final isAvailable = prop.status == RoomStatus.tersedia;

    final myTransactions = context.watch<AppState>().myTransactions;
    final hasPending =
        myTransactions.any((t) => t.status == TransactionStatus.pending);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          // ── Photo Carousel ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary700,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount:
                        prop.imageUrls.isEmpty ? 1 : prop.imageUrls.length,
                    onPageChanged: (i) => setState(() => _currentImage = i),
                    itemBuilder: (_, i) => prop.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: prop.imageUrls[i],
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: AppColors.neutral200),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.neutral200,
                              child: const Icon(Icons.broken_image_rounded,
                                  size: 64, color: AppColors.neutral300),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral200,
                            child: const Icon(Icons.apartment_rounded,
                                size: 64, color: AppColors.neutral300),
                          ),
                  ),
                  // Dot indicators
                  if (prop.imageUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          prop.imageUrls.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImage == i ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImage == i
                                  ? Colors.white
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(prop.name, style: AppTextStyles.displayMd),
                      ),
                      StatusBadge(
                        type:
                            isAvailable ? BadgeType.tersedia : BadgeType.penuh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          prop.fullAddress,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.map_outlined,
                            size: 14, color: AppColors.primary500),
                        const SizedBox(width: 4),
                        Text(
                          'Lihat di Peta',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.primary500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary200),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Sewa', style: AppTextStyles.labelSm),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(prop.pricePerMonth),
                                  style: AppTextStyles.priceLg,
                                ),
                                const Text(
                                  ' / bulan',
                                  style: AppTextStyles.bodySm,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            prop.type == PropertyType.kos ? 'Kos' : 'Kontrakan',
                            style: AppTextStyles.labelMd
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Info Umum ────────────────────────────────────
                  Text('Informasi Umum',
                      style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  InfoRow(
                    icon: Icons.wc_rounded,
                    label: 'Tipe Kamar',
                    value: prop.roomGender == RoomGender.male
                        ? 'Khusus Putra'
                        : prop.roomGender == RoomGender.female
                            ? 'Khusus Putri'
                            : 'Campur (Putra & Putri)',
                  ),
                  const Divider(height: 1),
                  InfoRow(
                    icon: Icons.location_city_rounded,
                    label: 'Wilayah',
                    value: prop.area,
                  ),
                  const SizedBox(height: 20),

                  // ── Kontak Pemilik ───────────────────────────────
                  if (prop.ownerPhone.isNotEmpty) ...[
                    Text('Pemilik',
                        style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.call_rounded,
                              color: AppColors.primary500),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${prop.ownerName} • ${prop.ownerPhone}',
                              style: AppTextStyles.labelMd
                                  .copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            label: 'Hubungi',
                            onPressed: () async {
                              final phone =
                                  normalizePhoneNumber(prop.ownerPhone);
                              final uri = Uri(scheme: 'tel', path: phone);
                              try {
                                final launched = await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                                if (!launched && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Tidak bisa membuka aplikasi panggilan.')),
                                  );
                                }
                              } catch (_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Gagal membuka nomor telepon.')),
                                  );
                                }
                              }
                            },
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.sm,
                            leadingIcon: Icons.call_end_rounded,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Deskripsi ────────────────────────────────────
                  Text('Deskripsi',
                      style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(prop.description,
                      style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary, height: 1.7)),
                  const SizedBox(height: 20),

                  // ── Fasilitas ────────────────────────────────────
                  Text('Fasilitas',
                      style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: prop.facilities
                        .map((f) => _FacilityChip(label: f))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // ── Skema Pembayaran ─────────────────────────────
                  Text('Skema Pembayaran',
                      style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  const _PaymentSchemeCard(
                    icon: Icons.payments_rounded,
                    title: 'Bayar Penuh',
                    description: 'Bayar total harga sewa sekaligus',
                    badgeType: BadgeType.bayarPenuh,
                  ),
                  if (prop.isDpEnabled) ...[
                    const SizedBox(height: 8),
                    _PaymentSchemeCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Down Payment (DP)',
                      description:
                          'Cicil mulai dari ${CurrencyFormatter.format(prop.dpAmount)}',
                      badgeType: BadgeType.dp,
                    ),
                  ],
                  if (prop.isCicilanEnabled) ...[
                    const SizedBox(height: 8),
                    _PaymentSchemeCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'Cicilan',
                      description:
                          'Maksimal ${prop.maxTermin} termin pembayaran',
                      badgeType: BadgeType.cicilan,
                    ),
                  ],
                  const SizedBox(height: 12),

                  const SizedBox(
                      height:
                          24), // Memberikan jarak nafas sedikit di akhir konten
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ─────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.bgSurface,
            border: Border(top: BorderSide(color: AppColors.borderDefault)),
          ),
          child: isAvailable
              ? AppButton(
                  label: 'Ajukan Sewa',
                  onPressed: () {
                    if (hasPending) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: AppColors.warning500),
                              SizedBox(width: 8),
                              Text('Transaksi Tertunda',
                                  style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: const Text(
                            'Anda masih memiliki transaksi yang belum dibayar. Silakan selesaikan pembayaran atau batalkan pesanan tersebut di menu Transaksi sebelum mengajukan sewa baru.',
                            style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK, Mengerti',
                                  style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary600)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingPage(property: prop),
                        ),
                      );
                    }
                  },
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.lg,
                  leadingIcon: Icons.edit_note_rounded,
                )
              : const AppButton(
                  label: 'Kamar Penuh',
                  onPressed: null,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.lg,
                ),
        ),
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  final String label;
  const _FacilityChip({required this.label});

  IconData _getIcon() {
    final l = label.toLowerCase();
    if (l.contains('wifi') || l.contains('wi-fi')) return Icons.wifi_rounded;
    if (l.contains('ac')) return Icons.ac_unit_rounded;
    if (l.contains('parkir')) return Icons.local_parking_rounded;
    if (l.contains('dapur')) return Icons.kitchen_rounded;
    if (l.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (l.contains('cctv')) return Icons.videocam_outlined;
    if (l.contains('tv')) return Icons.tv_rounded;
    if (l.contains('kasur') || l.contains('spring')) return Icons.bed_rounded;
    if (l.contains('lemari')) return Icons.door_sliding_outlined;
    if (l.contains('kamar mandi')) return Icons.bathroom_outlined;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 14, color: AppColors.primary500),
          const SizedBox(width: 6),
          Text(label,
              style:
                  AppTextStyles.labelSm.copyWith(color: AppColors.primary700)),
        ],
      ),
    );
  }
}

class _PaymentSchemeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final BadgeType badgeType;

  const _PaymentSchemeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMd),
                Text(description, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          StatusBadge(type: badgeType),
        ],
      ),
    );
  }
}
