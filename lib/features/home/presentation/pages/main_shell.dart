import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import 'home_page.dart';
import '../../widgets/explore_page.dart';
import '../../widgets/history_page.dart';
import '../../widgets/profile_page.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../admin/presentation/pages/admin_properties_page.dart';
import '../../../admin/presentation/pages/admin_tenants_page.dart';
import '../../../admin/presentation/pages/admin_transactions_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMitra = context.watch<AppState>().isMitra;

    final userPages = [
      const HomePage(),
      const ExplorePage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    final mitraPages = [
      const AdminDashboardPage(),
      const AdminPropertiesPage(),
      const AdminTenantsPage(),
      const AdminTransactionsPage(),
    ];

    final pages = isMitra ? mitraPages : userPages;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A1C1917),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: isMitra
                  ? _buildMitraNavItems()
                  : _buildUserNavItems(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUserNavItems() {
    const items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Jelajahi'),
      _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Riwayat'),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
    ];
    return List.generate(
      items.length,
      (i) => Expanded(
        child: _NavButton(
          item: items[i],
          isActive: _selectedIndex == i,
          onTap: () => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }

  List<Widget> _buildMitraNavItems() {
    const items = [
      _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dasbor'),
      _NavItem(icon: Icons.apartment_outlined, activeIcon: Icons.apartment_rounded, label: 'Properti'),
      _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Penghuni'),
      _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Transaksi'),
    ];
    return List.generate(
      items.length,
      (i) => Expanded(
        child: _NavButton(
          item: items[i],
          isActive: _selectedIndex == i,
          onTap: () => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({required this.item, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary500 : AppColors.neutral400;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              key: ValueKey(isActive),
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
