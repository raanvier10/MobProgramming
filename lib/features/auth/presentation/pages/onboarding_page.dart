import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/images/onboarding_search.png',
      title: 'Temukan Hunian\ndi Karawang',
      description:
          'Cari kos dan kontrakan terbaik di seluruh wilayah Karawang dengan mudah dan cepat.',
      gradientColors: [
        const Color(0xFF667eea),
        const Color(0xFF764ba2),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_map.png',
      title: 'Peta Interaktif\nBerbasis GPS',
      description:
          'Lihat lokasi hunian terdekat dari posisimu secara real-time di peta digital.',
      gradientColors: [
        const Color(0xFF11998e),
        const Color(0xFF38ef7d),
      ],
    ),
    _OnboardingData(
      image: 'assets/images/onboarding_payment.png',
      title: 'Pembayaran\nFleksibel',
      description:
          'Bayar penuh, DP, atau cicilan via Virtual Account & QRIS. Semua dalam satu aplikasi.',
      gradientColors: [
        const Color(0xFFf093fb),
        const Color(0xFFf5576c),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (visible on page > 0)
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: _currentPage > 0
                          ? () {
                              _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    GestureDetector(
                      onTap: _goToLogin,
                      child: Text(
                        'Lewati',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return AnimatedBuilder(
                    animation:
                        Listenable.merge([_floatAnimation, _fadeAnimation]),
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _OnboardingSlide(
                          data: data,
                          floatOffset: _floatAnimation.value,
                          isLastPage: index == _pages.length - 1,
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom section — dots, button, sign in
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = _currentPage == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary500
                              : AppColors.neutral200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  _AnimatedCTAButton(
                    label: isLast ? 'Mulai Sekarang' : 'Lanjut',
                    onPressed: () {
                      if (!isLast) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToLogin();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sign in row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToLogin,
                        child: Text(
                          'Masuk',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

// ── Animated CTA Button ──────────────────────────────────────
class _AnimatedCTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _AnimatedCTAButton({required this.label, required this.onPressed});

  @override
  State<_AnimatedCTAButton> createState() => _AnimatedCTAButtonState();
}

class _AnimatedCTAButtonState extends State<_AnimatedCTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.reverse();
      },
      onTapUp: (_) {
        _controller.forward();
        widget.onPressed();
      },
      onTapCancel: () {
        _controller.forward();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary500, AppColors.primary400],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary500.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
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

// ── Onboarding Data ──────────────────────────────────────────
class _OnboardingData {
  final String image;
  final String title;
  final String description;
  final List<Color> gradientColors;

  _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}

// ── Onboarding Slide ─────────────────────────────────────────
class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final double floatOffset;
  final bool isLastPage;

  const _OnboardingSlide({
    required this.data,
    required this.floatOffset,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Illustration area
          Expanded(
            flex: 5,
            child: _buildIllustration(context),
          ),

          const SizedBox(height: 24),

          // Text area
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.displayXl.copyWith(
                    fontSize: 30,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    data.description,
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.65;
    final cardHeight = cardWidth * 1.15;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Decorative circles
        ..._buildDecoCircles(cardWidth, cardHeight),

        // Main card — floating
        Transform.translate(
          offset: Offset(0, floatOffset),
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  data.gradientColors[0].withOpacity(0.12),
                  data.gradientColors[1].withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: data.gradientColors[0].withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.gradientColors[0].withOpacity(0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Image
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Accent badge top-right
        Positioned(
          top: 10 + floatOffset,
          right: 20,
          child: _AccentDot(
            color: data.gradientColors[0],
            size: 32,
            icon: _getIconForPage(),
          ),
        ),
      ],
    );
  }

  IconData _getIconForPage() {
    if (data.image.contains('search')) return Icons.search_rounded;
    if (data.image.contains('map')) return Icons.place_rounded;
    return Icons.payments_rounded;
  }

  List<Widget> _buildDecoCircles(double cardW, double cardH) {
    return [
      // Top-left small circle
      Positioned(
        top: 0,
        left: 10,
        child: Transform.translate(
          offset: Offset(0, floatOffset * 0.5),
          child: _DecorCircle(
            size: 14,
            color: data.gradientColors[1].withOpacity(0.4),
          ),
        ),
      ),
      // Bottom-right small circle
      Positioned(
        bottom: 30,
        right: 15,
        child: Transform.translate(
          offset: Offset(0, -floatOffset * 0.3),
          child: _DecorCircle(
            size: 10,
            color: data.gradientColors[0].withOpacity(0.5),
          ),
        ),
      ),
      // Mid-left circle
      Positioned(
        top: cardH * 0.5,
        left: 0,
        child: Transform.translate(
          offset: Offset(0, floatOffset * 0.7),
          child: _DecorCircle(
            size: 20,
            color: AppColors.accent400.withOpacity(0.5),
          ),
        ),
      ),
      // Top-right circle
      Positioned(
        top: 25,
        right: 5,
        child: Transform.translate(
          offset: Offset(0, -floatOffset * 0.4),
          child: _DecorCircle(
            size: 16,
            color: AppColors.success500.withOpacity(0.5),
          ),
        ),
      ),
    ];
  }
}

// ── Accent Dot with Icon ─────────────────────────────────────
class _AccentDot extends StatelessWidget {
  final Color color;
  final double size;
  final IconData icon;

  const _AccentDot({
    required this.color,
    required this.size,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.5, color: Colors.white),
    );
  }
}

// ── Decorative Circle ────────────────────────────────────────
class _DecorCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
