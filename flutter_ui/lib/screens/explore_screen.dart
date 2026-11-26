import 'package:flutter/material.dart';

import '../models/public_post.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<PublicPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = PublicApiService.getPosts(limit: 30);
  }

  Future<void> _refresh() async {
    setState(() => _future = PublicApiService.getPosts(limit: 30));
    await _future;
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
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<PublicPost>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    if (snapshot.hasError) {
                      return _ErrorView(
                        message: snapshot.error.toString(),
                        onRetry: _refresh,
                      );
                    }
                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return const Center(child: Text('Belum ada artikel.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: posts.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: theme.colorScheme.outlineVariant),
                      itemBuilder: (context, i) => _PostTile(post: posts[i]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                height: 1.3,
              ),
            ),
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.tags.map((t) => _TagChip(label: t)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Icon(Icons.cloud_off_outlined,
            size: 36, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ),
      ],
    );
  }
}