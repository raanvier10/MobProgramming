# PRD — Ngekos.in
> **Dokumen ini adalah sumber kebenaran tunggal (single source of truth) untuk AI agent.**
> Baca seluruh dokumen ini sebelum mengerjakan tugas apapun. Jangan berasumsi di luar cakupan yang tertulis di sini.

---

## 1. Ringkasan Produk

**Ngekos.in** adalah aplikasi mobile untuk pencarian dan pengelolaan hunian (kos & kontrakan) di wilayah **Karawang**. Aplikasi ini melayani dua jenis pengguna:

| Peran | Deskripsi |
|---|---|
| **User (Pencari Hunian)** | Mencari, memesan, dan membayar hunian |
| **Admin/Mitra (Pemilik)** | Mendaftarkan, mengelola properti, dan memantau transaksi |

---

## 2. Batasan Lingkup (Scope)

> ⚠️ **AI Agent: Jangan mengerjakan fitur di luar daftar ini tanpa konfirmasi eksplisit dari pengguna.**

### 2.1 Dalam Lingkup (In Scope)

- Autentikasi via Email dan Google OAuth
- Manajemen profil pengguna
- Pencarian & filter properti (wilayah, tipe, harga, fasilitas)
- Peta digital berbasis **Location Based Service (LBS)** dengan GPS
- Halaman detail properti (foto, deskripsi, sisa kamar, lokasi, skema bayar)
- Alur pengajuan sewa (input tanggal masuk + durasi)
- Sistem pembayaran: **Bayar Penuh**, **DP**, **Cicilan**
- Integrasi payment gateway: **Virtual Account (VA)** dan **QRIS**
- Kuitansi digital dan riwayat transaksi
- Dasbor mitra: tambah/edit properti, unggah foto
- Geotagging lokasi properti pada peta
- Konfigurasi opsi pembayaran per properti (DP nominal, maks termin cicilan)
- Kontrol status kamar: Tersedia / Penuh (manual & otomatis)
- Pemantauan transaksi real-time untuk pemilik
- Manajemen penghuni aktif + fitur "Selesai Sewa/Pindah"

### 2.2 Di Luar Lingkup (Out of Scope)

- Fitur chat atau pesan langsung antar pengguna dan pemilik
- Review / rating properti
- Notifikasi push (kecuali dinyatakan di iterasi berikutnya)
- Multi-kota (hanya Karawang)
- Web version (hanya mobile)
- Integrasi dengan platform properti eksternal (OLX, Mamikos, dll.)

---

## 3. Pengguna & Kebutuhan

### 3.1 User — Pencari Hunian

| # | Fitur | Deskripsi |
|---|---|---|
| U1 | Autentikasi & Profil | Registrasi, login (Email/Google), kelola profil |
| U2 | Pencarian & Filter | Cari berdasarkan wilayah, tipe (kos/kontrakan), harga, fasilitas |
| U3 | Peta LBS | Deteksi GPS, tampilkan pin hunian terdekat di peta |
| U4 | Detail Properti | Foto, deskripsi, sisa kamar, lokasi presisi, label skema bayar |
| U5 | Pengajuan Sewa | Form pemesanan: tanggal masuk + durasi sewa |
| U6 | Transaksi Fleksibel | Pilih skema (Bayar Penuh / DP / Cicilan), bayar via VA atau QRIS |
| U7 | Riwayat & Tagihan | Histori transaksi, kuitansi digital, jadwal jatuh tempo |

### 3.2 Admin/Mitra — Pemilik

| # | Fitur | Deskripsi |
|---|---|---|
| A1 | Manajemen Listing | Form upload/edit foto dan deskripsi properti |
| A2 | Geotagging | Tandai koordinat lokasi properti di peta secara presisi |
| A3 | Konfigurasi Pembayaran | Aktifkan DP (input nominal) dan/atau Cicilan (input maks termin) |
| A4 | Kontrol Status Kamar | Ubah status Tersedia/Penuh secara manual atau otomatis pasca-transaksi |
| A5 | Pemantauan Transaksi | Laporan real-time: pembayaran masuk, status tagihan, piutang cicilan |
| A6 | Manajemen Penghuni | Daftar penghuni aktif + nomor kamar + sisa masa sewa; tombol "Selesai Sewa/Pindah" untuk mengosongkan kamar secara otomatis |

---

## 4. Alur Utama (User Flow)

### 4.1 Alur Pencari Hunian

```
Buka App
  └─ Registrasi / Login (Email atau Google)
       └─ Halaman Utama: Peta LBS + Search Bar
            └─ Cari / Filter Properti
                 └─ Halaman Detail Properti
                      └─ Klik "Ajukan Sewa"
                           └─ Input tanggal masuk + durasi
                                └─ Pilih skema bayar (Penuh / DP / Cicilan)
                                     └─ Klik "Lanjutkan Pembayaran"
                                          └─ Tampil VA atau QRIS
                                               └─ Bayar → Kuitansi Digital
                                                    └─ Status: Penghuni Aktif
```

### 4.2 Alur Pemilik

```
Buka App
  └─ Login Akun Mitra
       └─ Dasbor Mitra
            ├─ Tambah Properti
            │    ├─ Isi form (nama, deskripsi, harga, foto)
            │    ├─ Geotagging lokasi di peta
            │    ├─ Atur konfigurasi skema bayar
            │    └─ Publikasikan
            ├─ Pantau Transaksi (real-time)
            └─ Manajemen Penghuni
                 └─ Tombol "Selesai Sewa/Pindah" → kamar otomatis "Tersedia"
```

---

## 5. Persyaratan Teknis

| Aspek | Detail |
|---|---|
| Platform | Mobile (Android & iOS) |
| Koneksi | Membutuhkan koneksi internet aktif |
| Izin Perangkat | GPS / Lokasi, Kamera, Galeri |
| Peta | Location Based Service (LBS) berbasis GPS |
| Payment Gateway | Virtual Account (VA) + QRIS |
| Autentikasi | Email/Password + Google OAuth |
| Geotagging | Koordinat lat/lng untuk setiap properti |
| **Penyimpanan Data** | **In-memory / state management saja — tanpa database apapun** |

### 5.1 Aturan Tanpa Database

> ⛔ **AI Agent: Dilarang keras menggunakan database dalam bentuk apapun.**

- **DILARANG** menggunakan database relasional (MySQL, PostgreSQL, SQLite, dll.)
- **DILARANG** menggunakan database NoSQL (MongoDB, Firebase Firestore, Supabase, dll.)
- **DILARANG** menggunakan ORM, query builder, atau migration tool apapun
- **DILARANG** membuat schema, tabel, koleksi, atau struktur database apapun
- **DILARANG** menggunakan localStorage, sessionStorage, IndexedDB, atau AsyncStorage sebagai pengganti database persisten
- **WAJIB** menyimpan seluruh data dalam **state/memori aplikasi** (contoh: variabel, array, object, useState, Riverpod, Provider, dll.)
- **WAJIB** menggunakan **data dummy/seed hardcoded** sebagai data awal untuk properti, pengguna, dan transaksi
- Data akan **hilang saat aplikasi di-restart** — ini adalah perilaku yang disengaja dan diterima

---

## 6. Aturan Bisnis Kritis

> **AI Agent: Aturan berikut adalah constraint keras. Jangan diubah tanpa persetujuan.**

7. **Tidak ada database** — seluruh data disimpan dalam memori aplikasi menggunakan state management. Data dummy hardcoded wajib disediakan sebagai seed awal. Tidak ada koneksi ke database, server, atau storage persisten apapun.

1. **Skema pembayaran bersifat per-properti** — pemilik yang mengatur aktif/tidaknya DP dan Cicilan untuk tiap properti miliknya.
2. **Status kamar otomatis berubah** menjadi "Penuh" setelah transaksi berhasil, dan kembali "Tersedia" setelah pemilik menekan "Selesai Sewa/Pindah".
3. **Wilayah layanan terbatas di Karawang** — filter pencarian tidak mencakup kota lain.
4. **Data penghuni diarsipkan** (bukan dihapus) ketika pemilik menekan "Selesai Sewa/Pindah".
5. **Pembayaran hanya melalui payment gateway** (VA/QRIS) — tidak ada pembayaran tunai melalui app.
6. **Kuitansi digital otomatis diterbitkan** setelah konfirmasi pembayaran dari payment gateway.

---

## 7. Definisi Status & Terminologi

| Istilah | Definisi |
|---|---|
| **Kos** | Hunian sewa per kamar dengan fasilitas bersama |
| **Kontrakan** | Hunian sewa per unit/rumah |
| **LBS** | Location Based Service — fitur peta yang memanfaatkan GPS pengguna |
| **Geotagging** | Proses menandai koordinat lokasi properti pada peta |
| **VA** | Virtual Account — metode pembayaran transfer bank |
| **QRIS** | QR Code Indonesian Standard — pembayaran via scan QR |
| **DP** | Down Payment — uang muka sewa |
| **Cicilan** | Skema pembayaran bertahap dengan jumlah termin maksimal |
| **Termin** | Jumlah periode cicilan |
| **Penghuni Aktif** | User yang telah berhasil melakukan pembayaran dan terdaftar menghuni |

---

## 8. Panduan untuk AI Agent

> Baca bagian ini sebelum memulai tugas apapun.

- **⛔ Jangan gunakan database dalam bentuk apapun** — lihat Bagian 5.1 untuk daftar lengkap yang dilarang. Gunakan state in-memory dan data dummy hardcoded.
- **Tetap di dalam scope.** Jika ada permintaan fitur yang tidak ada di dokumen ini, tanyakan konfirmasi sebelum mengerjakan.
- **Ikuti alur yang sudah didefinisikan.** Jangan membuat alur alternatif kecuali diminta eksplisit.
- **Gunakan terminologi yang konsisten** sesuai Bagian 7.
- **Jangan ubah aturan bisnis** di Bagian 6 tanpa konfirmasi dari pemilik produk.
- **Dua peran pengguna terpisah** — UI, izin akses, dan alur untuk User dan Admin/Mitra harus dibedakan dengan jelas.
- **Prioritas fitur mengikuti urutan** yang tercantum di Bagian 3 (U1 lebih prioritas dari U7, dst.).
- **Jika ada ambiguitas**, tanyakan klarifikasi sebelum mengerjakan — jangan berasumsi.
