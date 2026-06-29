import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser;
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final appState = context.read<AppState>();
    appState.updateProfile(_nameCtrl.text.trim(), _phoneCtrl.text.trim());
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success500, size: 22),
            const SizedBox(width: 12),
            Text(
              'Profil berhasil diperbarui',
              style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _changeProfilePicture(BuildContext context) {
    String? pickedPath;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              elevation: 10,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Center(
                child: Text('Ganti Foto Profil', style: AppTextStyles.displaySm.copyWith(fontWeight: FontWeight.w700)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pilih foto profil baru dari galeri perangkat Anda.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (pickedPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Image.network(pickedPath!, height: 120, width: 120, fit: BoxFit.cover)
                          : Image.file(File(pickedPath!), height: 120, width: 120, fit: BoxFit.cover),
                    )
                  else
                    InkWell(
                      onTap: () async {
                        try {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setDialogState(() {
                              pickedPath = image.path;
                            });
                          }
                        } catch (e) {
                          // Ignore error
                        }
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary300, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary500),
                            SizedBox(height: 8),
                            Text('Pilih Foto', style: TextStyle(color: AppColors.primary500, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  if (pickedPath != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setDialogState(() => pickedPath = null),
                      child: const Text('Hapus Pilihan', style: TextStyle(color: AppColors.danger500)),
                    ),
                  ],
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.textSecondary),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Batal', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: pickedPath == null ? null : () {
                          final appState = context.read<AppState>();
                          appState.updateProfile(
                            appState.currentUser!.name,
                            appState.currentUser!.phone,
                            avatarUrl: pickedPath,
                          );
                          Navigator.pop(ctx);
                        },
                        child: Text('Simpan', style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Keluar Akun',
            style: AppTextStyles.displaySm.copyWith(color: AppColors.danger500)),
        content: Text(
          'Apakah kamu yakin ingin keluar dari akun Ngekos.in ini?',
          style: AppTextStyles.bodyLg.copyWith(color: AppColors.textSecondary),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: Colors.grey.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Batal',
                      style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger500,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.read<AppState>().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    );
                  },
                  child: Text('Keluar',
                      style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(AppUser user) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: AppColors.primary100,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
        style: AppTextStyles.displayLg
            .copyWith(color: AppColors.primary500, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── APPBAR STANDAR (TIDAK TERLALU KE BAWAH / BIASA AJA) ────────────────
          SliverAppBar(
            expandedHeight:
                70.0, // Diubah menjadi lebih pendek agar pas & proporsional
            floating: false,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primary500,
            title: Text(
              'Profil Saya',
              style: AppTextStyles.displayMd.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary600,
                          AppColors.primary500,
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: HeaderPatternPainter(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: !_isEditing
                    ? IconButton(
                        key: const ValueKey('edit_btn'),
                        icon:
                            const Icon(Icons.edit_rounded, color: Colors.white),
                        onPressed: () => setState(() => _isEditing = true),
                      )
                    : TextButton(
                        key: const ValueKey('save_btn'),
                        onPressed: _saveProfile,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
            ],
          ),

          // ── KONTEN HALAMAN ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar & Name Card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutral500.withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primary500.withOpacity(0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: user.avatarUrl != null &&
                                        user.avatarUrl!.isNotEmpty
                                    ? (user.avatarUrl!.startsWith('http') || user.avatarUrl!.startsWith('https') 
                                        ? CachedNetworkImage(
                                            imageUrl: user.avatarUrl!,
                                            width: 104,
                                            height: 104,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              width: 104,
                                              height: 104,
                                              color: AppColors.primary100,
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  color: AppColors.primary500,
                                                  strokeWidth: 3,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => _buildFallbackAvatar(user),
                                          )
                                        : (kIsWeb
                                            ? Image.network(
                                                user.avatarUrl!,
                                                width: 104,
                                                height: 104,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(user),
                                              )
                                            : Image.file(
                                                File(user.avatarUrl!),
                                                width: 104,
                                                height: 104,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(user),
                                              )))
                                    : _buildFallbackAvatar(user),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _changeProfilePicture(context),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.accent500,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent500
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Column(
                            children: [
                              if (!_isEditing) ...[
                                Text(user.name,
                                    style: AppTextStyles.displaySm
                                        .copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(user.email,
                                    style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning50,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: AppColors.accent300
                                            .withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        user.role == UserRole.user
                                            ? Icons.person_rounded
                                            : Icons.business_center_rounded,
                                        size: 14,
                                        color: AppColors.warning700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        user.role == UserRole.user
                                            ? 'PENCARI HUNIAN'
                                            : 'MITRA',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.warning700,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                AppTextField(
                                  label: 'Nama Lengkap',
                                  controller: _nameCtrl,
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Nomor HP',
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Icons.phone_outlined,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Info Card ─────────────────────────────────────────────
                  if (!_isEditing) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text('Informasi Akun',
                          style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral500.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email),
                          const Divider(
                              indent: 20,
                              endIndent: 20,
                              height: 1,
                              color: AppColors.borderDefault),
                          _buildInfoTile(
                              icon: Icons.phone_outlined,
                              label: 'Telepon',
                              value: user.phone.isNotEmpty ? user.phone : '-'),
                          const Divider(
                              indent: 20,
                              endIndent: 20,
                              height: 1,
                              color: AppColors.borderDefault),
                          _buildInfoTile(
                            icon: Icons.badge_outlined,
                            label: 'Peran',
                            value: user.role == UserRole.user
                                ? 'Pencari Hunian'
                                : 'Mitra/Admin',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Menu Pengaturan ─────────────────────────────────────────────
                  if (!_isEditing) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text('Pengaturan',
                          style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral500.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            label: 'Bantuan & FAQ',
                            onTap: () {},
                          ),
                          const Divider(
                              indent: 56,
                              endIndent: 20,
                              height: 1,
                              color: AppColors.borderDefault),
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            label: 'Tentang Ngekos.in',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  title: const Text('Tentang Ngekos.in',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  content: const Text(
                                    'Ngekos.in v1.0.0\n\nAplikasi pencarian hunian (kos & kontrakan) di wilayah Karawang.\n\nDikembangkan untuk Proyek Akhir Mobile Programming.',
                                    style: TextStyle(height: 1.5),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup',
                                          style: TextStyle(
                                              color: AppColors.primary500,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const Divider(
                              indent: 56,
                              endIndent: 20,
                              height: 1,
                              color: AppColors.borderDefault),
                          _MenuItem(
                            icon: Icons.logout_rounded,
                            label: 'Keluar Akun',
                            labelColor: AppColors.danger500,
                            iconColor: AppColors.danger500,
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: InfoRow(icon: icon, label: label, value: value),
    );
  }
}

// ── DESIGN PATTERN TETAP DIADAIN TAPI DISESUAIKAN TINGGINYA ──────────────────
class HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.textSecondary,
    this.labelColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLg.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: AppColors.neutral300),
            ],
          ),
        ),
      ),
    );
  }
}
