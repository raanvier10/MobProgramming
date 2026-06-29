import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/formatters.dart';
import '../../../payment/presentation/pages/payment_page.dart';

class BookingPage extends StatefulWidget {
  final Property property;
  const BookingPage({super.key, required this.property});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  int _durationMonths = 1;
  PaymentScheme _selectedScheme = PaymentScheme.penuh;
  PaymentMethod _selectedMethod = PaymentMethod.va;

  double get _totalAmount =>
      widget.property.pricePerMonth * _durationMonths;

  double get _amountToPayNow {
    switch (_selectedScheme) {
      case PaymentScheme.penuh:
        return _totalAmount;
      case PaymentScheme.dp:
        return widget.property.dpAmount;
      case PaymentScheme.cicilan:
        return _totalAmount / widget.property.maxTermin;
    }
  }

  String get _paymentLabel {
    switch (_selectedScheme) {
      case PaymentScheme.penuh:
        return 'Total Pembayaran';
      case PaymentScheme.dp:
        return 'Total DP';
      case PaymentScheme.cicilan:
        return 'Termin Pertama';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prop = widget.property;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Ajukan Sewa'),
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
            // ── Property Summary ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                children: [
                  const Icon(Icons.apartment_rounded, size: 22, color: AppColors.primary500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prop.name, style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(prop.area, style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.formatCompact(prop.pricePerMonth)}/bln',
                    style: AppTextStyles.price.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('Detail Sewa', style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
            const SizedBox(height: 12),

            // ── Check-in Date ─────────────────────────────────
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
                  Text('Tanggal Masuk', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.primary500),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DateFormatter.format(_checkInDate),
                          style: AppTextStyles.bodyLg,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _checkInDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (ctx, child) => Theme(
                              data: Theme.of(ctx).copyWith(
                                colorScheme: const ColorScheme.light(primary: AppColors.primary500),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) setState(() => _checkInDate = picked);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary500,
                          side: const BorderSide(color: AppColors.primary500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Ubah'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Duration Stepper ──────────────────────────────
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
                  Text('Durasi Sewa', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 20, color: AppColors.primary500),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$_durationMonths bulan'
                          ' (${DateFormatter.formatShort(_checkInDate)} → '
                          '${DateFormatter.formatShort(DateTime(_checkInDate.year, _checkInDate.month + _durationMonths, _checkInDate.day))})',
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                      _Stepper(
                        value: _durationMonths,
                        min: 1,
                        max: 24,
                        onChanged: (v) => setState(() => _durationMonths = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('Skema Pembayaran', style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
            const SizedBox(height: 12),

            // ── Payment Scheme ────────────────────────────────
            _SchemeCard(
              scheme: PaymentScheme.penuh,
              selected: _selectedScheme,
              title: 'Bayar Penuh',
              description: 'Bayar ${CurrencyFormatter.format(_totalAmount)} sekaligus',
              icon: Icons.payments_rounded,
              onTap: () => setState(() => _selectedScheme = PaymentScheme.penuh),
            ),
            if (prop.isDpEnabled) ...[
              const SizedBox(height: 8),
              _SchemeCard(
                scheme: PaymentScheme.dp,
                selected: _selectedScheme,
                title: 'Down Payment',
                description: 'Bayar DP ${CurrencyFormatter.format(prop.dpAmount)} sekarang',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => setState(() => _selectedScheme = PaymentScheme.dp),
              ),
            ],
            if (prop.isCicilanEnabled) ...[
              const SizedBox(height: 8),
              _SchemeCard(
                scheme: PaymentScheme.cicilan,
                selected: _selectedScheme,
                title: 'Cicilan',
                description:
                    '${prop.maxTermin}x termin — ~${CurrencyFormatter.formatCompact(_totalAmount / prop.maxTermin)}/termin',
                icon: Icons.calendar_month_outlined,
                onTap: () => setState(() => _selectedScheme = PaymentScheme.cicilan),
              ),
            ],

            const SizedBox(height: 20),
            Text('Metode Pembayaran', style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
            const SizedBox(height: 12),

            // ── Payment Method ────────────────────────────────
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

            const SizedBox(height: 20),

            // ── Summary ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary200),
              ),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.home_outlined,
                    label: 'Properti',
                    value: prop.name,
                  ),
                  const Divider(color: AppColors.primary200, height: 12),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Check-in',
                    value: DateFormatter.formatShort(_checkInDate),
                  ),
                  const Divider(color: AppColors.primary200, height: 12),
                  InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Durasi',
                    value: '$_durationMonths bulan',
                  ),
                  const Divider(color: AppColors.primary200, height: 12),
                  InfoRow(
                    icon: Icons.payments_outlined,
                    label: _paymentLabel,
                    value: CurrencyFormatter.format(_amountToPayNow),
                    valueColor: AppColors.primary500,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
        ),
        child: AppButton(
          label: 'Lanjutkan Pembayaran',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentPage(
                property: prop,
                checkInDate: _checkInDate,
                durationMonths: _durationMonths,
                scheme: _selectedScheme,
                method: _selectedMethod,
              ),
            ),
          ),
          variant: AppButtonVariant.primary,
          size: AppButtonSize.lg,
          trailingIcon: Icons.arrow_forward_rounded,
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value, min, max;
  final void Function(int) onChanged;
  const _Stepper({required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$value', style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary100 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? AppColors.primary300 : AppColors.neutral200,
          ),
        ),
        child: Icon(icon, size: 18, color: onTap != null ? AppColors.primary500 : AppColors.textDisabled),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final PaymentScheme scheme, selected;
  final String title, description;
  final IconData icon;
  final VoidCallback onTap;

  const _SchemeCard({
    required this.scheme,
    required this.selected,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = scheme == selected;
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
        child: Row(
          children: [
            Icon(icon, size: 22, color: isSelected ? AppColors.primary500 : AppColors.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLg),
                  Text(description, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary500 : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary500 : AppColors.borderStrong,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
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
