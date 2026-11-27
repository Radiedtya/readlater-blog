# ReadLater

ReadLater adalah aplikasi untuk menjelajahi artikel, menyimpan artikel sebagai bookmark, dan mengelola bookmark berdasarkan topik. Repository ini terdiri dari aplikasi Flutter sebagai frontend dan Laravel sebagai REST API.

## Isi repository

```text
readlater-blog/
├── flutter_ui/       # Aplikasi Flutter (mobile, web, dan desktop)
└── laravel_api/      # REST API Laravel, database, dan migrasi
```

## Teknologi

- **Frontend:** Flutter dan Dart, dengan `http` untuk request API, `shared_preferences` untuk menyimpan token, dan Google Fonts untuk tipografi.
- **Backend:** Laravel 13, PHP 8.3+, Laravel Sanctum untuk autentikasi token, dan SQLite sebagai database bawaan konfigurasi.
- **Artikel publik:** Laravel meneruskan request ke [DummyJSON Posts](https://dummyjson.com/posts).

## Persyaratan

- Flutter SDK dan Dart SDK yang memenuhi versi di `flutter_ui/pubspec.yaml`
- PHP 8.3 atau lebih baru dan Composer
- Browser untuk menjalankan versi web, atau Android Studio/emulator untuk menjalankan versi Android
- Koneksi internet untuk mengambil artikel dari DummyJSON

## Menjalankan aplikasi di Windows

Jalankan API dan Flutter di dua terminal terpisah dari folder repository.

### 1. Siapkan dan jalankan Laravel API

```powershell
Set-Location .\laravel_api
composer install

if (-not (Test-Path .env)) {
    Copy-Item .env.example .env
}

if (-not (Test-Path .\database\database.sqlite)) {
    New-Item -ItemType File -Path .\database\database.sqlite | Out-Null
}

php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

API akan tersedia di `http://127.0.0.1:8000`. Opsi `--host=0.0.0.0` memungkinkan perangkat lain di jaringan lokal mengakses API; jangan mengekspos server development ini ke jaringan publik.

Konfigurasi lokal ada di `laravel_api/.env` dan tidak seharusnya dimasukkan ke repository. `.env.example` menggunakan SQLite (`DB_CONNECTION=sqlite`). `php artisan migrate --seed` membuat tabel dan mengisi topik awal.

### 2. Jalankan aplikasi Flutter

Buka terminal kedua dari folder repository:

```powershell
Set-Location .\flutter_ui
flutter pub get
flutter run -d chrome
```

Untuk Android, jalankan emulator atau hubungkan perangkat lalu gunakan:

```powershell
flutter run
```

Alamat API untuk tiap platform diatur di `flutter_ui/lib/constants/api_constant.dart`:

- Web dan iOS Simulator: `http://127.0.0.1:8000`
- Android Emulator: `http://10.0.2.2:8000`
- Perangkat fisik: ubah alamat tersebut ke IP LAN komputer yang menjalankan Laravel, misalnya `http://192.168.1.10:8000`. Pastikan perangkat dan komputer berada di jaringan yang sama.

Alamat ini merupakan konfigurasi development berbasis HTTP. Untuk deployment, gunakan alamat server yang sesuai dan HTTPS.

## Fitur dan alur API

- Registrasi, login, logout, dan pembaruan profil pengguna.
- Melihat daftar artikel publik dan detail artikel; artikel diambil melalui API Laravel dari DummyJSON.
- Menyimpan artikel atau membuat bookmark sendiri, mengubah dan menghapus bookmark, serta memfilter daftar berdasarkan topik atau kata pencarian.
- Mengelompokkan bookmark dengan topik **Teknologi**, **Gaya Hidup**, dan **Bisnis**. Topik dibuat oleh seeder dan endpoint topik memerlukan autentikasi.
- Token autentikasi disimpan di `shared_preferences` dan dikirim sebagai Bearer token untuk endpoint yang dilindungi Sanctum.

Endpoint yang tersedia:

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| `POST` | `/api/register` | Membuat akun dan token |
| `POST` | `/api/login` | Login dan menerbitkan token |
| `GET` | `/api/public/posts` | Daftar artikel; menerima `limit`, `skip`, dan `q` |
| `GET` | `/api/public/posts/{id}` | Detail artikel |
| `GET` | `/api/user` | Data pengguna yang sedang login |
| `PUT` | `/api/user` | Memperbarui profil atau kata sandi |
| `POST` | `/api/logout` | Mencabut token yang digunakan |
| `GET` | `/api/topics` | Daftar topik |
| `GET` | `/api/topics/{id}` | Detail topik |
| `GET` | `/api/bookmarks` | Daftar bookmark; menerima `topic_id` dan `q` |
| `POST` | `/api/bookmarks` | Membuat bookmark |
| `GET` | `/api/bookmarks/check?source_id={id}` | Memeriksa apakah artikel sudah disimpan |
| `GET` | `/api/bookmarks/{id}` | Detail bookmark |
| `PUT` | `/api/bookmarks/{id}` | Memperbarui bookmark |
| `DELETE` | `/api/bookmarks/{id}` | Menghapus bookmark |

Semua endpoint selain registrasi, login, dan `/api/public/posts...` memerlukan header `Authorization: Bearer <token>`.

## Struktur frontend (`flutter_ui/`)

### Kode aplikasi (`lib/`)

- `main.dart` — entry point Flutter, tema, dan konfigurasi `MaterialApp`.
- `constants/api_constant.dart` — base URL dan path endpoint API.
- `routes/app_routing.dart` — definisi route dan pembuatan halaman.
- `screens/` — halaman aplikasi:
  - `splash_screen.dart` — layar awal dan pemeriksaan status sesi.
  - `login_screen.dart`, `register_screen.dart` — autentikasi pengguna.
  - `home_screen.dart` — halaman utama dan navigasi ke bagian aplikasi.
  - `explore_screen.dart` — menjelajahi dan mencari artikel publik.
  - `detail_screen.dart` — membaca detail artikel publik.
  - `bookmarks_screen.dart` — melihat dan memfilter bookmark.
  - `bookmark_detail_screen.dart` — membaca satu bookmark.
  - `bookmark_form_screen.dart` — membuat atau mengedit bookmark.
  - `profile_screen.dart`, `edit_profile_screen.dart` — melihat dan mengubah profil.
- `services/` — komunikasi dengan backend:
  - `auth_service.dart` — registrasi, login, token, sesi, logout, dan pembaruan profil.
  - `crud_service.dart` — operasi topik dan bookmark.
  - `public_api_service.dart` — daftar dan detail artikel publik.
- `models/` — model data dan parsing JSON: `user.dart` (pengguna), `topic.dart` (topik bookmark), `bookmark.dart` (bookmark), `public_post.dart` (ringkasan artikel), dan `public_post_detail.dart` (detail artikel).
- `widgets/` — komponen UI yang digunakan ulang: `app_brand.dart` (identitas aplikasi), `custom_bottom_nav.dart` (navigasi bawah), `editorial_visuals.dart` (elemen visual editorial), dan `search_field.dart` (kolom pencarian).
- `state/bookmark_events.dart` — notifikasi perubahan bookmark agar halaman lain dapat memuat ulang datanya.

### Konfigurasi dan platform

- `pubspec.yaml` dan `pubspec.lock` — metadata aplikasi dan dependensi Dart/Flutter.
- `analysis_options.yaml` — aturan analisis kode Dart.
- `README.md` — README bawaan Flutter yang masih berisi petunjuk template.
- `test/widget_test.dart` — pengujian widget. Isinya masih berupa tes counter bawaan Flutter, belum disesuaikan dengan halaman ReadLater.
- `android/` — proyek Gradle, manifest, launcher, dan runner Android.
- `ios/` — proyek Xcode, konfigurasi Flutter, storyboard, dan runner iOS.
- `web/` — halaman HTML awal, ikon, dan manifest aplikasi web.
- `linux/`, `macos/`, `windows/` — konfigurasi build, runner desktop, dan aset aplikasi untuk tiap platform.
- `.metadata` dan `.gitignore` — metadata proyek Flutter serta aturan file yang tidak dilacak Git.

## Struktur backend (`laravel_api/`)

- `artisan` — entry point perintah Laravel.
- `app/Http/Controllers/Api/` — implementasi endpoint:
  - `AuthController.php` — autentikasi dan profil.
  - `BookmarkController.php` — operasi bookmark dan pemeriksaan kepemilikan.
  - `TopicController.php` — daftar dan detail topik.
  - `PublicApiController.php` — proxy artikel DummyJSON.
- `app/Http/Controllers/Controller.php` — base controller untuk controller aplikasi.
- `app/Models/` — model Eloquent `User`, `Topic`, dan `Bookmark` serta relasinya.
- `app/Providers/AppServiceProvider.php` — tempat registrasi dan bootstrap service aplikasi.
- `bootstrap/app.php`, `bootstrap/providers.php` — konfigurasi bootstrap serta daftar service provider; `bootstrap/cache/` menyimpan cache framework.
- `config/` — konfigurasi runtime: `app.php` (aplikasi), `auth.php` (autentikasi), `cache.php` (cache), `cors.php` (CORS), `database.php` (database), `filesystems.php` (storage), `logging.php` (log), `mail.php` (email), `queue.php` (queue), `sanctum.php` (token), `services.php` (integrasi), dan `session.php` (session).
- `database/migrations/` — skema database: migrasi awal membuat tabel users, cache, dan jobs; migrasi berikutnya membuat personal access tokens Sanctum, topics, bookmarks, lalu menambahkan `source_id` pada bookmarks.
- `database/seeders/` — `DatabaseSeeder.php` memanggil `TopicSeeder.php` untuk mengisi daftar topik.
- `database/factories/` — factory untuk membuat data pengguna pada pengujian.
- `database/database.sqlite` — file database SQLite lokal yang dibuat saat setup; tidak perlu dibagikan antar lingkungan.
- `routes/api.php` — definisi endpoint REST API.
- `routes/web.php` — route web `/` untuk halaman welcome Laravel.
- `routes/console.php` — definisi perintah console aplikasi.
- `resources/css/app.css`, `resources/js/app.js` — entry point aset CSS dan JavaScript Vite.
- `resources/views/welcome.blade.php` — view sambutan yang ditampilkan dari route web `/`.
- `public/index.php` — entry point request web; `.htaccess`, favicon, dan `robots.txt` adalah file publik pendukung.
- `storage/` — lokasi runtime untuk log, cache, session, view hasil kompilasi, dan file aplikasi.
- `tests/TestCase.php`, `tests/Unit/ExampleTest.php`, `tests/Feature/ExampleTest.php` — base test dan contoh tes bawaan Laravel.
- `composer.json` / `composer.lock` — dependensi PHP dan script Composer.
- `package.json`, `vite.config.js` — dependensi dan konfigurasi build aset frontend Laravel.
- `.env.example` — contoh konfigurasi environment; salin menjadi `.env` untuk penggunaan lokal.
- `phpunit.xml` — konfigurasi PHPUnit, termasuk SQLite in-memory untuk test.
- `README.md` — dokumentasi bawaan Laravel, masih berisi panduan framework umum.
- `AGENTS.md`, `CLAUDE.md` — panduan kerja untuk coding assistant.
- `.zed/settings.json` — pengaturan editor Zed untuk repository.
- `.gitignore`, `.gitattributes`, `.editorconfig`, dan `.npmrc` — aturan Git, format editor, dan konfigurasi npm.

## Menjalankan pemeriksaan

Flutter:

```powershell
Set-Location .\flutter_ui
flutter analyze
flutter test
```

Laravel:

```powershell
Set-Location .\laravel_api
php artisan test
```

## Catatan

- Jangan commit `laravel_api/.env`, kredensial, atau token.
- `flutter_ui/build/`, `flutter_ui/.dart_tool/`, dan `laravel_api/vendor/` adalah hasil build atau dependensi; tidak perlu diedit secara manual.
- `flutter test` saat ini menjalankan test counter template Flutter yang belum terhubung ke aplikasi ReadLater; test tersebut perlu disesuaikan sebelum dijadikan validasi fitur aplikasi.
- README bawaan di masing-masing subproyek merupakan dokumentasi template framework. Dokumen ini menjelaskan integrasi dan struktur repository ReadLater.
