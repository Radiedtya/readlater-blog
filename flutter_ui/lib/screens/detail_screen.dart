import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/public_post_detail.dart';
import '../models/topic.dart';
import '../services/crud_service.dart';
import '../services/public_api_service.dart';
import '../state/bookmark_events.dart';
import '../widgets/app_brand.dart';
import '../widgets/editorial_visuals.dart';

class DetailScreen extends StatefulWidget {
  final int postId;
  const DetailScreen({super.key, required this.postId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<PublicPostDetail> _future;
  PublicPostDetail? _loadedPost;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<PublicPostDetail> _fetch() async {
    // Ambil post & status tersimpan secara paralel.
    final results = await Future.wait([
      PublicApiService.getPost(widget.postId),
      CrudService.isSourceSaved(widget.postId.toString()),
    ]);
    final post = results[0] as PublicPostDetail;
    final saved = results[1] as bool;

    if (mounted) {
      setState(() {
        _loadedPost = post;
        _saved = saved;
      });
    }
    return post;
  }

  Future<void> _openSaveSheet() async {
    final post = _loadedPost;
    if (post == null) return;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _SaveBookmarkSheet(
          post: post,
          sourceId: widget.postId.toString(), // ← kirim source_id
        ),
      ),
    );

    if (saved == true && mounted) {
      setState(() => _saved = true);
      BookmarkEvents.instance.notifyChanged();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Disimpan ke bookmark')));
    }
  }

  void _showAlreadySavedMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Artikel ini sudah disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const AppBrand(),
        actions: [
          IconButton(
            icon: Icon(
              _saved ? Icons.bookmark : Icons.bookmark_border,
              color: _saved ? theme.colorScheme.primary : null,
            ),
            tooltip: _saved ? 'Sudah disimpan' : 'Simpan ke bookmark',
            onPressed: _loadedPost == null
                ? null
                : (_saved ? _showAlreadySavedMessage : _openSaveSheet),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: const EditorialBackdrop(palette: EditorialPalette.article),
          ),
          FutureBuilder<PublicPostDetail>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Gagal memuat: ${snapshot.error}'),
                  ),
                );
              }
              final post = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReadingHero(
                      eyebrow: 'Bacaan komunitas',
                      title: 'Satu cerita, banyak sudut pandang',
                      description: 'Luangkan waktu untuk membaca dan menemukan ide.',
                      icon: Icons.auto_stories_outlined,
                      accent: Color(0xFF6385B7),
                      compact: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      post.title,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 30,
                        height: 1.25,
                      ),
                    ),
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF0EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFD87A59),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _Meta(
                          icon: Icons.visibility_outlined,
                          label: '${post.views}',
                        ),
                        const SizedBox(width: 16),
                        _Meta(
                          icon: Icons.favorite_border,
                          label: '${post.likes}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
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
                      child: Text(
                        post.body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ============ BOTTOM SHEET: Form Simpan ============

class _SaveBookmarkSheet extends StatefulWidget {
  final PublicPostDetail post;
  final String sourceId; // ← baru

  const _SaveBookmarkSheet({required this.post, required this.sourceId});

  @override
  State<_SaveBookmarkSheet> createState() => _SaveBookmarkSheetState();
}

class _SaveBookmarkSheetState extends State<_SaveBookmarkSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  final List<TextEditingController> _keyPointControllers = [];

  List<Topic> _topics = [];
  int? _topicId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.post.title);

    final body = widget.post.body.replaceAll(RegExp(r'\s+'), ' ').trim();
    final summaryText = body.length > 300
        ? '${body.substring(0, 300).trimRight()}…'
        : body;
    _summaryController = TextEditingController(text: summaryText);

    for (final tag in widget.post.tags.take(5)) {
      _keyPointControllers.add(TextEditingController(text: tag));
    }
    if (_keyPointControllers.isEmpty) {
      _keyPointControllers.add(TextEditingController());
    }

    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final topics = await CrudService.getTopics();
      if (!mounted) return;
      setState(() {
        _topics = topics;
        _topicId = topics.isNotEmpty ? topics.first.id : null;
        _loading = false;
      });
    } catch (e) {
      debugPrint('✗ Gagal load topik: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat topik: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    for (final c in _keyPointControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addKeyPoint() {
    setState(() => _keyPointControllers.add(TextEditingController()));
  }

  void _removeKeyPoint(int i) {
    setState(() {
      _keyPointControllers[i].dispose();
      _keyPointControllers.removeAt(i);
      if (_keyPointControllers.isEmpty) {
        _keyPointControllers.add(TextEditingController());
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final keyPoints = _keyPointControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (_topicId == null) {
      setState(() => _error = 'Pilih topik terlebih dahulu.');
      return;
    }
    if (keyPoints.isEmpty) {
      setState(() => _error = 'Tambahkan minimal satu poin penting.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await CrudService.createBookmark(
        topicId: _topicId!,
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        keyPoints: keyPoints,
        sourceId: widget.sourceId, // ← kirim source_id
      );
      debugPrint(
        '✓ Bookmark dari detail tersimpan (source_id=${widget.sourceId})',
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('✗ Gagal simpan: $e');
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Simpan ke bookmark',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 22,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 20),
                            tooltip: 'Tutup',
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ReadingHero(
                                eyebrow: 'Tambahkan ke koleksi',
                                title: 'Simpan bacaan ini',
                                description:
                                    'Tulis ringkasan dan poin yang ingin diingat.',
                                icon: Icons.bookmark_add_outlined,
                                accent: Color(0xFF648D72),
                                compact: true,
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<int>(
                                value: _topicId,
                                decoration: const InputDecoration(
                                  labelText: 'Topik',
                                  prefixIcon: Icon(Icons.sell_outlined),
                                ),
                                items: _topics
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t.id,
                                        child: Text(t.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _saving
                                    ? null
                                    : (v) => setState(() => _topicId = v),
                                validator: (v) =>
                                    v == null ? 'Topik wajib dipilih' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _titleController,
                                enabled: !_saving,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Judul',
                                  prefixIcon: Icon(Icons.title),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Judul wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _summaryController,
                                enabled: !_saving,
                                maxLines: 4,
                                minLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Ringkasan',
                                  alignLabelWithHint: true,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Ringkasan wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Poin penting',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _saving ? null : _addKeyPoint,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Tambah'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ..._keyPointControllers.asMap().entries.map((
                                entry,
                              ) {
                                final i = entry.key;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: entry.value,
                                          enabled: !_saving,
                                          decoration: InputDecoration(
                                            hintText: 'Poin ${i + 1}',
                                            prefixIcon: const Icon(
                                              Icons.circle,
                                              size: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed:
                                            (!_saving &&
                                                _keyPointControllers.length > 1)
                                            ? () => _removeKeyPoint(i)
                                            : null,
                                        icon: const Icon(Icons.close, size: 18),
                                        tooltip: 'Hapus poin',
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (_error != null) ...[
                                const SizedBox(height: 4),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _saving ? null : _save,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
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
                                  : const Text('Simpan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
