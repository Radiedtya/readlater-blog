import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../screens/bookmark_detail_screen.dart';
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
  static const String bookmarkDetail = '/bookmark-detail';
  static const String bookmarkForm = '/bookmark-form';

  static Route<dynamic> _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.018),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(settings, const SplashScreen());

      case login:
        return _buildRoute(settings, const LoginScreen());

      case register:
        return _buildRoute(settings, const RegisterScreen());

      case editProfile:
        return _buildRoute(settings, const EditProfileScreen());

      case home:
        return _buildRoute(settings, const HomeScreen());

      case detail:
        final id = settings.arguments as int;
        return _buildRoute(settings, DetailScreen(postId: id));

      case bookmarkDetail:
        final bookmark = settings.arguments as Bookmark;
        return _buildRoute(settings, BookmarkDetailScreen(bookmark: bookmark));

      case bookmarkForm:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          settings,
          BookmarkFormScreen(
            existing: args['bookmark'] as Bookmark?,
            preselectedTopicId: args['preselectedTopicId'] as int?,
          ),
        );

      default:
        return _buildRoute(
          settings,
          Scaffold(
            appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
            body: const Center(child: Text('Route tidak dikenali.')),
          ),
        );
    }
  }
}
