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
      setState(() {}); // update suffix clear icon
      return;
    }
    setState(() => _query = trimmed);
    _debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed == _query) return;
    setState(() => _query = trimmed);
    _load();
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
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchField(
                    controller: _searchController,
                    hintText: 'Cari artikel',
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    onClear: _searchController.text.isEmpty
                        ? null
                        : _clearSearch,
                  ),
                ],
              ),
            ),
            // Subtle loading indicator saat re-search (data lama tetap tampil)
            if (_loading && _posts != null)
              LinearProgressIndicator(
                minHeight: 2,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.outlineVariant,
              ),
            Expanded(child: _buildBody(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    // Initial load
    if (_loading && _posts == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    // Error
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Icon(Icons.cloud_off_outlined,
              size: 36, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: _load,
              child: const Text('Coba lagi'),
            ),
          ),
        ],
      );
    }

    final posts = _posts ?? const <PublicPost>[];

    // Empty state
    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Icon(
            _query.isEmpty
                ? Icons.article_outlined
                : Icons.search_off_outlined,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            _query.isEmpty
                ? 'Belum ada artikel.'
                : 'Tidak ada hasil untuk "$_query".',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Data
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: posts.length,
        separatorBuilder: (_, __) =>
            Divider(color: theme.colorScheme.outlineVariant),
        itemBuilder: (context, i) => _PostTile(post: posts[i]),
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  final PublicPost post;
  const _PostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed(AppRouting.detail, arguments: post.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontSize: 20, height: 1.3),
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.tags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(t, style: theme.textTheme.labelSmall),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}