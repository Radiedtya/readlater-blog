import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/public_post.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';
import '../widgets/editorial_visuals.dart';
import '../widgets/reading_loader.dart';
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
    final posts = _posts ?? const <PublicPost>[];

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparan agar gradasi terlihat
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            children: [
              Text('Jelajah', style: theme.textTheme.displaySmall),
              const SizedBox(height: 4),
              Text(
                'Artikel pilihan dari komunitas',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 18),
              const ReadingHero(
                eyebrow: 'Jelajahi ide baru',
                title: 'Bacaan yang menginspirasi',
                description: 'Temukan cerita dan wawasan pilihan komunitas.',
                icon: Icons.auto_stories_outlined,
                accent: Color(0xFF4F8B77),
                compact: true,
              ),
              const SizedBox(height: 20),
              SearchField(
                controller: _searchController,
                hintText: 'Cari artikel',
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchChanged,
                onClear: _searchController.text.isEmpty ? null : _clearSearch,
              ),
              if (_loading && _posts != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  minHeight: 2,
                  color: theme.colorScheme.primary,
                  backgroundColor: Colors.transparent,
                ),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _loading && _posts == null
                    ? const Padding(
                        key: ValueKey('explore-loading'),
                        padding: EdgeInsets.only(top: 48, bottom: 32),
                        child: ReadingLoader(label: 'Memuat bacaan...'),
                      )
                    : _error != null
                    ? Padding(
                        key: const ValueKey('explore-error'),
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(child: Text('Gagal memuat: $_error')),
                      )
                    : posts.isEmpty
                    ? Padding(
                        key: const ValueKey('explore-empty'),
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(
                          child: Text(
                            _query.isEmpty
                                ? 'Belum ada artikel.'
                                : 'Tidak ada hasil untuk "$_query".',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    : Padding(
                        key: const ValueKey('explore-posts'),
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          children: posts
                              .map((post) => _SoftPostCard(post: post))
                              .toList(),
                        ),
                      ),
              ),
            ],
          ),
        ),
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
            const SizedBox(height: 8),
            Text(
              post.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
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
