import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../models/topic.dart';
import '../routes/app_routing.dart';
import '../services/crud_service.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late Future<_BookmarksData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BookmarksData> _load() async {
    final results = await Future.wait([
      CrudService.getTopics(),
      CrudService.getBookmarks(),
    ]);
    return _BookmarksData(
      topics: results[0] as List<Topic>,
      bookmarks: results[1] as List<Bookmark>,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _openForm({Bookmark? bookmark, int? preselectedTopicId}) async {
    final result = await Navigator.of(context).pushNamed(
      AppRouting.bookmarkForm,
      arguments: {
        'bookmark': bookmark,
        'preselectedTopicId': preselectedTopicId,
      },
    );
    if (result == true) _refresh();
  }

  Future<void> _delete(Bookmark bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus bookmark?'),
        content: Text('"${bookmark.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await CrudService.deleteBookmark(bookmark.id);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<_BookmarksData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Gagal memuat: ${snapshot.error}'),
                      ),
                    );
                  }
                  final data = snapshot.data!;
                  if (data.bookmarks.isEmpty) {
                    return _EmptyState(
                      onAdd: () => _openForm(
                        preselectedTopicId: data.topics.isNotEmpty
                            ? data.topics.first.id
                            : null,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                      itemCount: data.bookmarks.length,
                      itemBuilder: (context, i) {
                        final b = data.bookmarks[i];
                        return _BookmarkCard(
                          bookmark: b,
                          onTap: () => _openForm(bookmark: b),
                          onDelete: () => _delete(b),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarksData {
  final List<Topic> topics;
  final List<Bookmark> bookmarks;
  _BookmarksData({required this.topics, required this.bookmarks});
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.6,
                      ),
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
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 18,
                  height: 1.3,
                ),
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border,
                size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Belum ada bookmark', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Simpan artikel atau catatan pentingmu di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah bookmark'),
            ),
          ],
        ),
      ),
    );
  }
}