import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../widgets/app_brand.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/editorial_visuals.dart';
import 'bookmarks_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index;

  final _pages = const [ExploreScreen(), BookmarksScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _navigateToTab(int index) {
    if (index == _index) return;

    final route = switch (index) {
      0 => AppRouting.home,
      1 => AppRouting.bookmarks,
      2 => AppRouting.profile,
      _ => throw RangeError.index(index, _pages, 'index'),
    };
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final palette = switch (_index) {
      0 => EditorialPalette.explore,
      1 => EditorialPalette.bookmarks,
      _ => EditorialPalette.profile,
    };

    return Scaffold(
      extendBody: true, // Biar background tembus ke bawah Navbar
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.colors,
                ),
              ),
            ),
          ),

          // 2. Header aplikasi dan konten halaman
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppBrand(),
                  ),
                ),
                Expanded(
                  child: IndexedStack(index: _index, children: _pages),
                ),
              ],
            ),
          ),

          // 3. Custom Navbar di paling bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNav(currentIndex: _index, onTap: _navigateToTab),
          ),
        ],
      ),
    );
  }
}
