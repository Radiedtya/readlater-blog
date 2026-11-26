import 'package:flutter/foundation.dart';

/// Sinyal global: "daftar bookmark berubah".
///
/// Dipakai supaya screen lain (misal [BookmarksScreen] yang sudah di-mount
/// di dalam IndexedStack) tahu kalau bookmark dibuat/diubah/dihapus
/// dari tempat lain ([DetailScreen], dsb.), lalu reload otomatis.
class BookmarkEvents extends ChangeNotifier {
  BookmarkEvents._();
  static final BookmarkEvents instance = BookmarkEvents._();

  void notifyChanged() => notifyListeners();
}