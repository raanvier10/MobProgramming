import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/property_card.dart';
import '../../property/presentation/pages/property_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  Property? _selectedProperty;
  String? _selectedArea;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Center of Karawang
  static final _karawangCenter = LatLng(-6.3021, 107.3010);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final properties = appState.searchProperties(
      query: _searchQuery,
      area: _selectedArea,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _karawangCenter,
              zoom: 11.5,
              minZoom: 9,
              maxZoom: 18,
              onTap: (_, __) => setState(() => _selectedProperty = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ngekosin.app',
              ),
              MarkerLayer(
                markers: properties.map((prop) {
                  final isSelected = _selectedProperty?.id == prop.id;
                  return Marker(
                    point: LatLng(prop.latitude, prop.longitude),
                    width: isSelected ? 42 : 30,
                    height: isSelected ? 42 : 30,
                    builder: (_) => GestureDetector(
                      onTap: () {
                        setState(() => _selectedProperty = prop);
                        _mapController.move(
                          LatLng(prop.latitude, prop.longitude),
                          14.0,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: prop.status == RoomStatus.tersedia
                              ? AppColors.primary500
                              : AppColors.danger500,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [const BoxShadow(color: Color(0x404F46E5), blurRadius: 12, spreadRadius: 2)]
                              : [const BoxShadow(color: Color(0x221C1917), blurRadius: 4)],
                        ),
                        child: Icon(Icons.apartment_rounded, color: Colors.white, size: isSelected ? 20 : 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Top overlay: App Bar + Filter ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    // Title bar
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Color(0x1A1C1917), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.primary500, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: AppTextStyles.labelLg,
                              decoration: InputDecoration(
                                hintText: 'Cari di Peta (${properties.length} hunian)',
                                hintStyle: AppTextStyles.labelLg.copyWith(color: AppColors.textTertiary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                                FocusScope.of(context).unfocus();
                              },
                              child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Area filter chips
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _AreaChip(
                            label: 'Semua',
                            isSelected: _selectedArea == null,
                            onTap: () => setState(() => _selectedArea = null),
                          ),
                          ...context.read<AppState>().karawangAreas.map(
                                (a) => Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: _AreaChip(
                                    label: a,
                                    isSelected: _selectedArea == a,
                                    onTap: () => setState(() => _selectedArea = a),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── My Location FAB ────────────────────────────────────
          Positioned(
            bottom: _selectedProperty != null ? 220 : 100,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'myloc',
              backgroundColor: AppColors.bgSurface,
              onPressed: () {
                _mapController.move(_karawangCenter, 11.5);
              },
              child: const Icon(Icons.my_location_rounded, color: AppColors.primary500, size: 22),
            ),
          ),

          // ── Bottom Sheet: Selected Property ────────────────────
          if (_selectedProperty != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                decoration: const BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Color(0x1A1C1917), blurRadius: 16, offset: Offset(0, -4))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BottomSheetHandle(),
                    const SizedBox(height: 12),
                    PropertyCardMini(
                      property: _selectedProperty!,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailPage(property: _selectedProperty!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _AreaChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary500 : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x0F1C1917), blurRadius: 4)],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
