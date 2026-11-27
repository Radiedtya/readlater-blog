import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_brand.dart';
import '../widgets/editorial_visuals.dart';
import '../widgets/reading_loader.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscure = true;
  String? _error;

  /// Password berubah hanya kalau salah satu field password diisi
  bool get _wantsPasswordChange =>
      _currentPasswordController.text.isNotEmpty ||
      _newPasswordController.text.isNotEmpty ||
      _confirmPasswordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.me();
    if (!mounted) return;
    if (user == null) {
      setState(() {
        _error = 'Gagal memuat data profil.';
        _loading = false;
      });
      return;
    }
    _nameController.text = user.name;
    _emailController.text = user.email;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      debugPrint('✗ Validasi form gagal');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final updated = await AuthService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        currentPassword: _wantsPasswordChange
            ? _currentPasswordController.text
            : null,
        newPassword: _wantsPasswordChange ? _newPasswordController.text : null,
        newPasswordConfirmation: _wantsPasswordChange
            ? _confirmPasswordController.text
            : null,
      );

      debugPrint('✓ Profil diperbarui: ${updated.email}');

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      debugPrint('✗ AuthException: ${e.message}');
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      debugPrint('✗ Error: $e');
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppBrand(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: const EditorialBackdrop(palette: EditorialPalette.account),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _loading
                ? const ReadingLoader(
                    key: ValueKey('profile-loading'),
                    label: 'Memuat profil...',
                  )
                : SafeArea(
                    key: const ValueKey('profile-form'),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            const ReadingHero(
                              eyebrow: 'Akun pembaca',
                              title: 'Sesuaikan profilmu',
                              description: 'Perbarui informasi akun dan jaga keamanan kata sandi.',
                              icon: Icons.manage_accounts_outlined,
                              accent: Color(0xFF8173AE),
                              compact: true,
                            ),
                            const SizedBox(height: 24),
                            // ===== Section: Data profil =====
                            _SectionHeader(label: 'DATA PROFIL'),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              enabled: !_saving,
                              decoration: const InputDecoration(
                                labelText: 'Nama lengkap',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Nama wajib diisi';
                                if (value.length > 255)
                                  return 'Nama terlalu panjang';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_saving,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Email wajib diisi';
                                final regex = RegExp(
                                  r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$',
                                );
                                if (!regex.hasMatch(value)) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // ===== Section: Ubah kata sandi =====
                            _SectionHeader(label: 'UBAH KATA SANDI (OPSIONAL)'),
                            const SizedBox(height: 8),
                            Text(
                              'Biarkan kosong jika tidak ingin mengganti kata sandi.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _currentPasswordController,
                              obscureText: _obscure,
                              enabled: !_saving,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Kata sandi saat ini',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) {
                                if (!_wantsPasswordChange) return null;
                                if ((v ?? '').isEmpty) {
                                  return 'Kata sandi saat ini wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: _obscure,
                              enabled: !_saving,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Kata sandi baru',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (v) {
                                if (!_wantsPasswordChange) return null;
                                final value = v ?? '';
                                if (value.isEmpty)
                                  return 'Kata sandi baru wajib diisi';
                                if (value.length < 8)
                                  return 'Minimal 8 karakter';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscure,
                              enabled: !_saving,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Konfirmasi kata sandi baru',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (v) {
                                if (!_wantsPasswordChange) return null;
                                if ((v ?? '').isEmpty) {
                                  return 'Konfirmasi kata sandi wajib diisi';
                                }
                                if (v != _newPasswordController.text) {
                                  return 'Kata sandi tidak cocok';
                                }
                                return null;
                              },
                            ),

                            // ===== Error =====
                            if (_error != null) ...[
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 18,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 32),

                            // ===== Tombol simpan =====
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _saving ? null : _save,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Simpan perubahan'),
                              ),
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

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w600),
    );
  }
}
