import '../../core/iam_config.dart';
import '../../core/errors.dart';
import '../../domain/entities/session.dart';
import '../../domain/ports/auth_provider.dart';

class AzureAdAuthProvider implements AuthProviderPort {
  @override
  Future<IamResult<Session>> startAuth(IamConfig config) async {
    return const IamResult.err(UnsupportedProvider('Azure AD startAuth not implemented yet'));
  }
  @override
  Future<IamResult<Session>> exchangeCode(IamConfig config, {required Uri redirect}) async {
    return const IamResult.err(UnsupportedProvider('Azure AD exchangeCode not implemented yet'));
  }
  @override
  Future<IamResult<Session>> refresh(IamConfig config, {required String refreshToken}) async {
    return const IamResult.err(UnsupportedProvider('Azure AD refresh not implemented yet'));
  }
  @override
  Future<IamResult<void>> revoke(IamConfig config, {String? accessToken, String? refreshToken}) async {
    return const IamResult.err(UnsupportedProvider('Azure AD revoke not implemented yet'));
  }
}
