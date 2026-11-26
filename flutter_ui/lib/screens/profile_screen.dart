import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';

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
    final result =
        await Navigator.of(context).pushNamed(AppRouting.editProfile);
    debugPrint('← Edit profil ditutup, result=$result');
    if (result == true) await _refresh();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content:
            const Text('Kamu perlu masuk kembali untuk mengakses bookmark.'),
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
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouting.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<User?>(
            key: ValueKey(_refreshCounter),
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2));
              }
              final user = snapshot.data;
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                children: [
                  Text('Profil', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 24),

                  // ==== Kartu profil ====
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border:
                          Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          child: Text(
                            (user != null && user.name.isNotEmpty)
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Pengguna',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '-',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
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
                  OutlinedButton.icon(
                    onPressed: _openEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit profil'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Keluar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}