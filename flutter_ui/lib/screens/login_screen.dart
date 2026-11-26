import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) {
      debugPrint('✗ Form validasi gagal');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint('✓ Login sebagai: ${user.name} <${user.email}>');

      if (!mounted) {
        debugPrint('⚠ Widget tidak mounted, batal navigasi');
        return;
      }

      // Pastikan token benar-benar tersimpan sebelum pindah
      final savedToken = await AuthService.getToken();
      debugPrint(
        '✓ Verifikasi token: ${savedToken == null ? "KOSONG" : "${savedToken.length} char"}',
      );

      if (savedToken == null || savedToken.isEmpty) {
        throw AuthException('Token tidak tersimpan. Coba login ulang.');
      }

      debugPrint('→ Navigasi ke ${AppRouting.home}');
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRouting.home,
        (route) => false,
      );
      debugPrint('✓ pushNamedAndRemoveUntil selesai');
    } on AuthException catch (e) {
      debugPrint('✗ AuthException: ${e.message}');
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e, st) {
      debugPrint('✗ Error tak terduga: $e');
      debugPrint('$st');
      if (!mounted) return;
      setState(() => _error = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.bookmark_added_outlined,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text('Masuk', style: theme.textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Lanjutkan membaca koleksimu.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),

                // ---- Email ----
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Email wajib diisi';
                    if (value.length > 255) return 'Email terlalu panjang';
                    final regex = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');
                    if (!regex.hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---- Password ----
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Kata sandi',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Kata sandi wajib diisi';
                    if (value.length < 8) return 'Minimal 8 karakter';
                    return null;
                  },
                ),

                // ---- Error ----
                if (_error != null) ...[
                  const SizedBox(height: 16),
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 28),

                // ---- Submit ----
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Masuk'),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context)
                            .pushReplacementNamed(AppRouting.register),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}