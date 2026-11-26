import 'package:flutter/material.dart';

import '../models/public_post_detail.dart';
import '../services/public_api_service.dart';

class DetailScreen extends StatefulWidget {
  final int postId;
  const DetailScreen({super.key, required this.postId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<PublicPostDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = PublicApiService.getPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<PublicPostDetail>(
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
          final post = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    height: 1.25,
                  ),
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
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
                              child: Text(t,
                                  style: theme.textTheme.labelSmall),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Meta(icon: Icons.visibility_outlined, label: '${post.views}'),
                    const SizedBox(width: 16),
                    _Meta(icon: Icons.favorite_border, label: '${post.likes}'),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 20),
                Text(
                  post.body,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ],
            ),
          );
        },
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