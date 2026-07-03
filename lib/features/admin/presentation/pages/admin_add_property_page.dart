import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/app_state.dart';
import '../../../../core/data/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/mitra_widgets.dart';

class AdminAddPropertyPage extends StatefulWidget {
  final Property? property;
  const AdminAddPropertyPage({super.key, this.property});
  @override
  State<AdminAddPropertyPage> createState() => _AdminAddPropertyPageState();
}

class _AdminAddPropertyPageState extends State<AdminAddPropertyPage> {
  int _step = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _dpAmountCtrl = TextEditingController();
  final _maxTerminCtrl = TextEditingController();
  PropertyType _type = PropertyType.kos;
  RoomGender _gender = RoomGender.mixed;
  List<String> _facilities = [];
  bool _isDpEnabled = false;
  bool _isCicilanEnabled = false;
  bool _isLoading = false;
  LatLng _selectedLocation = LatLng(-6.3021, 107.3010);
  bool _locationPicked = false;
  List<String> _imageUrls = [];

  final _stepLabels = ['Info', 'Foto', 'Lokasi', 'Bayar', 'Review'];
  final _allFacilities = [
    'Wi-Fi',
    'AC',
    'Kamar Mandi Dalam',
    'Kamar Mandi Luar',
    'Parkir Motor',
    'Parkir Mobil',
    'Dapur Bersama',
    'Dapur Pribadi',
    'Laundry',
    'CCTV',
    'Ruang Tamu',
    'Kasur',
    'Lemari Pakaian',
    'Meja Belajar'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.property != null) _loadProperty(widget.property!);
  }

  void _loadProperty(Property p) {
    _nameCtrl.text = p.name;
    _descCtrl.text = p.description;
    _priceCtrl.text = p.pricePerMonth.toInt().toString();
    _areaCtrl.text = p.area;
    _addressCtrl.text = p.fullAddress;
    _dpAmountCtrl.text = p.dpAmount.toInt().toString();
    _maxTerminCtrl.text = p.maxTermin.toString();
    _type = p.type;
    _gender = p.roomGender;
    _facilities = List.from(p.facilities);
    _isDpEnabled = p.isDpEnabled;
    _isCicilanEnabled = p.isCicilanEnabled;
    _selectedLocation = LatLng(p.latitude, p.longitude);
    _locationPicked = true;
    _imageUrls = List.from(p.imageUrls);
  }

  void _saveDraft() {
    // Fitur draft dinonaktifkan atas permintaan user agar form selalu fresh
  }

  bool _validateCurrentStep() {
    if (_step == 0) return _formKeys[0].currentState?.validate() ?? false;
    if (_step == 1 && _imageUrls.isEmpty) {
      showMitraToast(context, 'Tambahkan minimal 1 foto',
          type: ToastType.error);
      return false;
    }
    if (_step == 2) {
      if (!_formKeys[2].currentState!.validate()) return false;
      if (!_locationPicked) {
        showMitraToast(context, 'Tandai lokasi properti di peta',
            type: ToastType.error);
        return false;
      }
      return true;
    }
    if (_step == 3) return _formKeys[3].currentState?.validate() ?? false;
    return true;
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    setState(() => _step++);
  }

  void _back() {
    setState(() => _step--);
  }

  void _publish() async {
    if (!_validateCurrentStep()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final appState = context.read<AppState>();
    final user = appState.currentUser!;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final dpAmt = double.tryParse(_dpAmountCtrl.text) ?? 0;
    final maxT = int.tryParse(_maxTerminCtrl.text) ?? 0;

    if (widget.property == null) {
      appState.addProperty(Property(
        id: 'prop-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _type,
        roomGender: _gender,
        status: RoomStatus.tersedia,
        pricePerMonth: price,
        imageUrls: _imageUrls.isEmpty
            ? [
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800'
              ]
            : _imageUrls,
        facilities: _facilities,
        area: _areaCtrl.text.trim(),
        fullAddress: _addressCtrl.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        ownerId: user.id,
        ownerName: user.name,
        isDpEnabled: _isDpEnabled,
        dpAmount: _isDpEnabled ? dpAmt : 0,
        isCicilanEnabled: _isCicilanEnabled,
        maxTermin: _isCicilanEnabled ? maxT : 0,
      ));
    } else {
      appState.updateProperty(widget.property!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _type,
        roomGender: _gender,
        pricePerMonth: price,
        facilities: _facilities,
        area: _areaCtrl.text.trim(),
        fullAddress: _addressCtrl.text.trim(),
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        isDpEnabled: _isDpEnabled,
        dpAmount: _isDpEnabled ? dpAmt : 0,
        isCicilanEnabled: _isCicilanEnabled,
        maxTermin: _isCicilanEnabled ? maxT : 0,
      ));
    }
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      showMitraToast(
          context,
          widget.property == null
              ? 'Properti berhasil dipublikasikan!'
              : 'Properti diperbarui');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _areaCtrl.dispose();
    _addressCtrl.dispose();
    _dpAmountCtrl.dispose();
    _maxTerminCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) {
          _back();
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: Text(
              widget.property == null ? 'Tambah Properti' : 'Edit Properti'),
          backgroundColor: AppColors.bgSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (_step > 0)
                _back();
              else {
                Navigator.pop(context);
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.borderDefault),
          ),
        ),
        body: Column(
          children: [
            StepIndicator(currentStep: _step, stepLabels: _stepLabels),
            Expanded(child: _buildStepContent()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildInfoStep();
      case 1:
        return _buildPhotoStep();
      case 2:
        return _buildLocationStep();
      case 3:
        return _buildPaymentStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoStep() {
    final areas = context.read<AppState>().karawangAreas;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeys[0],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Informasi Dasar',
              style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text('Isi detail utama propertimu', style: AppTextStyles.bodySm),
          const SizedBox(height: 16),
          AppTextField(
              label: 'Nama Properti',
              hint: 'Contoh: Kos Harmoni',
              controller: _nameCtrl,
              validator: (v) => v!.trim().isEmpty ? 'Nama wajib diisi' : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _buildDropdown<PropertyType>(
                    'Tipe',
                    _type,
                    PropertyType.values,
                    (t) => t == PropertyType.kos ? 'Kos' : 'Kontrakan',
                    (v) => setState(() => _type = v!))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildDropdown<RoomGender>(
                    'Peruntukan',
                    _gender,
                    RoomGender.values,
                    (g) => g == RoomGender.male
                        ? 'Putra'
                        : g == RoomGender.female
                            ? 'Putri'
                            : 'Campur',
                    (v) => setState(() => _gender = v!))),
          ]),
          const SizedBox(height: 12),
          AppTextField(
              label: 'Deskripsi',
              hint: 'Ceritakan keunggulan propertimu...',
              controller: _descCtrl,
              maxLines: 4,
              validator: (v) =>
                  v!.trim().isEmpty ? 'Deskripsi wajib diisi' : null),
          const SizedBox(height: 20),
          Text('Fasilitas',
              style: AppTextStyles.displaySm.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Pilih minimal 1 fasilitas', style: AppTextStyles.bodySm),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allFacilities.map((f) {
                final sel = _facilities.contains(f);
                return FilterChip(
                    label: Text(f),
                    selected: sel,
                    onSelected: (s) => setState(
                        () => s ? _facilities.add(f) : _facilities.remove(f)),
                    selectedColor: AppColors.primary100,
                    checkmarkColor: AppColors.primary700,
                    labelStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                        color: sel
                            ? AppColors.primary700
                            : AppColors.textSecondary),
                    backgroundColor: AppColors.bgSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color: sel
                                ? AppColors.primary500
                                : AppColors.borderDefault)));
              }).toList()),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Foto Properti',
            style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text('Tambahkan foto agar propertimu lebih menarik',
            style: AppTextStyles.bodySm),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() {
            _imageUrls.add(
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800');
          }),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=800'),
                  fit: BoxFit.cover,
                  opacity: 0.15,
                ),
                border: Border.all(
                    color: AppColors.primary200,
                    width: 2,
                    style: BorderStyle.solid)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary500.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.add_a_photo_rounded,
                    size: 28, color: AppColors.primary500),
              ),
              const SizedBox(height: 12),
              Text('Unggah Foto Properti',
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.primary700)),
              const SizedBox(height: 4),
              Text('Format JPG, PNG • Maks 5MB',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700.withOpacity(0.6), fontSize: 12)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        if (_imageUrls.isNotEmpty) ...[
          Text('${_imageUrls.length} foto ditambahkan',
              style: AppTextStyles.labelSm),
          const SizedBox(height: 8),
          SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(_imageUrls[i],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: AppColors.neutral100,
                              child: const Icon(Icons.broken_image_rounded)))),
                  Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                          onTap: () => setState(() => _imageUrls.removeAt(i)),
                          child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                  color: AppColors.danger500,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white)))),
                ]),
              )),
        ],
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.info50,
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.info500),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Foto pertama akan menjadi cover listing propertimu.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.info700, fontSize: 12))),
            ])),
      ]),
    );
  }

  Widget _buildLocationStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.all(16),
          child:
              Form(
                key: _formKeys[2],
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Lokasi Properti',
                      style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Ketuk peta untuk menandai lokasi',
                      style: AppTextStyles.bodySm),
                  const SizedBox(height: 12),
                  AppTextField(
                      label: 'Wilayah Karawang',
                hint: 'Contoh: Teluk Jambe',
                controller: _areaCtrl,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
            const SizedBox(height: 12),
            AppTextField(
                label: 'Alamat Lengkap',
                hint: 'Jl. Merdeka No. 123...',
                controller: _addressCtrl,
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
          ]))),
      Expanded(
          child: Stack(children: [
        FlutterMap(
          options: MapOptions(
            center: _selectedLocation,
            zoom: 15,
            onTap: (_, latlng) => setState(() {
              _selectedLocation = latlng;
              _locationPicked = true;
            }),
          ),
          children: [
            TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ngekosin.app'),
            if (_locationPicked)
              MarkerLayer(markers: [
                Marker(
                    point: _selectedLocation,
                    width: 40,
                    height: 40,
                    builder: (_) => const Icon(Icons.location_on,
                        color: AppColors.primary500, size: 40)),
              ]),
          ],
        ),
        if (_locationPicked)
          Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A000000), blurRadius: 8)
                      ]),
                  child: Row(children: [
                    const Icon(Icons.pin_drop_rounded,
                        size: 18, color: AppColors.success500),
                    const SizedBox(width: 8),
                    Text(
                        '${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}',
                        style: AppTextStyles.labelSm),
                  ]))),
      ])),
    ]);
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
          key: _formKeys[3],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Harga & Pembayaran',
                style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text('Atur harga dan skema pembayaran',
                style: AppTextStyles.bodySm),
            const SizedBox(height: 16),
            AppTextField(
                label: 'Harga per Bulan (Rp)',
                hint: '1500000',
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Harga wajib diisi';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Masukkan angka valid > 0';
                  return null;
                }),
            const SizedBox(height: 16),
            _paymentToggle(
                'Aktifkan DP',
                'Izinkan calon penghuni bayar uang muka',
                _isDpEnabled,
                (v) => setState(() => _isDpEnabled = v)),
            if (_isDpEnabled)
              Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  child: AppTextField(
                      label: 'Nominal DP (Rp)',
                      controller: _dpAmountCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (!_isDpEnabled) return null;
                        if (v!.isEmpty) return 'Nominal DP wajib diisi';
                        final dp = double.tryParse(v);
                        if (dp == null || dp <= 0)
                          return 'Masukkan angka valid';
                        final price = double.tryParse(_priceCtrl.text) ?? 0;
                        if (price > 0 && dp > price)
                          return 'DP tidak boleh melebihi harga';
                        return null;
                      })),
            const SizedBox(height: 12),
            _paymentToggle(
                'Aktifkan Cicilan',
                'Izinkan cicilan untuk sewa panjang',
                _isCicilanEnabled,
                (v) => setState(() => _isCicilanEnabled = v)),
            if (_isCicilanEnabled)
              Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                  child: AppTextField(
                      label: 'Maks Termin',
                      hint: '3',
                      controller: _maxTerminCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (!_isCicilanEnabled) return null;
                        if (v!.isEmpty) return 'Termin wajib diisi';
                        final t = int.tryParse(v);
                        if (t == null || t < 1) return 'Minimal 1 termin';
                        return null;
                      })),
            const SizedBox(height: 32),
          ])),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Review & Publikasi',
            style: AppTextStyles.displaySm.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text('Periksa kembali sebelum dipublikasikan',
            style: AppTextStyles.bodySm),
        const SizedBox(height: 16),
        _reviewSection('Info Dasar', [
          _reviewItem('Nama', _nameCtrl.text),
          _reviewItem('Tipe', _type == PropertyType.kos ? 'Kos' : 'Kontrakan'),
          _reviewItem(
              'Peruntukan',
              _gender == RoomGender.male
                  ? 'Putra'
                  : _gender == RoomGender.female
                      ? 'Putri'
                      : 'Campur'),
          _reviewItem(
              'Fasilitas', _facilities.isEmpty ? '-' : _facilities.join(', ')),
        ]),
        _reviewSection('Lokasi', [
          _reviewItem('Wilayah', _areaCtrl.text.isEmpty ? '-' : _areaCtrl.text),
          _reviewItem(
              'Alamat', _addressCtrl.text.isEmpty ? '-' : _addressCtrl.text),
          _reviewItem(
              'Koordinat',
              _locationPicked
                  ? '${_selectedLocation.latitude.toStringAsFixed(4)}, ${_selectedLocation.longitude.toStringAsFixed(4)}'
                  : 'Belum ditandai'),
        ]),
        _reviewSection(
            'Foto', [_reviewItem('Jumlah', '${_imageUrls.length} foto')]),
        _reviewSection('Pembayaran', [
          _reviewItem('Harga/bln', 'Rp ${_priceCtrl.text}'),
          _reviewItem(
              'DP', _isDpEnabled ? 'Ya — Rp ${_dpAmountCtrl.text}' : 'Tidak'),
          _reviewItem(
              'Cicilan',
              _isCicilanEnabled
                  ? 'Ya — Maks ${_maxTerminCtrl.text} termin'
                  : 'Tidak'),
        ]),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _reviewSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary500.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary600)),
        const Divider(height: 24, color: AppColors.borderDefault),
        ...items,
      ]),
    );
  }

  Widget _reviewItem(String label, String value) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.bodySm)),
          Expanded(
              child: Text(value,
                  style: AppTextStyles.labelMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
        ]));
  }

  Widget _paymentToggle(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: value ? AppColors.primary50 : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: value ? AppColors.primary200 : AppColors.borderDefault),
          boxShadow: [
            if (value)
              BoxShadow(
                color: AppColors.primary500.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
          ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value ? AppColors.primary100 : AppColors.bgMuted,
            shape: BoxShape.circle,
          ),
          child: Icon(value ? Icons.check_rounded : Icons.payments_outlined, 
               size: 20, color: value ? AppColors.primary600 : AppColors.textTertiary),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.labelMd.copyWith(color: value ? AppColors.primary700 : AppColors.textPrimary)),
          Text(subtitle,
              style: AppTextStyles.bodySm
                  .copyWith(color: value ? AppColors.primary600.withOpacity(0.8) : AppColors.textTertiary, fontSize: 12)),
        ])),
        Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary500),
      ]),
    );
  }

  Widget _buildDropdown<T>(String label, T value, List<T> items,
      String Function(T) labelFn, ValueChanged<T?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style:
              AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.bgMuted,
              borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  items: items
                      .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(labelFn(t), style: AppTextStyles.bodyMd)))
                      .toList(),
                  onChanged: onChanged))),
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderDefault))),
      child: Row(children: [
        if (_step > 0)
          Expanded(
              child: AppButton(
                  label: 'Kembali',
                  onPressed: _back,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.md)),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
            flex: _step > 0 ? 2 : 1,
            child: _step < 4
                ? AppButton(
                    label: 'Lanjutkan',
                    onPressed: _next,
                    variant: AppButtonVariant.brand,
                    trailingIcon: Icons.arrow_forward_rounded)
                : AppButton(
                    label:
                        widget.property == null ? 'Publikasikan' : 'Perbarui',
                    onPressed: _isLoading ? null : _publish,
                    isLoading: _isLoading,
                    variant: AppButtonVariant.primary,
                    leadingIcon: Icons.publish_rounded)),
      ]),
    );
  }
}
