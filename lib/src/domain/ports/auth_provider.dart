import '../../core/iam_config.dart';
import '../../core/errors.dart';
import '../entities/session.dart';

abstract class AuthProviderPort {
  Future<IamResult<Session>> startAuth(IamConfig config);
  Future<IamResult<Session>> exchangeCode(IamConfig config, {required Uri redirect});
  Future<IamResult<Session>> refresh(IamConfig config, {required String refreshToken});
  Future<IamResult<void>> revoke(IamConfig config, {String? accessToken, String? refreshToken});
}
