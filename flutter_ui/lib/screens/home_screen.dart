import 'package:flutter/material.dart';

import '../widgets/custom_bottom_nav.dart';
import 'bookmarks_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  // 3 warna gradasi terang yang soft (Peach, Lavender, Cream)
  static const _gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFF0EB), // Peach lembut
        Color(0xFFF3EFFF), // Lavender sangat terang
        Color(0xFFF7F6F2), // Cream
      ],
      stops: [0.0, 0.5, 1.0],
    ),
  );

  final _pages = const [ExploreScreen(), BookmarksScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Biar background tembus ke bawah Navbar
      body: Stack(
        children: [
          // 1. Background Gradasi
          Container(decoration: _gradientBackground),

          // 2. Konten Halaman
          IndexedStack(index: _index, children: _pages),

          // 3. Custom Navbar di paling bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}
