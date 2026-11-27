import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../services/user_profile_store.dart';
import '../widgets/editorial_visuals.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_image_crop_dialog.dart';
import '../widgets/reading_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _future;
  int _refreshCounter = 0;
  bool _uploadingProfileImage = false;

  @override
  void initState() {
    super.initState();
    _future = UserProfileStore.instance.load();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final future = UserProfileStore.instance.load();
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

  Future<void> _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image == null) return;

      if (!mounted) return;
      final imageBytes = await image.readAsBytes();
      if (!mounted) return;
      final croppedImage = await showProfileImageCropDialog(
        context,
        imageBytes,
      );
      if (croppedImage == null || !mounted) return;

      setState(() => _uploadingProfileImage = true);
      final user = await AuthService.uploadProfileImage(croppedImage);
      UserProfileStore.instance.update(user);
      if (!mounted) return;
      setState(() {
        _future = Future.value(user);
        _refreshCounter++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
      );
    } on AuthException catch (error) {
      debugPrint('Gagal mengunggah foto profil: ${error.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error, stackTrace) {
      debugPrint('Gagal memperbarui foto profil: $error\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto profil gagal diperbarui: $error')),
      );
    } finally {
      if (mounted) setState(() => _uploadingProfileImage = false);
    }
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
                              color: Colors.white.withValues(alpha: 0.7),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    ProfileAvatar(
                                      radius: 30,
                                      imageUrl: user?.profileImageUrl,
                                      initials:
                                          (user != null && user.name.isNotEmpty)
                                          ? user.name[0].toUpperCase()
                                          : '?',
                                      onTap: _uploadingProfileImage
                                          ? null
                                          : _pickProfileImage,
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: IgnorePointer(
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF292821),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: _uploadingProfileImage
                                              ? const SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 1.5,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.camera_alt_rounded,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
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

                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8DE),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFFD87A59),
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'IDENTITAS PENGEMBANG',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFB8874E),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Dibuat oleh',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFF1E8), Colors.white],
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD87A59)
                                      .withValues(alpha: 0.1),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFD87A59)
                                                .withValues(alpha: 0.16),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          'https://www.radiedtya.web.id/_next/image?url=%2Fimages%2Fhero-sec%2Fme.jpeg&w=384&q=75',
                                          width: 76,
                                          height: 76,
                                          fit: BoxFit.cover,
                                          semanticLabel:
                                              'Foto Muhammad Radiedtya Pratama',
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    width: 76,
                                                    height: 76,
                                                    color: const Color(
                                                      0xFFFFF0EB,
                                                    ),
                                                    child: const Icon(
                                                      Icons.person_rounded,
                                                      size: 38,
                                                      color: Color(0xFFD87A59),
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Muhammad Radiedtya Pratama',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 7,
                                            runSpacing: 7,
                                            children: [
                                              const _CreatorTag(
                                                icon: Icons.school_rounded,
                                                label: 'XII RPL 1',
                                              ),
                                              const _CreatorTag(
                                                icon: Icons.badge_rounded,
                                                label: 'Absen 15',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFD87A59)
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.link_rounded,
                                            size: 17,
                                            color: Color(0xFFD87A59),
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            'URL Public API',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFF8A6653,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      const SelectableText(
                                        'https://dummyjson.com/posts',
                                        style: TextStyle(
                                          color: Color(0xFF654C3D),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
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

class _CreatorTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CreatorTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB8874E)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF765A47),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
