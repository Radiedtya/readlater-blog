import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.explore_outlined, label: 'Jelajah'),
      (icon: Icons.bookmark_border_rounded, label: 'Tersimpan'),
      (icon: Icons.person_outline_rounded, label: 'Profil'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFEAE8E2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final isActive = currentIndex == index;
            return Expanded(
              child: _NavBarItem(
                icon: items[index].icon,
                label: items[index].label,
                isActive: isActive,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF1EFE9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? const Color(0xFF292821)
                  : const Color(0xFF858178),
              size: 20,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF292821)
                    : const Color(0xFF858178),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
