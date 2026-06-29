// ============================================================
// MODELS — Ngekos.in (In-Memory, no database)
// ============================================================

enum UserRole { user, mitra }

enum PropertyType { kos, kontrakan }

enum RoomGender { male, female, mixed }

enum RoomStatus { tersedia, penuh, diproses }

enum PaymentScheme { penuh, dp, cicilan }

enum PaymentMethod { va, qris }

enum TransactionStatus { pending, lunas, cicilan }

// ── User ────────────────────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password; // plain text for demo
  final UserRole role;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      password: password,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// ── Property ────────────────────────────────────────────────
class Property {
  final String id;
  String name;
  String description;
  PropertyType type;
  RoomGender roomGender;
  RoomStatus status;
  double pricePerMonth;
  List<String> imageUrls;
  List<String> facilities;
  String area; // Wilayah Karawang
  String fullAddress;
  double latitude;
  double longitude;
  String ownerId;
  String ownerName;
  // Payment config
  bool isDpEnabled;
  double dpAmount;
  bool isCicilanEnabled;
  int maxTermin;

  Property({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.roomGender,
    required this.status,
    required this.pricePerMonth,
    required this.imageUrls,
    required this.facilities,
    required this.area,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.ownerId,
    required this.ownerName,
    this.isDpEnabled = false,
    this.dpAmount = 0,
    this.isCicilanEnabled = false,
    this.maxTermin = 3,
  });

  Property copyWith({
    String? name,
    String? description,
    PropertyType? type,
    RoomGender? roomGender,
    RoomStatus? status,
    double? pricePerMonth,
    List<String>? imageUrls,
    List<String>? facilities,
    String? area,
    String? fullAddress,
    double? latitude,
    double? longitude,
    bool? isDpEnabled,
    double? dpAmount,
    bool? isCicilanEnabled,
    int? maxTermin,
  }) {
    return Property(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      roomGender: roomGender ?? this.roomGender,
      status: status ?? this.status,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      imageUrls: imageUrls ?? this.imageUrls,
      facilities: facilities ?? this.facilities,
      area: area ?? this.area,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId,
      ownerName: ownerName,
      isDpEnabled: isDpEnabled ?? this.isDpEnabled,
      dpAmount: dpAmount ?? this.dpAmount,
      isCicilanEnabled: isCicilanEnabled ?? this.isCicilanEnabled,
      maxTermin: maxTermin ?? this.maxTermin,
    );
  }
}

// ── Transaction ─────────────────────────────────────────────
class AppTransaction {
  final String id;
  final String userId;
  final String userName;
  final String propertyId;
  final String propertyName;
  final String ownerId;
  final DateTime checkInDate;
  final int durationMonths;
  final double totalAmount;
  final PaymentScheme scheme;
  final PaymentMethod method;
  TransactionStatus status;
  final DateTime createdAt;
  // For cicilan
  final int? totalTermin;
  int? paidTermin;
  double? amountPerTermin;
  // VA / QRIS
  final String vaNumber;

  AppTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.propertyId,
    required this.propertyName,
    required this.ownerId,
    required this.checkInDate,
    required this.durationMonths,
    required this.totalAmount,
    required this.scheme,
    required this.method,
    required this.status,
    required this.createdAt,
    required this.vaNumber,
    this.totalTermin,
    this.paidTermin,
    this.amountPerTermin,
  });
}

// ── Tenant (Penghuni Aktif) ──────────────────────────────────
class Tenant {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String propertyId;
  final String propertyName;
  final String roomNumber;
  final DateTime checkInDate;
  final int durationMonths;
  final String transactionId;
  bool isActive;
  DateTime? archivedDate; // Tanggal diarsipkan (Selesai Sewa/Pindah)

  Tenant({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.propertyId,
    required this.propertyName,
    required this.roomNumber,
    required this.checkInDate,
    required this.durationMonths,
    required this.transactionId,
    this.isActive = true,
    this.archivedDate,
  });

  DateTime get checkOutDate =>
      DateTime(checkInDate.year, checkInDate.month + durationMonths, checkInDate.day);

  int get remainingDays => checkOutDate.difference(DateTime.now()).inDays;
}

// ── PropertyDraft (Autosave progress form) ────────────────────
class PropertyDraft {
  String? name;
  String? description;
  PropertyType type;
  RoomGender gender;
  double? pricePerMonth;
  List<String> facilities;
  String? area;
  String? fullAddress;
  double? latitude;
  double? longitude;
  List<String> imageUrls;
  bool isDpEnabled;
  double? dpAmount;
  bool isCicilanEnabled;
  int? maxTermin;
  int currentStep; // 0-based step index

  PropertyDraft({
    this.name,
    this.description,
    this.type = PropertyType.kos,
    this.gender = RoomGender.mixed,
    this.pricePerMonth,
    this.facilities = const [],
    this.area,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.isDpEnabled = false,
    this.dpAmount,
    this.isCicilanEnabled = false,
    this.maxTermin,
    this.currentStep = 0,
  });
}
