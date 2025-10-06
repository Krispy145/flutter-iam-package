import '../../core/iam_config.dart';
import '../../core/errors.dart';
import '../entities/session.dart';
import '../ports/auth_provider.dart';
import '../ports/token_storage.dart';

class TokenService {
  final IamConfig config;
  final AuthProviderPort provider;
  final TokenStoragePort storage;

  TokenService({required this.config, required this.provider, required this.storage});

  bool _isExpiring(Session s, {Duration threshold = const Duration(seconds: 45)}) {
    final exp = s.accessTokenExpiry;
    if (exp == null) return true;
    return DateTime.now().isAfter(exp.subtract(threshold));
    }

  Future<IamResult<Session>> ensure(Session s) async {
    if (!_isExpiring(s)) return IamResult.ok(s);
    if (s.refreshToken == null) return const IamResult.err(TokenRefreshFailed('no refresh token'));
    final r = await provider.refresh(config, refreshToken: s.refreshToken!);
    return await r.when(
      ok: (ns) async { await storage.save(ns); return IamResult.ok(ns); },
      err: (e) async { await storage.clear(); return IamResult.err(e); },
    );
  }
}
