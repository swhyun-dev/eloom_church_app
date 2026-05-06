import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  final String? token;
  const ApiService({this.token});

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query?.isNotEmpty == true ? query : null);
    final res = await http.get(uri, headers: _headers);
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('응답 형식이 올바르지 않습니다.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception((decoded['message'] as String?) ?? '요청에 실패했습니다. (${res.statusCode})');
    }
    return decoded;
  }

  Future<void> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.delete(uri, headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      throw Exception((decoded['message'] as String?) ?? '삭제에 실패했습니다. (${res.statusCode})');
    }
  }

  static String absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${ApiConfig.baseUrl}$path';
  }
}
