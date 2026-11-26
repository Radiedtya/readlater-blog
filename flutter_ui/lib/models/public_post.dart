class PublicPost {
  final int id;
  final String title;
  final List<String> tags;

  const PublicPost({required this.id, required this.title, required this.tags});

  factory PublicPost.fromJson(Map<String, dynamic> json) => PublicPost(
        id: json['id'] as int,
        title: json['title'] as String,
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}