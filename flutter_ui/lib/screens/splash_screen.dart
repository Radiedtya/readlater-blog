import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_added_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('ReadLater', style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Simpan yang penting. Baca kapan saja.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}