import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../widgets/editorial_visuals.dart';
import '../widgets/reading_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _future;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _future = AuthService.me();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final future = AuthService.me();
    setState(() {
      _future = future;
      _refreshCounter++;
    });
    try {
      await future;
    } catch (e) {
      debugPrint('⚠ Refresh profile gagal: $e');
    }
  }

  Future<void> _openEdit() async {
    final result = await Navigator.of(context)
        .pushNamed(AppRouting.editProfile);
    debugPrint('← Edit profil ditutup, result=$result');
    if (result == true) await _refresh();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu perlu masuk kembali untuk mengakses bookmark.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouting.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<User?>(
            key: ValueKey(_refreshCounter),
            future: _future,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final user = snapshot.data;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isLoading
                    ? const ReadingLoader(
                        key: ValueKey('profile-loading'),
                        label: 'Memuat profil...',
                      )
                    : ListView(
                        key: const ValueKey('profile-content'),
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                        children: [
                          Text('Profil', style: theme.textTheme.displaySmall),
                          const SizedBox(height: 18),
                          const ReadingHero(
                            eyebrow: 'Akun pembaca',
                            title: 'Ruang pribadimu',
                            description: 'Atur akun dan lanjutkan membaca dengan nyaman.',
                            icon: Icons.person_outline_rounded,
                            accent: Color(0xFFB8874E),
                            compact: true,
                          ),
                          const SizedBox(height: 24),

                          // ==== Kartu profil ====
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFFFFF0EB),
                                  child: Text(
                                    (user != null && user.name.isNotEmpty)
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontSize: 24,
                                          color: const Color(0xFFD87A59),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Pengguna',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user?.email ?? '-',
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==== Aksi ====
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: _openEdit,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Edit profil'),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text('Keluar'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
