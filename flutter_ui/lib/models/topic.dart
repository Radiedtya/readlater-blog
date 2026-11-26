class Topic {
  final int id;
  final String name;
  final String slug;
  final int bookmarksCount;

  const Topic({
    required this.id,
    required this.name,
    required this.slug,
    this.bookmarksCount = 0,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        bookmarksCount: (json['bookmarks_count'] as int?) ?? 0,
      );
}