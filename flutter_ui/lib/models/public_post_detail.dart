class PublicPostDetail {
  final int id;
  final String title;
  final String body;
  final List<String> tags;
  final int views;
  final int likes;
  final int dislikes;

  const PublicPostDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.views,
    required this.likes,
    required this.dislikes,
  });

  factory PublicPostDetail.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'] as Map<String, dynamic>? ?? {};
    return PublicPostDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      views: (json['views'] as int?) ?? 0,
      likes: (reactions['likes'] as int?) ?? 0,
      dislikes: (reactions['dislikes'] as int?) ?? 0,
    );
  }
}