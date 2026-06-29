# DESIGN.md — Ngekos.in Design System
> **Dokumen ini adalah panduan desain resmi Ngekos.in.**
> AI agent wajib membaca seluruh dokumen ini sebelum membuat komponen UI, layar, atau aset visual apapun. Semua keputusan visual harus mengacu ke sini.

---

## 1. Filosofi Desain

Ngekos.in adalah aplikasi hunian untuk masyarakat Karawang. Desain harus terasa:

- **Terpercaya** — pengguna menyerahkan uang sewa, UI harus memberi rasa aman
- **Ramah** — bukan korporat, tapi juga tidak murahan
- **Lokal** — terasa relevan untuk pengguna Indonesia, bukan clone asing
- **Efisien** — pencarian dan booking harus bisa dilakukan dalam hitungan tap

---

## 2. Tipografi

### 2.1 Font Family

| Peran | Font | Digunakan untuk |
|---|---|---|
| **Display / Heading** | TT Commons Pro | Judul halaman, nama properti, angka besar, hero text |
| **UI / Body** | Plus Jakarta Sans | Label, deskripsi, tombol, input, navigasi, semua teks umum |
| **Fallback** | system-ui, sans-serif | Jika kedua font gagal dimuat |

```css
/* Import */
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap');
/* TT Commons Pro diimport via CDN atau lokal sesuai lisensi */

/* CSS Variables */
--font-display: 'TT Commons Pro', system-ui, sans-serif;
--font-body:    'Plus Jakarta Sans', system-ui, sans-serif;
```

### 2.2 Type Scale

| Token | Size | Weight | Line Height | Font | Digunakan untuk |
|---|---|---|---|---|---|
| `--text-display-xl` | 32px | 700 | 1.2 | TT Commons Pro | Hero / splash screen |
| `--text-display-lg` | 28px | 700 | 1.25 | TT Commons Pro | Judul halaman utama |
| `--text-display-md` | 24px | 600 | 1.3 | TT Commons Pro | Judul seksi, nama properti |
| `--text-display-sm` | 20px | 600 | 1.35 | TT Commons Pro | Sub-judul, harga besar |
| `--text-body-lg` | 16px | 400 | 1.6 | Plus Jakarta Sans | Deskripsi panjang |
| `--text-body-md` | 14px | 400 | 1.6 | Plus Jakarta Sans | Body text standar |
| `--text-body-sm` | 13px | 400 | 1.5 | Plus Jakarta Sans | Teks pendukung, caption |
| `--text-label-lg` | 14px | 600 | 1.4 | Plus Jakarta Sans | Label form, tombol besar |
| `--text-label-md` | 13px | 600 | 1.4 | Plus Jakarta Sans | Tombol kecil, badge, tab |
| `--text-label-sm` | 11px | 500 | 1.3 | Plus Jakarta Sans | Micro label, timestamp |

### 2.3 Aturan Tipografi

- **Heading selalu TT Commons Pro**, body & UI selalu Plus Jakarta Sans
- **Jangan mix weight sembarangan** — gunakan hanya 400, 500, 600, 700
- **Harga properti** → TT Commons Pro 600–700, warna `--color-primary`
- **Teks di atas warna gelap** → selalu putih `#FFFFFF`
- **Teks di atas background terang** → gunakan token warna teks (lihat Bagian 3.3)
- Jangan gunakan italic kecuali untuk placeholder input
- Letter-spacing heading: `-0.02em` untuk display besar

---

## 3. Warna

### 3.1 Palet Utama

#### Primary — Navy Blue (Kepercayaan & Profesionalisme)
```
--color-primary-50:  #EEF2FF
--color-primary-100: #E0E7FF
--color-primary-200: #C7D2FE
--color-primary-300: #A5B4FC
--color-primary-400: #818CF8
--color-primary-500: #4F46E5   ← Base brand color (indigo-navy)
--color-primary-600: #3730A3
--color-primary-700: #312E81
--color-primary-800: #1E1B4B
--color-primary-900: #0F0E2E   ← Terdalam, untuk teks di dark bg
```

#### Accent — Amber Orange (Aksi & Kehangatan)
```
--color-accent-50:  #FFFBEB
--color-accent-100: #FEF3C7
--color-accent-200: #FDE68A
--color-accent-300: #FCD34D
--color-accent-400: #FBBF24
--color-accent-500: #F59E0B   ← Base accent (CTA, highlight)
--color-accent-600: #D97706
--color-accent-700: #B45309
--color-accent-800: #92400E
--color-accent-900: #78350F
```

#### Neutral — Warm Gray
```
--color-neutral-0:   #FFFFFF
--color-neutral-50:  #F8F7F4   ← Background halaman
--color-neutral-100: #F1EFE9
--color-neutral-200: #E4E1D8
--color-neutral-300: #C9C5B9
--color-neutral-400: #9E9A8E
--color-neutral-500: #78746A
--color-neutral-600: #57534A
--color-neutral-700: #44403C
--color-neutral-800: #292524
--color-neutral-900: #1C1917
```

### 3.2 Warna Semantik

```
/* Success */
--color-success-50:  #F0FDF4
--color-success-500: #22C55E
--color-success-700: #15803D

/* Warning */
--color-warning-50:  #FFFBEB
--color-warning-500: #F59E0B
--color-warning-700: #B45309

/* Danger / Error */
--color-danger-50:  #FEF2F2
--color-danger-500: #EF4444
--color-danger-700: #B91C1C

/* Info */
--color-info-50:  #EFF6FF
--color-info-500: #3B82F6
--color-info-700: #1D4ED8
```

### 3.3 Token Warna Teks

```
--color-text-primary:    #1C1917   /* Heading, teks utama */
--color-text-secondary:  #57534A   /* Deskripsi, label */
--color-text-tertiary:   #9E9A8E   /* Placeholder, timestamp */
--color-text-disabled:   #C9C5B9   /* Input disabled */
--color-text-inverse:    #FFFFFF   /* Teks di atas bg gelap */
--color-text-accent:     #D97706   /* Link, teks aksi */
--color-text-primary-brand: #4F46E5 /* Teks warna brand */
```

### 3.4 Token Warna Background

```
--color-bg-page:       #F8F7F4   /* Background seluruh halaman */
--color-bg-surface:    #FFFFFF   /* Card, modal, bottom sheet */
--color-bg-elevated:   #FFFFFF   /* Floating elements */
--color-bg-muted:      #F1EFE9   /* Input field, chips non-aktif */
--color-bg-overlay:    rgba(15, 14, 46, 0.5)  /* Overlay modal/drawer */
```

### 3.5 Token Warna Border

```
--color-border-default:  #E4E1D8   /* Border card, divider */
--color-border-strong:   #C9C5B9   /* Border input aktif */
--color-border-focus:    #4F46E5   /* Focus ring */
--color-border-danger:   #EF4444   /* Input error */
```

### 3.6 Aturan Penggunaan Warna

- **CTA utama (Bayar, Ajukan Sewa, Publikasikan)** → `--color-accent-500` bg, teks putih
- **Aksi primer sekunder (Lihat Detail, Tambah)** → `--color-primary-500` bg, teks putih
- **Aksi ghost / outline** → border `--color-primary-500`, teks `--color-primary-500`, bg transparan
- **Status Tersedia** → `--color-success-500`
- **Status Penuh** → `--color-danger-500`
- **Badge DP / Cicilan** → `--color-accent-100` bg, `--color-accent-800` teks
- **Badge Bayar Penuh** → `--color-primary-100` bg, `--color-primary-700` teks
- **Harga per bulan** → `--color-primary-500`, TT Commons Pro 600
- Jangan gunakan warna primer dan aksen bersamaan pada satu tombol

---

## 4. Tombol (Button)

### 4.1 Varian Tombol

#### Primary (CTA Utama)
```
background:    --color-accent-500  (#F59E0B)
color:         #FFFFFF
border:        none
border-radius: 12px
padding:       14px 24px
font:          Plus Jakarta Sans 600 14px
```
Digunakan: "Ajukan Sewa", "Lanjutkan Pembayaran", "Publikasikan"

#### Brand (Aksi Penting Non-CTA)
```
background:    --color-primary-500  (#4F46E5)
color:         #FFFFFF
border:        none
border-radius: 12px
padding:       14px 24px
font:          Plus Jakarta Sans 600 14px
```
Digunakan: "Login", "Daftar", "Tambah Properti"

#### Outline
```
background:    transparent
color:         --color-primary-500
border:        1.5px solid --color-primary-500
border-radius: 12px
padding:       13px 24px
font:          Plus Jakarta Sans 600 14px
```
Digunakan: "Batal", "Kembali", aksi sekunder

#### Ghost / Text Button
```
background:    transparent
color:         --color-primary-500
border:        none
padding:       8px 12px
font:          Plus Jakarta Sans 600 14px
```
Digunakan: "Lihat Semua", "Lewati", link dalam teks

#### Danger
```
background:    --color-danger-500
color:         #FFFFFF
border:        none
border-radius: 12px
padding:       14px 24px
font:          Plus Jakarta Sans 600 14px
```
Digunakan: "Selesai Sewa/Pindah", "Hapus Properti"

### 4.2 Ukuran Tombol

| Ukuran | Height | Padding H | Font Size | Digunakan |
|---|---|---|---|---|
| `lg` | 52px | 28px | 16px | CTA utama full-width |
| `md` | 44px | 24px | 14px | Tombol standar |
| `sm` | 36px | 16px | 13px | Tombol dalam card, chip |
| `xs` | 28px | 12px | 12px | Badge interaktif, micro action |

### 4.3 State Tombol

```
Default:   opacity 1, scale 1
Hover:     opacity 0.92
Active:    scale 0.97, opacity 0.88
Disabled:  opacity 0.4, cursor not-allowed
Loading:   opacity 0.7, tampilkan spinner 16px
```

### 4.4 Aturan Tombol

- Full-width untuk CTA di halaman (bukan dalam card kecil)
- Selalu ada icon kiri atau kanan untuk aksi navigasi (chevron, arrow)
- Tombol loading tidak boleh di-tap ulang
- Maksimal 2 tombol per layar pada level yang sama
- Tombol Danger wajib ada konfirmasi dialog sebelum eksekusi

---

## 5. Input & Form

### 5.1 Text Input

```
height:           48px
background:       --color-bg-muted   (#F1EFE9)
border:           1.5px solid transparent
border-radius:    10px
padding:          0 16px
font:             Plus Jakarta Sans 400 14px
color:            --color-text-primary

/* States */
:focus            border-color: --color-border-focus (#4F46E5)
                  background: #FFFFFF
                  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.12)
:error            border-color: --color-border-danger
                  background: --color-danger-50
:disabled         opacity: 0.5, cursor: not-allowed
```

### 5.2 Label & Helper Text

```
Label:       Plus Jakarta Sans 600 13px, --color-text-secondary, margin-bottom 6px
Placeholder: Plus Jakarta Sans 400 14px, --color-text-tertiary (italic)
Helper:      Plus Jakarta Sans 400 12px, --color-text-tertiary, margin-top 4px
Error msg:   Plus Jakarta Sans 400 12px, --color-danger-700, margin-top 4px
```

### 5.3 Dropdown / Select

- Tampilan sama dengan text input
- Icon chevron-down di kanan (16px, `--color-text-tertiary`)
- Saat terbuka: border `--color-border-focus`, shadow ringan

### 5.4 Toggle / Switch

```
Width: 48px, Height: 28px
Track OFF:  --color-neutral-300
Track ON:   --color-primary-500
Thumb:      #FFFFFF, 22px circle, shadow ringan
Transition: 200ms ease
```

### 5.5 Checkbox & Radio

```
Size:        20px × 20px
Border:      1.5px solid --color-border-strong
Radius:      checkbox → 5px | radio → 50%
Checked bg:  --color-primary-500
Check icon:  #FFFFFF, 12px
```

### 5.6 Date Picker & Durasi

- Gunakan native date picker mobile
- Durasi sewa: stepper (+/-) dengan nilai min 1 bulan
- Tampilkan ringkasan "X bulan = tanggal mulai → tanggal selesai"

---

## 6. Card

### 6.1 Card Properti (List)

```
background:    #FFFFFF
border-radius: 16px
border:        1px solid --color-border-default
padding:       0   (foto full-width di atas, konten di bawah)
shadow:        0 2px 8px rgba(28, 25, 23, 0.06)

Foto:          aspect-ratio 16/9, border-radius 16px 16px 0 0, object-fit cover
Konten:        padding 12px 14px 14px
Nama:          TT Commons Pro 600 16px, --color-text-primary
Lokasi:        Plus Jakarta Sans 400 13px, --color-text-tertiary, icon ti-map-pin 12px
Harga:         TT Commons Pro 700 18px, --color-primary-500
Per bulan:     Plus Jakarta Sans 400 12px, --color-text-tertiary
Badge status:  pojok kanan atas foto, lihat Bagian 6.4
```

### 6.2 Card Properti (Detail)

- Foto: carousel horizontal, indicator dot
- Section: Info Umum, Fasilitas, Lokasi (peta mini), Skema Pembayaran
- Setiap section dipisah divider `--color-border-default` 1px

### 6.3 Card Transaksi

```
background:    #FFFFFF
border-radius: 12px
border-left:   3px solid (warna sesuai status)
padding:       14px 16px

Status Lunas:   border-left --color-success-500
Status Pending: border-left --color-warning-500
Status Cicilan: border-left --color-info-500
```

### 6.4 Badge Status

| Status | Background | Teks | Label |
|---|---|---|---|
| Tersedia | `--color-success-50` | `--color-success-700` | ● Tersedia |
| Penuh | `--color-danger-50` | `--color-danger-700` | ● Penuh |
| Bayar Penuh | `--color-primary-100` | `--color-primary-700` | Bayar Penuh |
| DP | `--color-accent-100` | `--color-accent-800` | Bisa DP |
| Cicilan | `--color-info-50` | `--color-info-700` | Bisa Cicil |
| Pending | `--color-warning-50` | `--color-warning-700` | Menunggu Bayar |
| Aktif | `--color-success-50` | `--color-success-700` | Aktif |

```
Badge umum:
border-radius: 20px
padding:       3px 10px
font:          Plus Jakarta Sans 600 11px
```

---

## 7. Navigasi

### 7.1 Bottom Navigation Bar (User)

```
height:          64px + safe area bottom
background:      #FFFFFF
border-top:      1px solid --color-border-default
padding:         8px 0

Tab items: 4 item
  - Beranda    (icon: ti-home)
  - Jelajahi   (icon: ti-map-2)
  - Riwayat    (icon: ti-receipt)
  - Profil     (icon: ti-user)

Tab aktif:   icon + label --color-primary-500, font 600
Tab nonaktif: icon + label --color-neutral-400, font 400
Label:       Plus Jakarta Sans 500 10px, margin-top 2px
Icon size:   22px
```

### 7.2 Bottom Navigation Bar (Mitra/Admin)

```
Tab items: 4 item
  - Dasbor     (icon: ti-layout-dashboard)
  - Properti   (icon: ti-building)
  - Penghuni   (icon: ti-users)
  - Transaksi  (icon: ti-chart-bar)
```

### 7.3 Top App Bar

```
height:       56px
background:   #FFFFFF
border-bottom: 1px solid --color-border-default
padding:      0 16px

Elemen:
  Kiri:   Tombol back (ti-arrow-left, 24px) atau logo
  Tengah: TT Commons Pro 600 17px, --color-text-primary
  Kanan:  Aksi opsional (ti-bell, ti-search, ti-dots-vertical)
```

### 7.4 Search Bar

```
height:           44px
background:       --color-bg-muted
border-radius:    22px (pill)
padding:          0 16px 0 40px
icon kiri:        ti-search, 18px, --color-text-tertiary, posisi abs kiri 14px
font:             Plus Jakarta Sans 400 14px
```

---

## 8. Icon

### 8.1 Library

Gunakan **Tabler Icons** (outline) secara konsisten di seluruh aplikasi.
Referensi: https://tabler.io/icons

### 8.2 Ukuran Icon

| Konteks | Ukuran |
|---|---|
| Bottom nav | 22px |
| Top bar action | 24px |
| Inline dalam teks | 16px |
| Dalam tombol | 18px |
| Card / list item | 20px |
| Hero / ilustrasi | 32–48px |

### 8.3 Daftar Icon Utama per Fitur

| Fitur | Icon |
|---|---|
| Beranda | `ti-home` |
| Cari / Jelajahi | `ti-search`, `ti-map-2` |
| Properti | `ti-building` |
| Kamar Kos | `ti-door` |
| Kontrakan | `ti-home-2` |
| Lokasi / Map | `ti-map-pin`, `ti-map` |
| Harga / Uang | `ti-currency-rupiah` |
| Pembayaran | `ti-credit-card` |
| DP | `ti-cash` |
| Cicilan | `ti-calendar-due` |
| QRIS | `ti-qrcode` |
| Virtual Account | `ti-building-bank` |
| Riwayat | `ti-receipt` |
| Kuitansi | `ti-file-invoice` |
| Penghuni | `ti-users` |
| Profil | `ti-user` |
| Pengaturan | `ti-settings` |
| Foto / Kamera | `ti-camera`, `ti-photo` |
| Upload | `ti-upload` |
| Fasilitas WiFi | `ti-wifi` |
| Fasilitas Parkir | `ti-car` |
| Fasilitas AC | `ti-air-conditioning` |
| Fasilitas Dapur | `ti-tool-kitchen-2` |
| Status Tersedia | `ti-circle-check` |
| Status Penuh | `ti-circle-x` |
| Notifikasi | `ti-bell` |
| Keluar | `ti-logout` |
| Tambah | `ti-plus` |
| Edit | `ti-pencil` |
| Hapus | `ti-trash` |
| Publikasikan | `ti-world-upload` |
| Dasbor | `ti-layout-dashboard` |
| Laporan | `ti-chart-bar` |
| Filter | `ti-adjustments-horizontal` |

### 8.4 Aturan Icon

- **Selalu outline**, jangan gunakan filled variant
- Warna icon mengikuti konteks teks di sekitarnya kecuali ditetapkan khusus
- Icon dekoratif wajib `aria-hidden="true"`
- Icon fungsional wajib `aria-label` yang deskriptif
- Jangan campur icon dari library berbeda

---

## 9. Spacing & Layout

### 9.1 Spacing Scale

```
--space-1:   4px
--space-2:   8px
--space-3:   12px
--space-4:   16px    ← padding konten standar
--space-5:   20px
--space-6:   24px
--space-8:   32px
--space-10:  40px
--space-12:  48px
--space-16:  64px
```

### 9.2 Layout Standar Mobile

```
Screen padding H:   16px (kiri & kanan)
Section gap:        24px antar section
Card gap:           12px antar card
Component gap:      8px antar elemen dalam komponen
Safe area top:      status bar height (dynamic)
Safe area bottom:   home indicator + 64px nav bar
```

### 9.3 Grid

- List properti: 1 kolom (full width) untuk list, 2 kolom untuk grid view
- Grid 2 kolom: gap 12px, tiap kolom `(screenWidth - 32 - 12) / 2`
- Jangan gunakan lebih dari 2 kolom di mobile

---

## 10. Border Radius

```
--radius-sm:    6px    /* Badge, chip kecil */
--radius-md:    10px   /* Input, tombol kecil */
--radius-lg:    12px   /* Tombol standar, card kecil */
--radius-xl:    16px   /* Card properti, bottom sheet */
--radius-2xl:   24px   /* Modal, drawer */
--radius-full:  9999px /* Pill, avatar, search bar */
```

---

## 11. Shadow / Elevation

```
--shadow-sm:   0 1px 3px rgba(28, 25, 23, 0.06)   /* Card default */
--shadow-md:   0 4px 12px rgba(28, 25, 23, 0.10)  /* Card hover, floating button */
--shadow-lg:   0 8px 24px rgba(28, 25, 23, 0.14)  /* Modal, bottom sheet */
--shadow-focus: 0 0 0 3px rgba(79, 70, 229, 0.20) /* Focus ring */
```

---

## 12. Peta & LBS

- Gunakan tile peta yang bersih dan tidak ramai (OpenStreetMap / Mapbox Light style)
- **Pin properti**: warna `--color-primary-500`, icon `ti-building` putih di dalam
- **Pin lokasi user**: warna `--color-accent-500`, pulse animation ringan
- **Pin aktif/dipilih**: ukuran 1.3× dari pin biasa, shadow `--shadow-md`
- Label nama properti di bawah pin: Plus Jakarta Sans 500 11px, bg putih, radius 4px, shadow sm
- Bottom sheet muncul dari bawah saat pin diklik (tinggi 40% layar)
- Tombol "Lokasi Saya": FAB pojok kanan bawah, icon `ti-current-location`

---

## 13. Payment UI

### 13.1 Layar Pilih Skema

- Tampilkan sebagai radio card (bukan dropdown)
- Tiap card berisi: icon, nama skema, deskripsi singkat, dan detail nominal
- Card terpilih: border `2px solid --color-primary-500`, bg `--color-primary-50`

### 13.2 Layar VA / QRIS

```
VA Number:    TT Commons Pro 700 24px, letter-spacing 0.05em
              background --color-bg-muted, border-radius 10px, padding 16px
              Icon copy (ti-copy) di kanan
QRIS Image:  center, max-width 240px, border 1px solid --color-border-default
Timer:        countdown, warna --color-danger-500 jika < 5 menit
Bank logo:   height 24px, grayscale kecuali hover
```

### 13.3 Kuitansi Digital

- Background putih, border `--color-border-default`
- Header: logo Ngekos.in + "KUITANSI RESMI"
- Dashed divider antar section (style tiket)
- Tombol download (ti-download) dan share (ti-share)

---

## 14. Empty State & Error State

### 14.1 Empty State

```
Ilustrasi:   SVG sederhana relevan dengan konteks, max 160px
Judul:       TT Commons Pro 600 18px, --color-text-primary
Deskripsi:   Plus Jakarta Sans 400 14px, --color-text-secondary, max 2 baris
CTA:         Tombol brand (jika ada aksi yang bisa dilakukan)
Layout:      center, padding 48px 24px
```

Contoh pesan:
- Belum ada properti → "Belum Ada Hunian" + "Jadilah yang pertama mendaftarkan properti di sini."
- Pencarian kosong → "Tidak Ditemukan" + "Coba ubah filter atau kata kunci pencarian."
- Riwayat kosong → "Belum Ada Transaksi" + "Mulai cari hunian dan ajukan sewa pertamamu."

### 14.2 Error State

```
Icon:        ti-alert-triangle, 48px, --color-danger-500
Pesan:       Plus Jakarta Sans 400 14px, --color-text-secondary
Tombol:      "Coba Lagi" (outline)
```

### 14.3 Loading State

- Skeleton loader untuk card properti (bukan spinner)
- Skeleton: bg `--color-neutral-100`, shimmer animation kiri→kanan
- Spinner (24px, `--color-primary-500`) hanya untuk loading overlay dan tombol

---

## 15. Dialog & Bottom Sheet

### 15.1 Dialog Konfirmasi

```
background:    #FFFFFF
border-radius: --radius-2xl (atas saja)
padding:       24px
max-width:     340px
Overlay:       --color-bg-overlay

Judul:    TT Commons Pro 600 18px
Deskripsi: Plus Jakarta Sans 400 14px, --color-text-secondary
Tombol:   2 tombol — kiri Batal (outline), kanan Konfirmasi (primary/danger)
```

### 15.2 Bottom Sheet

```
background:    #FFFFFF
border-radius: 20px 20px 0 0
padding:       20px 16px 32px
Handle:        4px × 32px, --color-neutral-300, radius 2px, margin auto 8px bawah
```

### 15.3 Toast / Snackbar

```
background:    --color-neutral-800
color:         #FFFFFF
border-radius: 10px
padding:       12px 16px
font:          Plus Jakarta Sans 500 13px
Durasi:        3 detik, slide up dari bawah
Posisi:        bottom 80px (di atas bottom nav)

Varian:
  Sukses:  icon ti-circle-check, --color-success-500
  Error:   icon ti-circle-x, --color-danger-500
  Info:    icon ti-info-circle, --color-info-500
```

---

## 16. Aturan Aksesibilitas

- Semua elemen interaktif minimum **44×44px** tap target
- Contrast ratio teks minimum **4.5:1** (body), **3:1** (large text)
- Setiap icon fungsional wajib `aria-label`
- Input wajib punya `label` yang terasosiasi (bukan hanya placeholder)
- Jangan mengandalkan warna saja untuk menyampaikan informasi — selalu sertakan teks atau icon

---

## 17. Animasi & Transisi

```
--transition-fast:   120ms ease
--transition-normal: 200ms ease
--transition-slow:   300ms ease-in-out

Digunakan:
  Tombol active state:  --transition-fast, scale 0.97
  Toggle/switch:        --transition-normal
  Bottom sheet masuk:   --transition-slow, slide-up
  Modal masuk:          --transition-normal, fade + scale 0.96 → 1
  Skeleton shimmer:     1.5s infinite linear
  Map pin pulse:        2s infinite ease-in-out
```

Hindari animasi yang berlebihan. Setiap animasi harus punya tujuan fungsional (feedback, orientasi, atau transisi).

---

## 18. Panduan untuk AI Agent

> Baca bagian ini sebelum menulis kode UI apapun.

- **Selalu gunakan token** (CSS variables) — jangan hardcode nilai warna, ukuran, atau spacing
- **Font wajib**: TT Commons Pro untuk semua heading/display, Plus Jakarta Sans untuk UI/body
- **Jangan improvisasi warna** — gunakan hanya palet yang ada di Bagian 3
- **Icon harus dari Tabler outline** — lihat daftar di Bagian 8.3
- **Ikuti border-radius yang ditetapkan** — jangan menggunakan nilai di luar Bagian 10
- **Tombol CTA utama** selalu `--color-accent-500` (amber), bukan primary
- **Tombol aksi brand** (login, register, tambah) selalu `--color-primary-500` (indigo)
- **Jangan buat shadow baru** di luar yang didefinisikan di Bagian 11
- **Teks di bg gelap** selalu putih — tidak ada pengecualian
- **Konsistensi lebih penting dari kreativitas** — jika ragu, tanya sebelum membuat keputusan visual baru
