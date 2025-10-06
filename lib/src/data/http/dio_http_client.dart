import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/ports/http_client.dart';

class DioHttpClient implements HttpClientPort {
  final Dio _dio;
  DioHttpClient([Dio? dio]) : _dio = dio ?? Dio();
  @override
  Future<(int, Map<String, dynamic>)> getJson(Uri url, {Map<String, String>? headers}) async {
    final res = await _dio.getUri(url, options: Options(headers: headers));
    return (res.statusCode ?? 0, Map<String, dynamic>.from(res.data is String ? json.decode(res.data) : res.data));
  }
  @override
  Future<(int, Map<String, dynamic>)> postForm(Uri url, Map<String, String> form, {Map<String, String>? headers}) async {
    final res = await _dio.postUri(url, data: FormData.fromMap(form), options: Options(headers: headers));
    return (res.statusCode ?? 0, Map<String, dynamic>.from(res.data is String ? json.decode(res.data) : res.data));
  }
}
