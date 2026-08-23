import 'dart:convert';

import 'package:dio/dio.dart';

import '../../domain/ports/http_client.dart';

class DioHttpClient implements HttpClientPort {
  final Dio _dio;

  DioHttpClient([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                validateStatus: (_) => true,
                headers: {'Accept': 'application/json'},
              ),
            );

  Map<String, dynamic> _asMap(dynamic data) {
    if (data == null || data == '') return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = json.decode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return {'raw': data};
  }

  @override
  Future<(int, Map<String, dynamic>)> getJson(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final res = await _dio.getUri(
      url,
      options: Options(headers: headers, validateStatus: (_) => true),
    );
    return (res.statusCode ?? 0, _asMap(res.data));
  }

  @override
  Future<(int, Map<String, dynamic>)> postForm(
    Uri url,
    Map<String, String> form, {
    Map<String, String>? headers,
  }) async {
    final res = await _dio.postUri(
      url,
      data: FormData.fromMap(form),
      options: Options(headers: headers, validateStatus: (_) => true),
    );
    return (res.statusCode ?? 0, _asMap(res.data));
  }

  @override
  Future<(int, Map<String, dynamic>)> postJson(
    Uri url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final res = await _dio.postUri(
      url,
      data: body,
      options: Options(
        headers: {'Content-Type': 'application/json', ...?headers},
        validateStatus: (_) => true,
      ),
    );
    return (res.statusCode ?? 0, _asMap(res.data));
  }
}
