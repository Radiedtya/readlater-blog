import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/bookmark.dart';
import '../models/topic.dart';
import 'auth_service.dart';

class CrudService {
  static Future<List<Topic>> getTopics() async {
    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.topics}'),
      headers: await AuthService.authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat topik (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Bookmark>> getBookmarks({int? topicId, String? q}) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}${ApiConstant.bookmarks}')
        .replace(queryParameters: {
      if (topicId != null) 'topic_id': topicId.toString(),
      if (q != null && q.isNotEmpty) 'q': q,
    });
    final res = await http.get(uri, headers: await AuthService.authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat bookmark (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Bookmark> createBookmark({
    required int topicId,
    required String title,
    required String summary,
    required List<String> keyPoints,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.bookmarks}'),
      headers: await AuthService.authHeaders(),
      body: jsonEncode({
        'topic_id': topicId,
        'title': title,
        'summary': summary,
        'key_points': keyPoints,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 201) {
      throw Exception(body['message'] ?? 'Gagal membuat bookmark');
    }
    return Bookmark.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<Bookmark> updateBookmark(
    int id, {
    int? topicId,
    String? title,
    String? summary,
    List<String>? keyPoints,
  }) async {
    final res = await http.put(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.bookmark(id)}'),
      headers: await AuthService.authHeaders(),
      body: jsonEncode({
        if (topicId != null) 'topic_id': topicId,
        if (title != null) 'title': title,
        if (summary != null) 'summary': summary,
        if (keyPoints != null) 'key_points': keyPoints,
      }),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['message'] ?? 'Gagal mengubah bookmark');
    }
    return Bookmark.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<void> deleteBookmark(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.bookmark(id)}'),
      headers: await AuthService.authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus bookmark (${res.statusCode})');
    }
  }
}