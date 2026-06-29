# Ngekos.in

Aplikasi mobile pencarian hunian untuk calon penghuni — dibangun dengan **Flutter**, **Clean Architecture**, **BLoC/Cubit**, dan desain **Clay** (cream canvas, saturated feature cards).

## Fitur MVP (sesuai PRD)

- **FR-01** Registrasi & Login (email + Google Sign-In mock)
- **FR-02** Pencarian properti berdasarkan lokasi/kampus
- **FR-03** Filter harga, jenis kamar, fasilitas
- **FR-04** Detail hunian (galeri, ulasan, aturan)
- **FR-05** Favorit / wishlist
- **FR-06** Pengajuan booking
- **FR-07** Pembayaran (transfer, e-wallet, retail — mock gateway)
- **FR-08** Chat internal dengan pengelola

## Struktur Proyek

```
lib/
├── core/           # Theme Clay, DI, widgets
├── features/
│   ├── auth/
│   ├── property/
│   ├── favorite/
│   ├── booking/
│   ├── payment/
│   ├── chat/
│   └── home/
└── app.dart
```

## Menjalankan Aplikasi

```bash
cd ngekosin
flutter pub get
flutter run
```

## TDD

Lihat **[TDD_GUIDE.md](TDD_GUIDE.md)** untuk peta test per fitur dan workflow Red-Green-Refactor.

```bash
flutter test
```

## Akun Demo

Login dengan email apa saja + password minimal 6 karakter, atau gunakan **Masuk dengan Google**.
