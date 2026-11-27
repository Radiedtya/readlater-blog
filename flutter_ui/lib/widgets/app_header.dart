import 'dart:async';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../services/user_profile_store.dart';
import 'app_brand.dart';
import 'profile_avatar.dart';

enum _ProfileMenuAction { profile, logout }

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  late final Future<User?> _userFuture;
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _userFuture = UserProfileStore.instance.load();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _dateLabel(DateTime date) {
    const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _timeLabel(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk kembali untuk mengakses akun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouting.login, (route) => false);
  }

  void _onMenuSelected(_ProfileMenuAction action) {
    switch (action) {
      case _ProfileMenuAction.profile:
        Navigator.of(context).pushNamed(AppRouting.profile);
        return;
      case _ProfileMenuAction.logout:
        unawaited(_logout());
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          const AppBrand(),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _dateLabel(_now),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF777168),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _timeLabel(_now),
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: UserProfileStore.instance,
            builder: (context, _) => FutureBuilder<User?>(
              future: _userFuture,
              builder: (context, snapshot) {
                final user = UserProfileStore.instance.user ?? snapshot.data;
                final initials = user?.name.trim().isNotEmpty == true
                    ? user!.name.trim().characters.first.toUpperCase()
                    : '?';
                return PopupMenuButton<_ProfileMenuAction>(
                  tooltip: 'Menu akun',
                  onSelected: _onMenuSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<_ProfileMenuAction>(
                      value: _ProfileMenuAction.profile,
                      enabled: false,
                      height: 66,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.name ??
                                (snapshot.hasError
                                    ? 'Profil tidak tersedia'
                                    : snapshot.connectionState ==
                                          ConnectionState.waiting
                                    ? 'Memuat akun...'
                                    : 'Pengguna'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF25241F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ??
                                (snapshot.hasError
                                    ? 'Periksa koneksi lalu coba lagi'
                                    : ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF777168),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: _ProfileMenuAction.profile,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.person_outline_rounded, size: 20),
                        title: Text('Profil'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: _ProfileMenuAction.logout,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.logout_rounded, size: 20),
                        title: Text('Keluar'),
                      ),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileAvatar(
                        initials: initials,
                        imageUrl: user?.profileImageUrl,
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF777168),
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
