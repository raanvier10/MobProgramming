# Panduan TDD — Ngekos.in

Dokumen ini menjelaskan strategi **Test-Driven Development** pada proyek ini agar user tahu **apa yang diubah** dan **test mana yang harus lulus** setelah setiap perubahan.

## Cara Menjalankan Test

```bash
cd ngekosin
flutter pub get
flutter test
```

Jalankan test spesifik:

```bash
# Semua unit test repository
flutter test test/unit/

# Semua bloc test
flutter test test/bloc/

# Semua widget test
flutter test test/widget/

# Satu file (contoh setelah ubah auth)
flutter test test/unit/auth_repository_test.dart
```

## Peta Test → Fitur PRD

| ID PRD | Fitur | File Test | Apa yang Diverifikasi |
|--------|-------|-----------|----------------------|
| FR-01 | Registrasi & Login | `test/unit/auth_repository_test.dart` | Login, register, Google, JWT storage, logout |
| FR-01 | Auth UI/State | `test/bloc/auth_cubit_test.dart`, `test/widget/login_test.dart` | State BLoC, form login, copywriting "user" |
| FR-02 | Pencarian Properti | `test/unit/property_repository_test.dart` | Keyword lokasi/kampus |
| FR-03 | Filter Spesifik | `test/unit/property_repository_test.dart` | Harga, jenis kamar, fasilitas |
| FR-04 | Detail Hunian | `test/unit/property_repository_test.dart` | Galeri, ulasan, getById |
| FR-05 | Favorit | `test/unit/favorite_repository_test.dart`, `test/bloc/favorite_cubit_test.dart` | Toggle wishlist |
| FR-06 | Booking | `test/unit/booking_repository_test.dart`, `test/bloc/booking_cubit_test.dart` | Form, durasi, total harga |
| FR-07 | Pembayaran | `test/unit/payment_repository_test.dart`, `test/bloc/payment_cubit_test.dart` | Metode bayar, referensi |
| FR-08 | Chat | `test/unit/chat_repository_test.dart`, `test/bloc/chat_cubit_test.dart` | Percakapan, kirim pesan |
| Design | Clay Theme | `test/widget/onboarding_test.dart` | Feature cards, branding |
| App | Smoke | `test/widget_test.dart` | App boot |

## Workflow TDD Saat Mengubah Kode

### 1. Ubah test DULU (Red)
Contoh: user ingin menambah filter "Parkir Motor"

```dart
// test/unit/property_repository_test.dart — tambahkan:
test('filter fasilitas Parkir Motor', () async {
  final result = await repository.getProperties(
    filter: const PropertyFilter(facilities: ['Parkir Motor']),
  );
  expect(result.every((p) => p.facilities.contains('Parkir Motor')), isTrue);
});
```

Jalankan → test **GAGAL** (merah).

### 2. Implementasi (Green)
Ubah `PropertyRepositoryImpl`, `FilterSheet`, mock data → jalankan test lagi sampai **LULUS**.

### 3. Refactor (bila perlu)
Bersihkan kode tanpa mengubah perilaku. Test tetap hijau = aman.

## Apa yang Harus Diupdate Saat Mengubah Layer

| Layer yang Diubah | Test yang Wajib Dijalankan |
|-------------------|---------------------------|
| `domain/entities/` | Unit test entity + bloc test terkait |
| `data/repositories/` | `test/unit/*_repository_test.dart` |
| `presentation/cubit/` | `test/bloc/*_cubit_test.dart` |
| `presentation/pages/` | `test/widget/*_test.dart` |
| `core/theme/` | `test/widget/onboarding_test.dart` + smoke test |

## Konvensi Penamaan Test

```
group('NamaRepository — FR-XX', () { ... });  // unit
blocTest<XCubit, XState>('aksi emit state', ...);  // bloc
testWidgets('Halaman menampilkan ...', ...);  // widget
```

## Changelog Test (Baseline v1.0)

| Tanggal | Perubahan | Test Baru/Diubah |
|---------|-----------|------------------|
| 2026-06-11 | Initial MVP semua FR-01 s/d FR-08 | 16 file test, 40+ assertions |

> **Tip:** Setiap kali user mengubah fitur, tambahkan baris di tabel Changelog di atas dan commit bersama kode agar riwayat perubahan terlacak.
