import '../../core/errors.dart';
import '../../core/iam_config.dart';
import '../entities/session.dart';
import '../ports/auth_provider.dart';
import '../ports/token_storage.dart';

class TokenService {
  TokenService({
    required this.config,
    required this.provider,
    required this.storage,
    this.threshold = const Duration(seconds: 45),
  });

  final IamConfig config;
  final AuthProviderPort provider;
  final TokenStoragePort storage;
  final Duration threshold;

  bool isExpiring(Session s) {
    final exp = s.accessTokenExpiry;
    if (exp == null) return true;
    return DateTime.now().isAfter(exp.subtract(threshold));
  }

  Future<IamResult<Session>> refreshNow(Session s) async {
    final refresh = s.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      return const IamResult.err(TokenRefreshFailed('no refresh token'));
    }
    final result = await provider.refresh(config, refreshToken: refresh);
    return result.when(
      ok: (ns) async {
        await storage.save(ns);
        return IamResult.ok(ns);
      },
      err: (e) async {
        await storage.clear();
        return IamResult.err(e);
      },
    );
  }

  Future<IamResult<Session>> ensure(Session s) async {
    if (!isExpiring(s)) return IamResult.ok(s);
    return refreshNow(s);
  }
}
