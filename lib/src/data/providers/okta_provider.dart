// Stub adapter — implement discovery, PKCE, code exchange, refresh in next iterations.
import '../../core/iam_config.dart';
import '../../core/errors.dart';
import '../../domain/entities/session.dart';
import '../../domain/ports/auth_provider.dart';

class OktaAuthProvider implements AuthProviderPort {
  @override
  Future<IamResult<Session>> startAuth(IamConfig config) async {
    return const IamResult.err(UnsupportedProvider('Okta startAuth not implemented yet'));
  }
  @override
  Future<IamResult<Session>> exchangeCode(IamConfig config, {required Uri redirect}) async {
    return const IamResult.err(UnsupportedProvider('Okta exchangeCode not implemented yet'));
  }
  @override
  Future<IamResult<Session>> refresh(IamConfig config, {required String refreshToken}) async {
    return const IamResult.err(UnsupportedProvider('Okta refresh not implemented yet'));
  }
  @override
  Future<IamResult<void>> revoke(IamConfig config, {String? accessToken, String? refreshToken}) async {
    return const IamResult.err(UnsupportedProvider('Okta revoke not implemented yet'));
  }
}
