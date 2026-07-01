# GodeTrans - Aplikasi Pemesanan Tiket Travel

Aplikasi mobile pemesanan tiket travel (seperti Traveloka/Cititrans, tapi untuk
armada Hiace antar kota), dibangun dengan **Flutter** dan **Google Sheets**
sebagai database (lewat Google Apps Script sebagai REST API).

Fitur yang sudah jadi:
- Onboarding (3 slide)
- Login & Register (email/password ke Google Sheets, tombol sosial sebagai placeholder UI)
- Home: greeting, banner diskon, form cari tiket, rute populer
- Flow pemesanan tiket lengkap (7 langkah): Pilih Jadwal → Pilih Armada → Pilih
  Kursi → Data Penumpang → Ringkasan Pesanan → Pembayaran (simulasi) → Pembayaran Berhasil
- Tiket Saya (tab Akan Datang / Selesai)
- Riwayat Pesanan
- Akun Saya (profile, pengaturan placeholder, keluar)

> ⚡ **Sebelum mulai:** project ini berisi semua kode Dart (folder `lib/`)
> dan konfigurasi, tapi folder platform native (`android/`, `ios/`) belum
> disertakan. Cukup jalankan `flutter create .` sekali di folder ini —
> lihat **Bagian 2, Langkah 1** di bawah. Setelah itu app langsung bisa
> di-run seperti biasa.

---

## 📁 Struktur Folder

```
godetrans/
├── lib/
│   ├── main.dart                  # entry point
│   ├── models/                    # model data (User, Rute, Armada, Booking, dll)
│   ├── services/                  # koneksi ke Google Sheets API
│   ├── provider/                  # state management proses booking
│   ├── theme/                     # warna & gaya teks aplikasi
│   ├── widgets/                   # komponen UI yang dipakai berulang
│   └── screens/                   # semua halaman aplikasi
│       ├── onboarding/
│       ├── auth/
│       ├── home/
│       ├── booking/
│       ├── tickets/
│       └── account/
├── backend_apps_script/
│   └── Code.gs                    # kode backend Google Apps Script
├── pubspec.yaml
└── README.md                      # file ini
```

---

## 🧩 BAGIAN 1 — Setup Backend (Google Sheets + Apps Script)

Karena Anda sudah biasa pakai Google Sheets, ini ringkas saja:

### Langkah 1: Buat Spreadsheet
1. Buka [sheets.google.com](https://sheets.google.com), buat spreadsheet baru.
2. Beri nama misalnya **"GodeTrans Database"**.

### Langkah 2: Tempel Kode Apps Script
1. Di spreadsheet tadi, klik menu **Extensions → Apps Script**.
2. Hapus semua isi default di `Code.gs`.
3. Buka file `backend_apps_script/Code.gs` dari folder project ini, copy
   **seluruh isinya**, lalu paste ke editor Apps Script.
4. Simpan (Ctrl+S / Cmd+S), beri nama project misalnya "GodeTrans API".

### Langkah 3: Jalankan Setup Sekali
1. Di toolbar Apps Script, pilih fungsi `setupSheets` dari dropdown
   (di sebelah tombol "Run" / "Debug").
2. Klik **Run**.
3. Akan muncul permintaan izin (Authorization required) → klik **Review
   permissions** → pilih akun Google Anda → klik **Advanced** → **Go to
   GodeTrans API (unsafe)** → **Allow**.
   (Ini normal, karena scriptnya milik Anda sendiri dan belum diverifikasi
   Google — aman untuk dipakai pribadi.)
4. Setelah selesai jalan, akan muncul alert "Setup selesai!" dan kembali ke
   spreadsheet Anda akan terlihat sheet baru: `Users`, `RutePopuler`,
   `Jadwal`, `Armada`, `Kursi`, `Booking` — sudah lengkap dengan header
   kolom dan beberapa contoh data.

### Langkah 4: Deploy sebagai Web App
1. Di Apps Script, klik tombol **Deploy → New deployment**.
2. Klik ikon gear ⚙️ di samping "Select type", pilih **Web app**.
3. Isi:
   - Description: `GodeTrans API v1`
   - Execute as: **Me**
   - Who has access: **Anyone**
4. Klik **Deploy**.
5. Akan muncul **Web app URL** seperti:
   ```
   https://script.google.com/macros/s/AKfycbx.................../exec
   ```
   **Copy URL ini.**

> ⚠️ Setiap kali Anda mengedit `Code.gs` lagi setelah deploy, Anda perlu
> membuat **New deployment** lagi (atau gunakan "Manage deployments" →
> edit versi) agar perubahan kode ikut terpakai oleh URL yang sama.

### Struktur Sheet (otomatis dibuat oleh `setupSheets`)

| Sheet | Kolom |
|---|---|
| `Users` | id, nama, email, password, no_hp, role, created_at |
| `RutePopuler` | id, asal, tujuan, jam_berangkat, kursi_tersedia, harga |
| `Jadwal` | id, asal, tujuan, jam, kursi_tersedia |
| `Armada` | id, asal, tujuan, jam, nama, jumlah_kursi, harga, status |
| `Kursi` | id, armada_id, tanggal, jam, no_kursi, status |
| `Booking` | id, user_id, asal, tujuan, tanggal_berangkat, jam_berangkat, armada_id, armada_nama, nama_penumpang, kursi, jumlah_penumpang, harga_tiket, biaya_layanan, total_bayar, status, created_at |

Anda bisa menambah rute, armada, atau jadwal lain langsung dengan mengetik
baris baru di sheet `RutePopuler` dan `Armada` — tidak perlu ubah kode.

Catatan penting tentang peran (roles):

- **Peran yang didukung:** `admin` dan `user`.
- Saat `setupSheets` dijalankan pada spreadsheet baru, script akan menambahkan
  dua akun contoh: satu `admin` dan satu `user`.
- Contoh kredensial admin (untuk testing):

  - Email: `admin@godetrans.local`
  - Password: `admin123`

- Jika Anda sudah memiliki sheet `Users` dari setup sebelumnya, tambahkan
  kolom `role` (sebelum `created_at`) secara manual dan isi nilai `admin`
  untuk akun admin yang Anda buat sendiri.

---

## 📱 BAGIAN 2 — Menjalankan Aplikasi Flutter

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang
  (cek dengan `flutter doctor`).
- Editor: Android Studio / VS Code (dengan plugin Flutter).
- Emulator Android/iOS, atau HP fisik dengan USB debugging aktif.

### Langkah 1 (PENTING): Lengkapi Platform Folder
Project ini berisi source code Dart (`lib/`) dan konfigurasi (`pubspec.yaml`)
secara lengkap, namun folder platform (`android/`, `ios/`, dll) belum
disertakan karena ukurannya besar dan spesifik per-mesin. Buat folder
tersebut dengan satu kali perintah:

```bash
cd godetrans
flutter create . --org com.godetrans --project-name godetrans
```

Perintah ini **aman** dijalankan di folder project yang sudah ada — Flutter
akan otomatis membuat `android/`, `ios/`, `web/`, dll tanpa menimpa folder
`lib/` atau `pubspec.yaml` yang sudah Anda punya (Flutter akan mendeteksi
`pubspec.yaml` yang sudah ada dan hanya melengkapi bagian yang belum ada).

> Jika muncul pertanyaan untuk overwrite `pubspec.yaml`/`analysis_options.yaml`,
> pilih **No/n** agar konfigurasi yang sudah disiapkan tidak hilang.

### Langkah 2: Hubungkan ke Backend
1. Buka file:
   ```
   lib/services/sheets_api_service.dart
   ```
2. Cari baris:
   ```dart
   static const String baseUrl = "PASTE_URL_WEB_APP_APPS_SCRIPT_ANDA_DISINI";
   ```
3. Ganti dengan URL Web App yang Anda copy di Bagian 1, Langkah 4. Contoh:
   ```dart
   static const String baseUrl = "https://script.google.com/macros/s/AKfycbx.../exec";
   ```

### Langkah 3: Install Dependencies
Buka terminal di folder project ini, jalankan:
```bash
flutter pub get
```

### Langkah 4: Jalankan Aplikasi
Pastikan emulator/HP sudah terdeteksi (`flutter devices`), lalu:
```bash
flutter run
```

Aplikasi akan terbuka mulai dari **Onboarding**, lalu **Login/Register**
(buat akun baru dulu jika belum ada), masuk ke **Home**, dan Anda bisa
langsung mencoba alur pemesanan tiket lengkap sampai **Pembayaran Berhasil**.

### Panel Admin (placeholder di app)

Saya menambahkan layar admin sederhana di aplikasi Flutter sebagai placeholder:

- `lib/screens/admin/admin_dashboard.dart` — dashboard admin (link ke manage bookings)
- `lib/screens/admin/manage_bookings_screen.dart` — tampilan daftar booking, bisa ubah status

Untuk mengaksesnya di aplikasi, tambahkan navigasi ke `AdminDashboardScreen`
atau panggil route secara manual. Gunakan kredensial admin yang ada di sheet
(`admin@godetrans.local` / `admin123`) untuk testing — setelah login, Anda bisa
lihat daftar booking dan ubah statusnya (fungsi ini memanggil endpoint
`updateBookingStatus` pada Apps Script).

---

## 🔄 Cara Kerja Singkat

```
Flutter App  ──HTTP GET/POST──▶  Apps Script (Web App)  ──▶  Google Sheets
             ◀──── JSON ────────
```

- **GET** dipakai untuk mengambil data (rute, jadwal, armada, kursi, tiket).
- **POST** dipakai untuk menyimpan data (register, login, buat booking).
- Semua request memakai parameter `action` untuk menentukan operasi apa
  yang dijalankan di sisi Apps Script (lihat `doGet` dan `doPost` di
  `Code.gs`).

## 🛠️ Troubleshooting

**"Belum terhubung ke server" muncul di app**
→ Pastikan `baseUrl` di `sheets_api_service.dart` sudah benar dan sudah
  di-deploy ulang setelah edit `Code.gs` terakhir.

**Error "Authorization required" terus muncul saat Run di Apps Script**
→ Klik Advanced → Go to [nama project] (unsafe) → Allow. Ini wajar untuk
  script pribadi yang belum diverifikasi Google.

**Data tidak nambah meski sudah pesan tiket**
→ Cek sheet `Booking`, pastikan baris baru bertambah. Jika tidak, cek log
  error di Apps Script: menu **Executions** di sidebar kiri editor Apps Script.

**Login gagal padahal sudah daftar**
→ Pastikan email yang dipakai untuk login sama persis (case-sensitive) dengan
  yang didaftarkan, dan cek langsung di sheet `Users` apakah datanya tersimpan.

---

## 📌 Catatan Pengembangan Selanjutnya (opsional)
- Pembayaran saat ini adalah **simulasi** (tidak ada gateway nyata seperti
  Midtrans/Xendit). Status langsung ditandai berhasil dan tersimpan ke sheet
  `Booking`.
- Password disimpan sebagai teks biasa di sheet `Users` untuk kesederhanaan —
  untuk produksi nyata sebaiknya di-hash, namun ini di luar cakupan versi awal.
- Tombol login Google/Facebook/Apple masih placeholder UI (menampilkan pesan
  "belum tersedia"), sesuai kesepakatan awal pengembangan.
