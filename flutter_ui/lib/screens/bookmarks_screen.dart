import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../models/topic.dart';
import '../routes/app_routing.dart';
import '../services/crud_service.dart';
import '../state/bookmark_events.dart';
import '../widgets/search_field.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Topic> _topics = [];
  List<Bookmark>? _bookmarks;
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    BookmarkEvents.instance.addListener(_onBookmarkChanged);
    _load();
  }

  @override
  void dispose() {
    BookmarkEvents.instance.removeListener(_onBookmarkChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Dipanggil saat ada sinyal "bookmark berubah" dari screen lain
  /// (misal user baru simpan dari DetailScreen).
  void _onBookmarkChanged() {
    if (!mounted) return;
    debugPrint('→ BookmarkEvents: reload bookmark list');
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        CrudService.getTopics(),
        CrudService.getBookmarks(q: _query.isEmpty ? null : _query),
      ]);
      if (!mounted) return;
      setState(() {
        _topics = results[0] as List<Topic>;
        _bookmarks = results[1] as List<Bookmark>;
        _loading = false;
      });
    } catch (e) {
      debugPrint('⚠ Bookmarks load gagal: $e');
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

  Future<void> _openForm({Bookmark? bookmark, int? preselectedTopicId}) async {
    final result = await Navigator.of(context).pushNamed(
      AppRouting.bookmarkForm,
      arguments: {
        'bookmark': bookmark,
        'preselectedTopicId': preselectedTopicId,
      },
    );
    debugPrint('← Form ditutup, result=$result');
    if (!mounted) return;
    // Refresh jika form menyimpan perubahan (tambah/edit)
    if (result == true) await _load();
  }

  Future<void> _delete(Bookmark bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus bookmark?'),
        content: Text('"${bookmark.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await CrudService.deleteBookmark(bookmark.id);
      debugPrint('✓ Bookmark #${bookmark.id} dihapus');
    } catch (e) {
      debugPrint('✗ Gagal hapus: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${bookmark.title}" dihapus')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tersimpan', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text(
                    'Koleksi pribadimu',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchField(
                    controller: _searchController,
                    hintText: 'Cari bookmark',
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    onClear: _searchController.text.isEmpty
                        ? null
                        : _clearSearch,
                  ),
                ],
              ),
            ),
            if (_loading && _bookmarks != null)
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
    if (_loading && _bookmarks == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

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

    final bookmarks = _bookmarks ?? const <Bookmark>[];

    if (bookmarks.isEmpty) {
      return _EmptyState(
        isSearch: _query.isNotEmpty,
        query: _query,
        onAdd: () => _openForm(
          preselectedTopicId:
              _topics.isNotEmpty ? _topics.first.id : null,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
        itemCount: bookmarks.length,
        itemBuilder: (context, i) {
          final b = bookmarks[i];
          return _BookmarkCard(
            bookmark: b,
            onTap: () => _openForm(bookmark: b),
            onDelete: () => _delete(b),
          );
        },
      ),
    );
  }
}

// ================== Komponen pendukung ==================

class _EmptyState extends StatelessWidget {
  final bool isSearch;
  final String query;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.isSearch,
    required this.query,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Icon(
          isSearch ? Icons.search_off_outlined : Icons.bookmark_border,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        Text(
          isSearch ? 'Tidak ada hasil' : 'Belum ada bookmark',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          isSearch
              ? 'Tidak ada bookmark yang cocok dengan "$query".'
              : 'Simpan artikel atau catatan pentingmu di sini.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (!isSearch) ...[
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah bookmark'),
            ),
          ),
        ],
      ],
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bookmark.topic?.name ?? 'Tanpa topik',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(letterSpacing: 0.6),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    color: theme.colorScheme.onSurfaceVariant,
                    tooltip: 'Hapus',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                bookmark.title,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontSize: 18, height: 1.3),
              ),
              const SizedBox(height: 8),
              Text(
                bookmark.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (bookmark.keyPoints.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: bookmark.keyPoints.take(3).map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(p, style: theme.textTheme.labelSmall),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}