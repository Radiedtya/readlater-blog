import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../widgets/app_brand.dart';
import '../widgets/editorial_visuals.dart';
import '../widgets/reading_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = entrance;
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(entrance);
    _entranceController.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 1900)),
      AuthService.isLoggedIn(),
    ]);
    final loggedIn = results[1] as bool;
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacementNamed(loggedIn ? AppRouting.home : AppRouting.login);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
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
                      const SizedBox(height: 32),
                      const ReadingLoader(
                        label: 'Menyiapkan bacaanmu...',
                        accent: Color(0xFFB36F8B),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
