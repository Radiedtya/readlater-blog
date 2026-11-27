import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../widgets/app_header.dart';
import '../widgets/custom_bottom_nav.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: IndexedStack(index: _index, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _index,
        onTap: _navigateToTab,
      ),
    );
  }
}
