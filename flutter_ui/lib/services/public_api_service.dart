import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/public_post.dart';
import '../models/public_post_detail.dart';

class PublicApiService {
  static Future<List<PublicPost>> getPosts({
    int limit = 30,
    int skip = 0,
    String? q,
  }) async {
    final uri = Uri.parse('${ApiConstant.baseUrl}${ApiConstant.publicPosts}')
        .replace(queryParameters: {
      'limit': limit.toString(),
      'skip': skip.toString(),
      if (q != null && q.isNotEmpty) 'q': q,
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat artikel (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => PublicPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<PublicPostDetail> getPost(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConstant.baseUrl}${ApiConstant.publicPost(id)}'),
      headers: {'Accept': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat artikel (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return PublicPostDetail.fromJson(body['data'] as Map<String, dynamic>);
  }
}