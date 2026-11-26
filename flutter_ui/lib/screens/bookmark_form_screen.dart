import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../models/topic.dart';
import '../services/crud_service.dart';

class BookmarkFormScreen extends StatefulWidget {
  final Bookmark? existing;
  final int? preselectedTopicId;

  const BookmarkFormScreen({
    super.key,
    this.existing,
    this.preselectedTopicId,
  });

  @override
  State<BookmarkFormScreen> createState() => _BookmarkFormScreenState();
}

class _BookmarkFormScreenState extends State<BookmarkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final List<TextEditingController> _keyPointControllers = [];

  List<Topic> _topics = [];
  int? _topicId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final topics = await CrudService.getTopics();
      if (!mounted) return;
      setState(() {
        _topics = topics;
        if (_isEdit) {
          _topicId = widget.existing!.topicId;
          _titleController.text = widget.existing!.title;
          _summaryController.text = widget.existing!.summary;
          _keyPointControllers.addAll(
            widget.existing!.keyPoints
                .map((p) => TextEditingController(text: p)),
          );
        } else {
          _topicId = widget.preselectedTopicId ??
              (topics.isNotEmpty ? topics.first.id : null);
        }
        if (_keyPointControllers.isEmpty) {
          _keyPointControllers.add(TextEditingController());
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint('✗ Gagal load topik: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat daftar topik: $e';
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

    if (!_formKey.currentState!.validate()) {
      debugPrint('✗ Validasi form gagal');
      return;
    }

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

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_isEdit) {
        debugPrint('→ Update bookmark #${widget.existing!.id}');
        await CrudService.updateBookmark(
          widget.existing!.id,
          topicId: _topicId,
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          keyPoints: keyPoints,
        );
      } else {
        debugPrint('→ Create bookmark');
        await CrudService.createBookmark(
          topicId: _topicId!,
          title: _titleController.text.trim(),
          summary: _summaryController.text.trim(),
          keyPoints: keyPoints,
        );
      }

      debugPrint('✓ Bookmark tersimpan');

      if (!mounted) return;
      Navigator.of(context).pop(true);
      return; // guard: jangan eksekusi finally pada widget yang sudah di-pop
    } catch (e) {
      debugPrint('✗ Gagal simpan: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit bookmark' : 'Bookmark baru'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    Text(
                      _isEdit ? 'Perbarui catatanmu' : 'Simpan yang penting',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),

                    // Topik
                    DropdownButtonFormField<int>(
                      value: _topicId,
                      decoration: const InputDecoration(
                        labelText: 'Topik',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      items: _topics
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              ))
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (v) => setState(() => _topicId = v),
                      validator: (v) =>
                          v == null ? 'Topik wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),

                    // Judul
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        labelText: 'Judul artikel',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Judul wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Ringkasan
                    TextFormField(
                      controller: _summaryController,
                      maxLines: 4,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        labelText: 'Ringkasan',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Ringkasan wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 24),

                    // Poin penting
                    Row(
                      children: [
                        Expanded(
                          child: Text('Poin penting',
                              style: theme.textTheme.titleSmall),
                        ),
                        TextButton.icon(
                          onPressed: _saving ? null : _addKeyPoint,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._keyPointControllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: entry.value,
                                enabled: !_saving,
                                decoration: InputDecoration(
                                  hintText: 'Poin ${i + 1}',
                                  prefixIcon: const Icon(Icons.circle, size: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: (!_saving &&
                                      _keyPointControllers.length > 1)
                                  ? () => _removeKeyPoint(i)
                                  : null,
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Error inline
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline,
                              size: 18, color: theme.colorScheme.error),
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

                    const SizedBox(height: 24),

                    // Tombol simpan
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                            : Text(_isEdit ? 'Simpan perubahan' : 'Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}