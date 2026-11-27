import 'dart:math' as math;

import 'package:flutter/material.dart';

enum EditorialPalette {
  login,
  register,
  explore,
  bookmarks,
  profile,
  article,
  saved,
  bookmarkForm,
  account,
  splash,
}

extension EditorialPaletteColors on EditorialPalette {
  List<Color> get colors => switch (this) {
    EditorialPalette.login => const [Color(0xFFE7F0FF), Color(0xFFF9F2F1)],
    EditorialPalette.register => const [Color(0xFFFFE9DF), Color(0xFFF7EAF2)],
    EditorialPalette.explore => const [Color(0xFFE5F3EE), Color(0xFFF4F3E8)],
    EditorialPalette.bookmarks => const [Color(0xFFEDE8FA), Color(0xFFF8EDF3)],
    EditorialPalette.profile => const [Color(0xFFFFEFCF), Color(0xFFF8E6D9)],
    EditorialPalette.article => const [Color(0xFFE2EFFB), Color(0xFFF1EDF8)],
    EditorialPalette.saved => const [Color(0xFFE2F2E8), Color(0xFFF2F0DF)],
    EditorialPalette.bookmarkForm => const [
      Color(0xFFFFE8D6),
      Color(0xFFF9F0E3),
    ],
    EditorialPalette.account => const [Color(0xFFE8E8FA), Color(0xFFF8EAF0)],
    EditorialPalette.splash => const [Color(0xFFF9E6EE), Color(0xFFE9EFFB)],
  };
}

class EditorialBackdrop extends StatelessWidget {
  final EditorialPalette palette;

  const EditorialBackdrop({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.colors,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class ReadingHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final bool compact;

  const ReadingHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    this.accent = const Color(0xFFD87A59),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 132 : 156),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: compact ? 22 : 24,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ReadingArtwork(icon: icon, accent: accent),
        ],
      ),
    );
  }
}

class _ReadingArtwork extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _ReadingArtwork({required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 2,
            top: 4,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 3,
            bottom: 3,
            child: Transform.rotate(
              angle: -0.16,
              child: Container(
                width: 56,
                height: 76,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.08,
            child: Container(
              width: 64,
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: accent),
                  const SizedBox(height: 8),
                  Container(
                    width: 34,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 9,
            child: Transform.rotate(
              angle: math.pi / 12,
              child: Icon(Icons.auto_awesome, size: 20, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
