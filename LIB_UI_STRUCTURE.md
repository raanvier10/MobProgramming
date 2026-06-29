# Struktur File `lib/` dan Keterkaitan dengan Tampilan UI

Dokumen ini membantu menemukan file tampilan yang bertanggung jawab atas layar tertentu dalam aplikasi Flutter.

## Entry Point
- `lib/main.dart`
  - Entry point aplikasi.
- `lib/app.dart`
  - Konfigurasi aplikasi seperti routing, tema, dan injeksi dependensi.

## Core UI
- `lib/core/widgets/`
  - `clay_button.dart` - tombol custom.
  - `clay_feature_card.dart` - kartu fitur tampilan.
  - `property_card.dart` - kartu properti yang digunakan di daftar/matikan.
- `lib/core/theme/`
  - `clay_theme.dart` - pengaturan tema aplikasi.
  - `clay_colors.dart` - warna tema dan palet.
- `lib/core/di/app_injection.dart`
  - Injeksi dependensi (BLoC/Cubit/Repository).
- `lib/core/data/mock_data.dart`
  - Data dummy yang mungkin dipakai di tampilan.

## Fitur dan Halaman UI
Semua tampilan halaman terletak di bawah `lib/features/<fitur>/presentation/pages/`.

### Auth
- `lib/features/auth/presentation/pages/login_page.dart`
  - Tampilan login. Jika ingin memperbaiki tampilan login, edit file ini.
- `lib/features/auth/presentation/pages/register_page.dart`
  - Tampilan pendaftaran.
- `lib/features/auth/presentation/pages/onboarding_page.dart`
  - Tampilan onboarding / selamat datang.

### Home
- `lib/features/home/presentation/pages/home_page.dart`
  - Halaman utama setelah login.
- `lib/features/home/presentation/pages/main_shell.dart`
  - Kerangka utama aplikasi (tab/navigasi shell).

### Booking
- `lib/features/booking/presentation/pages/bookings_page.dart`
  - Tampilan daftar semua booking.
- `lib/features/booking/presentation/pages/booking_page.dart`
  - Tampilan detail booking.

### Chat
- `lib/features/chat/presentation/pages/chat_list_page.dart`
  - Daftar percakapan/chat.
- `lib/features/chat/presentation/pages/chat_room_page.dart`
  - Ruang obrolan / detail chat.

### Favorite
- `lib/features/favorite/presentation/pages/favorites_page.dart`
  - Tampilan daftar favorit.

### Payment
- `lib/features/payment/presentation/pages/payment_page.dart`
  - Tampilan pembayaran.

### Property
- `lib/features/property/presentation/pages/property_detail_page.dart`
  - Halaman detail properti.
- `lib/features/property/presentation/pages/filter_sheet.dart`
  - Panel filter properti.

## Catatan Khusus
- Untuk memperbaiki tampilan login, langsung buka `lib/features/auth/presentation/pages/login_page.dart`.
- Jika ingin menambahkan komponen UI ulang, cek juga file widget di `lib/core/widgets/`.
- Untuk perubahan tema global, edit file di `lib/core/theme/`.

## Tips Penggunaan
1. Cari file yang relevan dengan jenis tampilan di tabel di atas.
2. Buka file tersebut di editor.
3. Perbaiki layout, widget, atau styling di file yang sesuai.
4. Jika perubahan mempengaruhi widget kecil, cek `lib/core/widgets/` untuk komponen bersama.
