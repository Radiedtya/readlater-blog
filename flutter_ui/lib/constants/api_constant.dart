import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Konfigurasi base URL & endpoint API.
///
/// Base URL otomatis menyesuaikan platform saat development:
/// - Web / iOS Simulator  : http://127.0.0.1:8000
/// - Android Emulator     : http://10.0.2.2:8000
/// - Physical device      : ubah manual ke `http://<IP-LAN-komputer>:8000`
class ApiConstant {
  ApiConstant._();

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000'; // emulator Android
    }
    return 'http://127.0.0.1:8000';
  }

  // ---- Auth ----
  static const String register = '/api/register';
  static const String login = '/api/login';
  static const String logout = '/api/logout';
  static const String me = '/api/user';
  static const String updateProfile = '/api/user';
  static const String uploadProfileImage = '/api/user/avatar';

  // ---- Topics ----
  static const String topics = '/api/topics';
  static String topic(int id) => '/api/topics/$id';

  // ---- Bookmarks ----
  static const String bookmarks = '/api/bookmarks';
  static const String bookmarksCheck = '/api/bookmarks/check';
  static String bookmark(int id) => '/api/bookmarks/$id';

  // ---- Public API (proxy dummyjson lewat Laravel) ----
  static const String publicPosts = '/api/public/posts';
  static String publicPost(int id) => '/api/public/posts/$id';
}
