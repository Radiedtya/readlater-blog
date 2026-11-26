import 'topic.dart';

class Bookmark {
  final int id;
  final int topicId;
  final String title;
  final String summary;
  final List<String> keyPoints;
  final Topic? topic;
  final DateTime? createdAt;

  const Bookmark({
    required this.id,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.keyPoints,
    this.topic,
    this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        id: json['id'] as int,
        topicId: json['topic_id'] as int,
        title: json['title'] as String,
        summary: json['summary'] as String,
        keyPoints: (json['key_points'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        topic: json['topic'] != null
            ? Topic.fromJson(json['topic'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );
}