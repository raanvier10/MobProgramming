import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/seed_data.dart';

/// AppState — In-memory state management (no database)
/// Singleton instance diakses via Provider atau langsung
class AppState extends ChangeNotifier {
  // ── Auth ─────────────────────────────────────────────────────
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isMitra => _currentUser?.role == UserRole.mitra;

  // ── Data Lists (in-memory) ────────────────────────────────────
  List<AppUser> _users = List.from(SeedData.users);
  List<Property> _properties = List.from(SeedData.properties);
  List<AppTransaction> _transactions = List.from(SeedData.transactions);
  List<Tenant> _tenants = List.from(SeedData.tenants);

  List<Property> get allProperties => _properties;
  List<AppTransaction> get allTransactions => _transactions;
  List<Tenant> get allTenants => _tenants;

  // ── Draft management ──────────────────────────────────────────
  PropertyDraft? _currentDraft;
  PropertyDraft? get currentDraft => _currentDraft;

  void saveDraft(PropertyDraft draft) {
    _currentDraft = draft;
    // Don't notifyListeners — draft is local to form
  }

  void clearDraft() {
    _currentDraft = null;
  }

  // ── User's own data ───────────────────────────────────────────
  List<AppTransaction> get myTransactions =>
      _transactions.where((t) => t.userId == _currentUser?.id).toList();

  List<Tenant> get myTenancies =>
      _tenants.where((t) => t.userId == _currentUser?.id && t.isActive).toList();

  // ── Mitra's data ──────────────────────────────────────────────
  List<Property> get mitraProperties =>
      _properties.where((p) => p.ownerId == _currentUser?.id).toList();

  List<AppTransaction> get mitraTransactions =>
      _transactions.where((t) => t.ownerId == _currentUser?.id).toList();

  List<Tenant> get mitraTenants =>
      _tenants.where((t) =>
          mitraProperties.any((p) => p.id == t.propertyId) && t.isActive).toList();

  List<Tenant> get mitraArchivedTenants =>
      _tenants.where((t) =>
          mitraProperties.any((p) => p.id == t.propertyId) && !t.isActive).toList();

  // ── Mitra Statistics ──────────────────────────────────────────
  double get mitraTotalRevenue =>
      mitraTransactions
          .where((t) => t.status == TransactionStatus.lunas)
          .fold(0.0, (sum, t) => sum + t.totalAmount);

  double get mitraPendingRevenue =>
      mitraTransactions
          .where((t) => t.status == TransactionStatus.pending)
          .fold(0.0, (sum, t) => sum + t.totalAmount);

  double get mitraCicilanPiutang =>
      mitraTransactions
          .where((t) => t.status == TransactionStatus.cicilan)
          .fold(0.0, (sum, t) {
        final remaining = (t.totalTermin ?? 0) - (t.paidTermin ?? 0);
        return sum + (t.amountPerTermin ?? 0) * remaining;
      });

  int get mitraAvailableRooms =>
      mitraProperties.where((p) => p.status == RoomStatus.tersedia).length;

  int get mitraFullRooms =>
      mitraProperties.where((p) => p.status == RoomStatus.penuh).length;

  /// Get tenants for a specific property
  List<Tenant> tenantsForProperty(String propertyId) =>
      _tenants.where((t) => t.propertyId == propertyId && t.isActive).toList();

  /// Get transactions for a specific property
  List<AppTransaction> transactionsForProperty(String propertyId) =>
      _transactions.where((t) => t.propertyId == propertyId).toList();

  /// Check if property has active transactions (pending or cicilan)
  bool hasActiveTransactions(String propertyId) =>
      _transactions.any((t) =>
          t.propertyId == propertyId &&
          (t.status == TransactionStatus.pending ||
              t.status == TransactionStatus.cicilan));

  // ── Auth Actions ──────────────────────────────────────────────
  bool login(String email, String password) {
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool register(String name, String email, String phone, String password) {
    final exists = _users.any((u) => u.email == email);
    if (exists) return false;
    final newUser = AppUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: UserRole.user,
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile(String name, String phone, {String? avatarUrl}) {
    if (_currentUser == null) return;
    final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      _users[idx] = _currentUser!.copyWith(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
      );
      _currentUser = _users[idx];
      notifyListeners();
    }
  }

  // ── Property Actions ──────────────────────────────────────────
  void addProperty(Property property) {
    _properties.add(property);
    clearDraft();
    notifyListeners();
  }

  void updateProperty(Property updated) {
    final idx = _properties.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _properties[idx] = updated;
      notifyListeners();
    }
  }

  void setRoomStatus(String propertyId, RoomStatus status) {
    final idx = _properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      _properties[idx] = _properties[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  // ── Transaction Actions ───────────────────────────────────────
  AppTransaction createTransaction({
    required Property property,
    required DateTime checkInDate,
    required int durationMonths,
    required PaymentScheme scheme,
    required PaymentMethod method,
  }) {
    if (_currentUser == null) throw Exception('Not logged in');

    // Set intermediate "diproses" status to prevent race conditions
    setRoomStatus(property.id, RoomStatus.diproses);

    final totalAmount = property.pricePerMonth * durationMonths;
    double? dpAmount;
    int? totalTermin;
    double? amountPerTermin;

    if (scheme == PaymentScheme.dp) {
      dpAmount = property.dpAmount;
      totalTermin = 2; // DP dianggap 2 termin: DP & Pelunasan
      amountPerTermin = dpAmount; // Simpan nominal DP ke amountPerTermin untuk dicatat di kuitansi
    } else if (scheme == PaymentScheme.cicilan) {
      totalTermin = property.maxTermin;
      amountPerTermin = totalAmount / property.maxTermin;
    }

    final vaNumber =
        '8277${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 12)}';

    final trx = AppTransaction(
      id: 'trx-${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      propertyId: property.id,
      propertyName: property.name,
      ownerId: property.ownerId,
      checkInDate: checkInDate,
      durationMonths: durationMonths,
      totalAmount: totalAmount,
      scheme: scheme,
      method: method,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      vaNumber: vaNumber,
      totalTermin: totalTermin,
      paidTermin: (scheme == PaymentScheme.cicilan || scheme == PaymentScheme.dp) ? 0 : null,
      amountPerTermin: amountPerTermin,
    );

    _transactions.add(trx);

    // Auto status kamar → Penuh
    setRoomStatus(property.id, RoomStatus.penuh);

    // Add tenant
    final tenant = Tenant(
      id: 'ten-${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      userPhone: _currentUser!.phone,
      propertyId: property.id,
      propertyName: property.name,
      roomNumber: 'A-${((_tenants.length + 1)).toString().padLeft(2, '0')}',
      checkInDate: checkInDate,
      durationMonths: durationMonths,
      transactionId: trx.id,
    );
    _tenants.add(tenant);

    notifyListeners();
    return trx;
  }

  void confirmPayment(String transactionId) {
    final idx = _transactions.indexWhere((t) => t.id == transactionId);
    if (idx != -1) {
      final t = _transactions[idx];
      if (t.scheme == PaymentScheme.cicilan || t.scheme == PaymentScheme.dp) {
        t.status = TransactionStatus.cicilan;
        t.paidTermin = 1; // Bayaran pertama (DP / Termin 1) masuk
      } else {
        t.status = TransactionStatus.lunas;
      }
      notifyListeners();
    }
  }

  void payInstallment(String transactionId) {
    final idx = _transactions.indexWhere((t) => t.id == transactionId);
    if (idx != -1) {
      final t = _transactions[idx];
      if (t.paidTermin != null && t.totalTermin != null) {
        t.paidTermin = t.paidTermin! + 1;
        if (t.paidTermin! >= t.totalTermin!) {
          t.status = TransactionStatus.lunas;
        }
      }
      notifyListeners();
    }
  }

  // ── Tenant Actions ────────────────────────────────────────────
  void selesaiSewa(String tenantId) {
    final idx = _tenants.indexWhere((t) => t.id == tenantId);
    if (idx != -1) {
      _tenants[idx].isActive = false;
      _tenants[idx].archivedDate = DateTime.now(); // Archive date
      // Auto status kamar → Tersedia
      setRoomStatus(_tenants[idx].propertyId, RoomStatus.tersedia);
      notifyListeners();
    }
  }

  // ── Search & Filter ───────────────────────────────────────────
  List<Property> searchProperties({
    String? query,
    PropertyType? type,
    RoomGender? gender,
    String? area,
    double? maxPrice,
    RoomStatus? status,
    List<String>? facilities,
  }) {
    return _properties.where((p) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.area.toLowerCase().contains(q) &&
            !p.fullAddress.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (type != null && p.type != type) return false;
      if (gender != null && p.roomGender != gender) return false;
      if (area != null && area.isNotEmpty && p.area != area) return false;
      if (maxPrice != null && p.pricePerMonth > maxPrice) return false;
      if (status != null && p.status != status) return false;
      if (facilities != null && facilities.isNotEmpty) {
        final hasAll = facilities.every((f) => p.facilities.contains(f));
        if (!hasAll) return false;
      }
      return true;
    }).toList();
  }

  List<String> get karawangAreas => [
    'Karawang Kota',
    'Karawang Baru',
    'Cikampek',
    'Teluk Jambe',
    'Rengasdengklok',
    'Ciampel',
    'Purwasari',
    'Klari',
  ];
}
