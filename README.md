# News App (Kabar Antariksa) - Proyek Pembelajaran Flutter

Aplikasi Flutter untuk membaca berita antariksa dari REST API publik (*Spaceflight News API*) tanpa API key. Proyek ini dibangun berdasarkan Product Requirement Document (**PRD: News App untuk Pembelajaran Flutter**).

---

## 🎯 Learning Objectives

1. **Melakukan network call ke REST API** menggunakan package `http`.
2. **Menerapkan asynchronous programming** dengan `Future` dan `async/await`.
3. **Menangani state jaringan:** `loading`, `sukses`, dan `error` (disertai tombol *Coba Lagi*).
4. **Mem-parsing data JSON menjadi model Dart** (`Article.fromJson`) dengan penanganan nilai `null` yang aman.

---

## 🚀 Fitur Versi 1

- **Daftar Berita**: Menampilkan artikel terbaru (gambar, judul, sumber berita, tanggal terbit).
- **Penanganan State Jaringan**:
  - Indikator loading saat memuat data.
  - Pesan error informatif saat offline/gagal dengan tombol *Coba Lagi*.
- **Pencarian & Pagination**:
  - Pencarian artikel secara instan berdasarkan kata kunci.
  - Infinite scroll (pagination otomatis `limit` & `offset` saat scroll mencapai bagian bawah).
- **Detail Artikel**:
  - Tampilan gambar resolusi tinggi, sumber, tanggal, dan ringkasan lengkap.
  - Tombol **Buka Artikel Asli** ke web browser eksternal via `url_launcher`.
- **Bookmark / Favorit**:
  - Simpan dan hapus artikel favorit dari daftar maupun halaman detail.
  - State favorit dikelola secara in-memory menggunakan `Provider`.
  - Halaman khusus *Artikel Favorit* lengkap dengan empty state dan aksi hapus.
- **Null Safety Robust**: Artikel dengan gambar atau ringkasan kosong tetap tampil tanpa error / crash.

---

## 📁 Struktur Folder

```text
lib/
├── main.dart                       # Setup MultiProvider, Material 3 Theme & entry point
├── models/
│   └── article.dart                # Model data Article & fromJson parsing
├── services/
│   └── news_service.dart           # Panggilan HTTP ke Spaceflight News REST API
├── providers/
│   ├── news_provider.dart          # State management berita (loading, loaded, error, pagination, search)
│   └── bookmark_provider.dart      # State management bookmark in-memory
├── screens/
│   ├── home_screen.dart            # Layar utama daftar berita & pencarian
│   ├── detail_screen.dart          # Layar detail artikel & tombol buka web
│   └── bookmark_screen.dart        # Layar daftar artikel favorit
└── widgets/
    ├── article_card.dart           # Komponen kartu artikel
    └── error_view.dart             # Komponen pesan error & tombol coba lagi
```

---

## 🛠️ Tech Stack & Dependencies

- **Flutter & Dart SDK**
- [`http`](https://pub.dev/packages/http): Network requests ke REST API.
- [`provider`](https://pub.dev/packages/provider): State management reaktif.
- [`url_launcher`](https://pub.dev/packages/url_launcher): Membuka tautan artikel asli di browser.
- [`intl`](https://pub.dev/packages/intl): Format tanggal dan waktu yang ramah pengguna.

---

## 🧪 Menjalankan Pengujian & Analisis

Jalankan perintah berikut di terminal:

```bash
# Menjalankan static analysis (bebas issue)
flutter analyze

# Menjalankan unit tests dan widget tests
flutter test
```

---

## 📱 Menjalankan Aplikasi

```bash
# Mengambil dependencies
flutter pub get

# Menjalankan di perangkat / emulator yang aktif
flutter run
```
