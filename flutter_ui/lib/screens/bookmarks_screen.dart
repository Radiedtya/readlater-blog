import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../routes/app_routing.dart';
import '../services/crud_service.dart';
import '../state/bookmark_events.dart';
import '../widgets/editorial_visuals.dart';
import '../widgets/search_field.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

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
      final bookmarks = await CrudService.getBookmarks(
        q: _query.isEmpty ? null : _query,
      );
      if (!mounted) return;
      setState(() {
        _bookmarks = bookmarks;
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

  Future<void> _openForm({Bookmark? bookmark}) async {
    final result = await Navigator.of(context)
        .pushNamed(AppRouting.bookmarkForm, arguments: {'bookmark': bookmark});
    debugPrint('← Form ditutup, result=$result');
    if (!mounted) return;
    if (result == true) await _load();
  }

  Future<void> _openBookmark(Bookmark bookmark) async {
    final result = await Navigator.of(context)
        .pushNamed(AppRouting.bookmarkDetail, arguments: bookmark);
    if (!mounted) return;
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('"${bookmark.title}" dihapus')));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, // Biar gradasi HomeScreen tembus
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 104),
        child: FloatingActionButton(
          onPressed: () => _openForm(),
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tersimpan', style: theme.textTheme.displaySmall),
                      const SizedBox(height: 4),
                      Text(
                        'Koleksi pribadimu',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const ReadingHero(
                        eyebrow: 'Ruang bacaanmu',
                        title: 'Simpan untuk nanti',
                        description:
                            'Semua catatan penting tersusun di satu tempat.',
                        icon: Icons.bookmark_added_outlined,
                        accent: Color(0xFF8270B2),
                        compact: true,
                      ),
                      const SizedBox(height: 20),
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
              ),
              if (_loading && _bookmarks != null)
                SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: theme.colorScheme.primary,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              if (_loading && _bookmarks == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 36,
                            color: Colors.black38,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _load,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if ((_bookmarks ?? const <Bookmark>[]).isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    isSearch: _query.isNotEmpty,
                    query: _query,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final bookmark = _bookmarks![i];
                      return _BookmarkCard(
                        bookmark: bookmark,
                        onTap: () => _openBookmark(bookmark),
                        onDelete: () => _delete(bookmark),
                      );
                    }, childCount: _bookmarks!.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== Komponen pendukung ==================

class _EmptyState extends StatelessWidget {
  final bool isSearch;
  final String query;

  const _EmptyState({required this.isSearch, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearch ? Icons.search_off_outlined : Icons.bookmark_border,
              size: 40,
              color: Colors.black38,
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
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
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
        color: Colors.white.withOpacity(0.7), // Efek kaca transparan
        borderRadius: BorderRadius.circular(24), // Lebih membulat
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bookmark.topic?.name.toUpperCase() ?? 'TANPA TOPIK',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFD87A59), // Warna aksen peach
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.black38,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  bookmark.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bookmark.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                if (bookmark.keyPoints.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bookmark.keyPoints.take(3).map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EFFF), // Warna lavender soft
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          p,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.indigo.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
