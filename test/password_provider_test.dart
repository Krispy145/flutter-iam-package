import 'package:flutter_iam/flutter_iam.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHttp implements HttpClientPort {
  FakeHttp(this.handler);

  final Future<(int, Map<String, dynamic>)> Function(
    String method,
    Uri url,
    Map<String, dynamic>? body,
  ) handler;

  @override
  Future<(int, Map<String, dynamic>)> getJson(
    Uri url, {
    Map<String, String>? headers,
  }) {
    return handler('GET', url, null);
  }

  @override
  Future<(int, Map<String, dynamic>)> postForm(
    Uri url,
    Map<String, String> form, {
    Map<String, String>? headers,
  }) {
    return handler('POST', url, form);
  }

  @override
  Future<(int, Map<String, dynamic>)> postJson(
    Uri url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) {
    return handler('POST', url, body);
  }
}

void main() {
  final config = IamConfig(issuer: Uri.parse('http://127.0.0.1:8000'));

  test('login stores access and refresh tokens', () async {
    final http = FakeHttp((method, url, body) async {
      expect(url.path, '/v1/auth/login');
      expect(body?['username'], 'demo');
      return (
        200,
        {
          'access_token': 'a1',
          'refresh_token': 'r1',
          'token_type': 'bearer',
          'expires_in': 3600,
        },
      );
    });
    final provider = PasswordAuthProvider(http);
    final result = await provider.login(
      config,
      username: 'demo',
      password: 'changeme',
    );
    final session = result.when(ok: (s) => s, err: (e) => fail(e.message));
    expect(session.accessToken, 'a1');
    expect(session.refreshToken, 'r1');
    expect(session.isAuthenticated, isTrue);
    expect(session.claims?['username'], 'demo');
  });

  test('wrong password maps to InvalidCredentials', () async {
    final http = FakeHttp((method, url, body) async {
      return (401, {'detail': 'Incorrect username or password'});
    });
    final result = await PasswordAuthProvider(http).login(
      config,
      username: 'demo',
      password: 'nope',
    );
    expect(result.failure, isA<InvalidCredentials>());
  });

  test('refresh posts refresh_token', () async {
    final http = FakeHttp((method, url, body) async {
      expect(url.path, '/v1/auth/refresh');
      expect(body?['refresh_token'], 'r1');
      return (
        200,
        {
          'access_token': 'a2',
          'refresh_token': 'r2',
          'expires_in': 3600,
        },
      );
    });
    final result = await PasswordAuthProvider(http).refresh(
      config,
      refreshToken: 'r1',
    );
    final session = result.when(ok: (s) => s, err: (e) => fail(e.message));
    expect(session.accessToken, 'a2');
    expect(session.refreshToken, 'r2');
  });
}
