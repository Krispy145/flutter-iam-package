import 'dart:async';

import 'package:dio/dio.dart';

import '../../core/iam_config.dart';
import '../../domain/entities/session.dart';
import '../../domain/services/session_service.dart';
import '../../domain/services/token_service.dart';

bool isAuthEndpoint(Uri uri) {
  final path = uri.path;
  return path.contains('/auth/login') ||
      path.contains('/auth/token') ||
      path.contains('/auth/refresh') ||
      path.contains('/auth/logout');
}

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.session,
    required this.tokens,
    required this.config,
    required Dio dio,
  }) : _dio = dio;

  final SessionService session;
  final TokenService tokens;
  final IamConfig config;
  final Dio _dio;
  Completer<void>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isAuthEndpoint(options.uri)) {
      final token = session.current.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final alreadyRetried = err.requestOptions.extra['auth_retried'] == true;
    if (err.response?.statusCode != 401 ||
        alreadyRetried ||
        isAuthEndpoint(err.requestOptions.uri)) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      handler.next(err);
      return;
    }

    final token = session.current.accessToken;
    final req = err.requestOptions;
    req.extra['auth_retried'] = true;
    if (token != null) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    try {
      handler.resolve(await _dio.fetch(req));
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  Future<bool> _refreshOnce() async {
    final existing = _refreshing;
    if (existing != null) {
      await existing.future;
      return session.current.isAuthenticated;
    }
    final completer = Completer<void>();
    _refreshing = completer;
    try {
      final current = session.current;
      if (!current.isAuthenticated) return false;
      final result = await tokens.refreshNow(current);
      if (result.isOk && result.value != null) {
        session.set(result.value!);
        return true;
      }
      session.set(const Session(isAuthenticated: false));
      return false;
    } finally {
      completer.complete();
      _refreshing = null;
    }
  }
}
