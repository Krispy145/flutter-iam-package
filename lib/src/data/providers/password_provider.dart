import '../../core/errors.dart';
import '../../core/iam_config.dart';
import '../../domain/entities/session.dart';
import '../../domain/ports/auth_provider.dart';
import '../../domain/ports/http_client.dart';

class PasswordAuthProvider implements AuthProviderPort, PasswordAuthPort {
  final HttpClientPort http;

  PasswordAuthProvider(this.http);

  Session _sessionFrom(Map<String, dynamic> json, {String? username}) {
    final token = json['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('access_token missing');
    }
    final expiresIn = json['expires_in'] is int
        ? json['expires_in'] as int
        : int.tryParse('${json['expires_in']}') ?? 3600;
    return Session(
      isAuthenticated: true,
      accessToken: token,
      refreshToken: json['refresh_token'] as String?,
      accessTokenExpiry: DateTime.now().add(Duration(seconds: expiresIn)),
      claims: {if (username != null) 'username': username},
    );
  }

  IamResult<Session> _fromStatus(int status, Map<String, dynamic> json,
      {String? username}) {
    if (status == 401 || status == 403) {
      return const IamResult.err(InvalidCredentials());
    }
    if (status < 200 || status >= 300) {
      final detail = json['detail']?.toString() ?? 'HTTP $status';
      return IamResult.err(AuthNetworkError(detail));
    }
    try {
      return IamResult.ok(_sessionFrom(json, username: username));
    } on FormatException catch (e) {
      return IamResult.err(AuthNetworkError(e.message));
    }
  }

  @override
  Future<IamResult<Session>> login(
    IamConfig config, {
    required String username,
    required String password,
  }) async {
    try {
      final (status, json) = await http.postJson(
        config.loginUrl,
        {'username': username, 'password': password},
      );
      return _fromStatus(status, json, username: username);
    } catch (e) {
      return IamResult.err(AuthNetworkError(e.toString()));
    }
  }

  @override
  Future<IamResult<Session>> startAuth(IamConfig config) async {
    return const IamResult.err(
      UnsupportedProvider('Use signInWithPassword for the password provider'),
    );
  }

  @override
  Future<IamResult<Session>> exchangeCode(
    IamConfig config, {
    required Uri redirect,
  }) async {
    return const IamResult.err(
      UnsupportedProvider('Password provider does not use authorization codes'),
    );
  }

  @override
  Future<IamResult<Session>> refresh(
    IamConfig config, {
    required String refreshToken,
  }) async {
    try {
      final (status, json) = await http.postJson(
        config.refreshUrl,
        {'refresh_token': refreshToken},
      );
      if (status == 401 || status == 403) {
        return const IamResult.err(TokenRefreshFailed());
      }
      return _fromStatus(status, json);
    } catch (e) {
      return IamResult.err(TokenRefreshFailed(e.toString()));
    }
  }

  @override
  Future<IamResult<void>> revoke(
    IamConfig config, {
    String? accessToken,
    String? refreshToken,
  }) async {
    if (refreshToken == null || refreshToken.isEmpty) {
      return const IamResult<void>.ok(null);
    }
    try {
      await http.postJson(config.logoutUrl, {'refresh_token': refreshToken});
      return const IamResult<void>.ok(null);
    } catch (e) {
      return IamResult.err(AuthNetworkError(e.toString()));
    }
  }
}
