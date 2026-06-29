import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ── AppButton ─────────────────────────────────────────────────
enum AppButtonVariant { primary, brand, outline, ghost, danger }
enum AppButtonSize { lg, md, sm, xs }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    final isDisabled = onPressed == null || isLoading;

    Widget child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: config.foreground,
            ),
          )
        else ...[
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: config.iconSize, color: config.foreground),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: config.fontSize,
              fontWeight: FontWeight.w600,
              color: config.foreground,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: config.iconSize, color: config.foreground),
          ],
        ],
      ],
    );

    return AnimatedScale(
      scale: isDisabled ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Material(
          color: config.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: config.height,
              width: fullWidth ? double.infinity : null,
              padding: EdgeInsets.symmetric(horizontal: config.paddingH),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: config.border,
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  _ButtonConfig _getConfig() {
    final heights = {
      AppButtonSize.lg: 52.0,
      AppButtonSize.md: 44.0,
      AppButtonSize.sm: 36.0,
      AppButtonSize.xs: 28.0,
    };
    final paddings = {
      AppButtonSize.lg: 28.0,
      AppButtonSize.md: 24.0,
      AppButtonSize.sm: 16.0,
      AppButtonSize.xs: 12.0,
    };
    final fontSizes = {
      AppButtonSize.lg: 16.0,
      AppButtonSize.md: 14.0,
      AppButtonSize.sm: 13.0,
      AppButtonSize.xs: 12.0,
    };
    final iconSizes = {
      AppButtonSize.lg: 20.0,
      AppButtonSize.md: 18.0,
      AppButtonSize.sm: 16.0,
      AppButtonSize.xs: 14.0,
    };

    Color bg, fg;
    Border? border;
    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.accent500;
        fg = Colors.white;
        break;
      case AppButtonVariant.brand:
        bg = AppColors.primary500;
        fg = Colors.white;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.primary500;
        border = Border.all(color: AppColors.primary500, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.primary500;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.danger500;
        fg = Colors.white;
        break;
    }

    return _ButtonConfig(
      background: bg,
      foreground: fg,
      border: border,
      height: heights[size]!,
      paddingH: paddings[size]!,
      fontSize: fontSizes[size]!,
      iconSize: iconSizes[size]!,
    );
  }
}

class _ButtonConfig {
  final Color background;
  final Color foreground;
  final Border? border;
  final double height;
  final double paddingH;
  final double fontSize;
  final double iconSize;

  _ButtonConfig({
    required this.background,
    required this.foreground,
    this.border,
    required this.height,
    required this.paddingH,
    required this.fontSize,
    required this.iconSize,
  });
}

// ── StatusBadge ───────────────────────────────────────────────
enum BadgeType { tersedia, penuh, bayarPenuh, dp, cicilan, pending, aktif }

class StatusBadge extends StatelessWidget {
  final BadgeType type;
  const StatusBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.dot)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: config.text,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            config.label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.text,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (type) {
      case BadgeType.tersedia:
        return _BadgeConfig(AppColors.success50, AppColors.success700, 'Tersedia', true);
      case BadgeType.penuh:
        return _BadgeConfig(AppColors.danger50, AppColors.danger700, 'Penuh', true);
      case BadgeType.bayarPenuh:
        return _BadgeConfig(AppColors.primary100, AppColors.primary700, 'Bayar Penuh', false);
      case BadgeType.dp:
        return _BadgeConfig(AppColors.accent100, AppColors.accent800, 'Bisa DP', false);
      case BadgeType.cicilan:
        return _BadgeConfig(AppColors.info50, AppColors.info700, 'Bisa Cicil', false);
      case BadgeType.pending:
        return _BadgeConfig(AppColors.warning50, AppColors.warning700, 'Menunggu Bayar', true);
      case BadgeType.aktif:
        return _BadgeConfig(AppColors.success50, AppColors.success700, 'Aktif', true);
    }
  }
}

class _BadgeConfig {
  final Color bg, text;
  final String label;
  final bool dot;
  _BadgeConfig(this.bg, this.text, this.label, this.dot);
}

// ── AppTextField ──────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? errorText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.errorText,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.textTertiary)
                : null,
            suffix: suffix,
            filled: true,
            fillColor: enabled ? AppColors.bgMuted : AppColors.bgMuted.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderDanger, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── AppSearchBar ──────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onFilterTap;

  const AppSearchBar({
    super.key,
    this.hint = 'Cari kos atau kontrakan...',
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Icon(Icons.search, size: 18, color: AppColors.textTertiary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (onFilterTap != null)
            IconButton(
              icon: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textTertiary),
              onPressed: onFilterTap,
              tooltip: 'Filter',
            ),
        ],
      ),
    );
  }
}

// ── SectionHeader ─────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.displaySm),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary500),
            ),
          ),
      ],
    );
  }
}

// ── EmptyState ────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.neutral300),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.displaySm.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.brand,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── DividerWithLabel ──────────────────────────────────────────
class DividerWithLabel extends StatelessWidget {
  final String label;
  const DividerWithLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderDefault)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppTextStyles.labelSm,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderDefault)),
      ],
    );
  }
}

// ── InfoRow ───────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMd.copyWith(color: valueColor ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── BottomSheetHandle ─────────────────────────────────────────
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutral300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
