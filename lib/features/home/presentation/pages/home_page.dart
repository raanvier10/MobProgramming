import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/formatters.dart';
import '../../../property/presentation/pages/property_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  PropertyType? _selectedType;
  double? _maxPrice;
  List<String> _selectedFacilities = [];
  List<Property> _results = [];
  bool _hasSearched = false;

  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = context.read<AppState>();
      setState(() => _results = appState.allProperties);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  void _search() {
    final appState = context.read<AppState>();
    setState(() {
      _hasSearched = true;
      _results = appState.searchProperties(
        query: _searchCtrl.text,
        type: _selectedType,
        maxPrice: _maxPrice,
        facilities: _selectedFacilities,
      );
    });
  }

  void _showFilterModal() {
    double tempMaxPrice = _maxPrice ?? 5000000;
    List<String> tempFacilities = List.from(_selectedFacilities);
    
    final facilitiesList = ['WiFi', 'AC', 'Kasur', 'Kamar Mandi Dalam', 'Lemari', 'Meja'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Pencarian',
                        style: AppTextStyles.displaySm.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Price Range Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Harga Maksimal per Bulan',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          CurrencyFormatter.format(tempMaxPrice),
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.primary600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: AppColors.primary500,
                      inactiveTrackColor: AppColors.primary50,
                      thumbColor: AppColors.primary500,
                      overlayColor: AppColors.primary500.withValues(alpha: 0.15),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: tempMaxPrice,
                      min: 500000,
                      max: 10000000,
                      divisions: 19,
                      onChanged: (val) {
                        setModalState(() => tempMaxPrice = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Facilities
                  Text(
                    'Fasilitas Tersedia',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.textPrimary, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: facilitiesList.map((f) {
                      final isSelected = tempFacilities.contains(f);
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              tempFacilities.remove(f);
                            } else {
                              tempFacilities.add(f);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary500 : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.25),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary500.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                f,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempMaxPrice = 5000000;
                                tempFacilities.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              'Reset',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _maxPrice = tempMaxPrice;
                                _selectedFacilities = tempFacilities;
                              });
                              _search();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary500,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                              shadowColor: AppColors.primary500.withValues(alpha: 0.4),
                            ),
                            child: Text(
                              'Terapkan Filter',
                              style: AppTextStyles.labelMd.copyWith(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final properties = _hasSearched ? _results : appState.allProperties;
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Main scrollable content ──────────────────────────────
          FadeTransition(
            opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: CustomScrollView(
              slivers: [
                // ── Gradient Header ─────────────────────────────────
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    user: user,
                    searchCtrl: _searchCtrl,
                    onSearch: _search,
                    selectedType: _selectedType,
                    onTypeChanged: (type) {
                      setState(() => _selectedType = type);
                      _search();
                    },
                    onFilterPressed: _showFilterModal,
                  ),
                ),

                // ── Body Content ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Section Header ──────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _hasSearched && _searchCtrl.text.isNotEmpty
                                  ? 'Hasil Pencarian (${properties.length})'
                                  : 'Hunian Tersedia',
                              style: AppTextStyles.displaySm.copyWith(
                                fontSize: 17,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (!_hasSearched || _searchCtrl.text.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary50,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: AppColors.primary200),
                                ),
                                child: Text(
                                  '${properties.length} properti',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.primary600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // ── Property List ────────────────────────────────────
                properties.isEmpty
                    ? const SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Tidak Ditemukan',
                          description:
                              'Coba ubah filter atau kata kunci pencarian.',
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final prop = properties[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PropertyCard(
                                  property: prop,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PropertyDetailPage(property: prop),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: properties.length,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Home Header — gradient card matching login style
// ─────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final dynamic user;
  final TextEditingController searchCtrl;
  final VoidCallback onSearch;
  final PropertyType? selectedType;
  final Function(PropertyType?) onTypeChanged;
  final VoidCallback onFilterPressed;

  const _HomeHeader({
    required this.user,
    required this.searchCtrl,
    required this.onSearch,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Hero banner fills from top edge (behind status bar) to a rounded bottom
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Full-width blue hero banner ───────────────────────────
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary500, AppColors.primary400],
            ),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _HomeHeaderPatternPainter()),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Location + Notification ──────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lokasi Kamu',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Karawang, Jawa Barat',
                                      style: AppTextStyles.labelMd.copyWith(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: Colors.white.withValues(alpha: 0.8)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Search bar ──────────────────────────────────────
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchCtrl,
                          onChanged: (_) => onSearch(),
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Cari kos atau kontrakan...',
                            hintStyle: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.textTertiary),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppColors.primary400, size: 20),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(4),
                              child: InkWell(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  onFilterPressed();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.tune_rounded, color: AppColors.primary500, size: 18),
                                ),
                              ),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Categories ──────────────────────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        child: Row(
                          children: [
                            _TypeChip(
                              label: 'Semua',
                              isSelected: selectedType == null,
                              onTap: () => onTypeChanged(null),
                            ),
                            const SizedBox(width: 8),
                            _TypeChip(
                              label: 'Kos',
                              isSelected: selectedType == PropertyType.kos,
                              onTap: () => onTypeChanged(PropertyType.kos),
                            ),
                            const SizedBox(width: 8),
                            _TypeChip(
                              label: 'Kontrakan',
                              isSelected: selectedType == PropertyType.kontrakan,
                              onTap: () => onTypeChanged(PropertyType.kontrakan),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Hero content: text left + illustration right ──────
                      Row(
                        children: [
                          // Left: hero text + CTA
                          Expanded(
                            flex: 55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hunian Nyaman,\nTersedia untukmu!',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.15,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cari kos & kontrakan terbaik di Karawang tanpa ribet',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.78),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Jelajahi',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: house illustration
                          Expanded(
                            flex: 45,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                'assets/images/kos_illustration.png',
                                fit: BoxFit.contain,
                                height: 150,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.home_work_outlined,
                                  size: 80,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Quick Stat Card
// ─────────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.displaySm.copyWith(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Type Filter Chip
// ─────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary600 : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero Pattern Painter
// ─────────────────────────────────────────────────────────────────

class _HomeHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();

    for (var i = -size.width; i < size.width * 2; i += 40) {
      path.moveTo(i.toDouble(), 0);
      path.cubicTo(
        i + 60,
        size.height * 0.3,
        i + 30,
        size.height * 0.7,
        i + 100,
        size.height,
      );
    }

    canvas.drawPath(path, paint);

    // Gelembung besar (Large Bubbles)
    final bubbleFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final bubbleStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Gelembung solid besar di pojok
    canvas.drawCircle(
        Offset(size.width * 0.1, -size.height * 0.1), 120, bubbleFill);
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.8), 150, bubbleFill);

    // Gelembung outline untuk variasi
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2), 60, bubbleStroke);
    canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.85), 45, bubbleStroke);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.1), 30, bubbleStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
