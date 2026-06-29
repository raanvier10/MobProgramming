import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/data/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/formatters.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  BadgeType get _statusBadge =>
      property.status == RoomStatus.tersedia ? BadgeType.tersedia : BadgeType.penuh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1C1917),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ─────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: property.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: property.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.neutral100),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.neutral100,
                              child: const Icon(Icons.apartment_rounded,
                                  color: AppColors.neutral300, size: 48),
                            ),
                          )
                        : Container(
                            color: AppColors.neutral100,
                            child: const Icon(Icons.apartment_rounded,
                                color: AppColors.neutral300, size: 48),
                          ),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: StatusBadge(type: _statusBadge),
                ),
                // Type badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary700.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      property.type == PropertyType.kos ? 'Kos' : 'Kontrakan',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── Content ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: AppTextStyles.labelLg.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          property.area,
                          style: AppTextStyles.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(property.pricePerMonth),
                        style: AppTextStyles.price,
                      ),
                      Text(
                        '/bulan',
                        style: AppTextStyles.labelSm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Payment scheme badges
                  Wrap(
                    spacing: 4,
                    children: [
                      StatusBadge(type: BadgeType.bayarPenuh),
                      if (property.isDpEnabled) StatusBadge(type: BadgeType.dp),
                      if (property.isCicilanEnabled) StatusBadge(type: BadgeType.cicilan),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini Property Card (for map bottom sheet) ─────────────────
class PropertyCardMini extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCardMini({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 110,
                height: double.infinity,
                child: property.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: property.imageUrls.first,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.neutral100,
                        child: const Icon(Icons.apartment_rounded, color: AppColors.neutral300),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(property.name,
                        style: AppTextStyles.labelMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(property.area, style: AppTextStyles.labelSm, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.formatCompact(property.pricePerMonth),
                          style: AppTextStyles.price.copyWith(fontSize: 15),
                        ),
                        Text('/bln', style: AppTextStyles.labelSm.copyWith(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.primary500, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
