import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/public_post.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';
import '../widgets/search_field.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<PublicPost>? _posts;
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await PublicApiService.getPosts(
        limit: 30,
        q: _query.isEmpty ? null : _query,
      );
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('⚠ Explore load gagal: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == _query) {
      setState(() {});
      return;
    }
    setState(() => _query = trimmed);
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    if (_query.isEmpty) {
      setState(() {});
      return;
    }
    setState(() => _query = '');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparan agar gradasi terlihat
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jelajah', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text(
                    'Artikel pilihan dari komunitas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SearchField(
                    controller: _searchController,
                    hintText: 'Cari artikel',
                    onChanged: _onSearchChanged,
                    onSubmitted: (v) => _onSearchChanged(v),
                    onClear: _searchController.text.isEmpty
                        ? null
                        : _clearSearch,
                  ),
                ],
              ),
            ),
            if (_loading && _posts != null)
              LinearProgressIndicator(
                minHeight: 2,
                color: theme.colorScheme.primary,
                backgroundColor: Colors.transparent,
              ),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading && _posts == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_error != null) {
      return Center(child: Text('Gagal memuat: $_error'));
    }

    final posts = _posts ?? const <PublicPost>[];

    if (posts.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty
              ? 'Belum ada artikel.'
              : 'Tidak ada hasil untuk "$_query".',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          24,
          8,
          24,
          120,
        ), // Padding bawah untuk navbar
        itemCount: posts.length,
        itemBuilder: (context, i) => _SoftPostCard(post: posts[i]),
      ),
    );
  }
}

// --- Kartu Artikel Soft UI ---
class _SoftPostCard extends StatelessWidget {
  final PublicPost post;
  const _SoftPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () =>
          Navigator.of(context)
              .pushNamed(AppRouting.detail, arguments: post.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: theme.textTheme.titleLarge?.copyWith(height: 1.3),
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0EB), // Warna peach soft
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(
                              0xFFD87A59,
                            ), // Warna teks oranye redup
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
