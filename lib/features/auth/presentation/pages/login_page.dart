import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/pages/main_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _errorMsg;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final appState = context.read<AppState>();
    final navigator = Navigator.of(context);

    await Future.delayed(const Duration(milliseconds: 600));

    final success =
        appState.login(_emailCtrl.text.trim(), _passCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } else {
      setState(() => _errorMsg = 'Email atau password salah. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
          // ── Decorative BG blobs ──────────────────────────
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary400.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent400.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.28,
            right: 24,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.accent400.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.18,
            left: 30,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.success500.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // ── Logo + Heading ──────────────────
                      Center(
                        child: Column(
                          children: [
                            // Logo
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary500,
                                    AppColors.primary400,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Selamat Datang!',
                              style: AppTextStyles.displayLg
                                  .copyWith(fontSize: 26, letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Masuk untuk lanjut ke Ngekos.in',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Error banner ───────────────────
                      if (_errorMsg != null) ...[
                        _ErrorBanner(message: _errorMsg!),
                        const SizedBox(height: 16),
                      ],

                      // ── Email field ────────────────────
                      const _AuthLabel('Email'),
                      const SizedBox(height: 8),
                      _AuthField(
                        controller: _emailCtrl,
                        hint: 'masukkan@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v?.isEmpty ?? true) ? 'Email wajib diisi' : null,
                      ),

                      const SizedBox(height: 20),

                      // ── Password field ─────────────────
                      const _AuthLabel('Password'),
                      const SizedBox(height: 8),
                      _AuthField(
                        controller: _passCtrl,
                        hint: 'Minimal 6 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePass,
                        suffixIcon: GestureDetector(
                          onTap: () =>
                              setState(() => _obscurePass = !_obscurePass),
                          child: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        validator: (v) => (v?.length ?? 0) < 6
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),

                      const SizedBox(height: 32),

                      // ── CTA Button ─────────────────────
                      _GradientButton(
                        label: 'Masuk',
                        isLoading: _isLoading,
                        onPressed: _login,
                      ),

                      const SizedBox(height: 20),

                      // ── Sign up link ───────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            ),
                            child: Text(
                              'Daftar Sekarang',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.primary500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Demo accounts ──────────────────
                      const _DemoBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Shared Auth Widgets
// ─────────────────────────────────────────────────────────────────

class _AuthLabel extends StatelessWidget {
  final String text;
  const _AuthLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMd.copyWith(
        color: AppColors.textPrimary,
        fontSize: 13.5,
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textTertiary),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(prefixIcon, size: 20, color: AppColors.textTertiary),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.borderDefault, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger500, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger500, width: 1.8),
        ),
        errorStyle: AppTextStyles.bodySm.copyWith(color: AppColors.danger500),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) _scaleCtrl.reverse();
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          _scaleCtrl.forward();
          widget.onPressed();
        }
      },
      onTapCancel: () => _scaleCtrl.forward(),
      child: AnimatedBuilder(
        animation: _scaleCtrl,
        builder: (_, child) =>
            Transform.scale(scale: _scaleCtrl.value, child: child),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary500, AppColors.primary400],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger500.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger500, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBox extends StatelessWidget {
  const _DemoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary600),
              const SizedBox(width: 6),
              Text(
                'Akun Demo',
                style:
                    AppTextStyles.labelMd.copyWith(color: AppColors.primary700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _DemoRow('Pencari Hunian', 'budi@email.com', 'password123'),
          const SizedBox(height: 4),
          const _DemoRow('Pemilik/Mitra', 'hendra@email.com', 'mitra123'),
        ],
      ),
    );
  }
}

class _DemoRow extends StatelessWidget {
  final String role, email, pass;
  const _DemoRow(this.role, this.email, this.pass);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: AppColors.primary400, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style:
                  const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
              children: [
                TextSpan(
                  text: '$role: ',
                  style: const TextStyle(
                      color: AppColors.primary700, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: '$email / $pass',
                  style: const TextStyle(color: AppColors.primary500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
