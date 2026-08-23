import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_iam/flutter_iam.dart';
import 'package:flutter_test/flutter_test.dart';

class _RefreshProvider implements AuthProviderPort {
  @override
  Future<IamResult<Session>> startAuth(IamConfig config) async {
    return const IamResult.err(UnsupportedProvider());
  }

  @override
  Future<IamResult<Session>> exchangeCode(
    IamConfig config, {
    required Uri redirect,
  }) async {
    return const IamResult.err(UnsupportedProvider());
  }

  @override
  Future<IamResult<Session>> refresh(
    IamConfig config, {
    required String refreshToken,
  }) async {
    return IamResult.ok(
      Session(
        isAuthenticated: true,
        accessToken: 'new-token',
        refreshToken: 'r2',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<IamResult<void>> revoke(
    IamConfig config, {
    String? accessToken,
    String? refreshToken,
  }) async {
    return const IamResult<void>.ok(null);
  }
}

class _Adapter implements HttpClientAdapter {
  int calls = 0;
  final auths = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls += 1;
    auths.add(options.headers['Authorization'] as String?);
    if (calls == 1) {
      return ResponseBody.fromString(
        '{"detail":"expired"}',
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late IamConfig config;
  late SessionService session;
  late TokenService tokens;
  late Dio dio;
  late _Adapter adapter;

  setUp(() {
    config = IamConfig(issuer: Uri.parse('http://127.0.0.1:8000'));
    session = SessionService();
    final storage = MemoryTokenStorage();
    tokens = TokenService(
      config: config,
      provider: _RefreshProvider(),
      storage: storage,
    );
    dio = Dio();
    adapter = _Adapter();
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(
        session: session,
        tokens: tokens,
        config: config,
        dio: dio,
      ),
    );
  });

  test('attaches bearer token', () async {
    session.set(
      Session(
        isAuthenticated: true,
        accessToken: 'abc',
        refreshToken: 'r1',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    adapter.calls = 1; // skip 401 branch
    await dio.getUri(Uri.parse('http://127.0.0.1:8000/v1/predict/samples'));
    expect(adapter.auths.single, 'Bearer abc');
  });

  test('refreshes and retries once on 401', () async {
    session.set(
      Session(
        isAuthenticated: true,
        accessToken: 'old',
        refreshToken: 'r1',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    final res =
        await dio.getUri(Uri.parse('http://127.0.0.1:8000/phishing/samples'));
    expect(res.statusCode, 200);
    expect(adapter.calls, 2);
    expect(adapter.auths.first, 'Bearer old');
    expect(adapter.auths.last, 'Bearer new-token');
    expect(session.current.accessToken, 'new-token');
  });
}
