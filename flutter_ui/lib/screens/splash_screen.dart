import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../widgets/app_brand.dart';
import '../widgets/editorial_visuals.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      loggedIn ? AppRouting.home : AppRouting.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: EditorialBackdrop(palette: EditorialPalette.splash),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppBrand(),
                  const SizedBox(height: 28),
                  const ReadingHero(
                    eyebrow: 'ReadLater',
                    title: 'Simpan yang penting',
                    description: 'Baca kapan saja, dengan ritme sendiri.',
                    icon: Icons.auto_stories_rounded,
                    accent: Color(0xFFB36F8B),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Koleksi bacaanmu, selalu dekat.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}