import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../screens/bookmark_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/edit_profile_screen.dart';

class AppRouting {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String editProfile = '/profile-edit';
  static const String detail = '/detail';
  static const String bookmarkForm = '/bookmark-form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case detail:
        final id = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => DetailScreen(postId: id));

      case bookmarkForm:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BookmarkFormScreen(
            existing: args['bookmark'] as Bookmark?,
            preselectedTopicId: args['preselectedTopicId'] as int?,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
            body: const Center(child: Text('Route tidak dikenali.')),
          ),
        );
    }
  }
}
