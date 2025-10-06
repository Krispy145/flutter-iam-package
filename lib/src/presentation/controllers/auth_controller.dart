import '../../core/iam_config.dart';
import '../../core/errors.dart';
import '../../domain/entities/session.dart';
import '../../domain/ports/auth_provider.dart';
import '../../domain/ports/token_storage.dart';
import '../../domain/services/session_service.dart';

class AuthController {
  final IamConfig config;
  final AuthProviderPort provider;
  final TokenStoragePort storage;
  final SessionService session;

  AuthController({required this.config, required this.provider, required this.storage, required this.session});

  Future<IamResult<Session>> signIn() async {
    final r = await provider.startAuth(config);
    return r.when(
      ok: (s) async { await storage.save(s); session.set(s); return IamResult.ok(s); },
      err: (e) => IamResult.err(e),
    );
  }

  Future<void> signOut() async {
    await storage.clear();
    session.set(const Session(isAuthenticated: false));
  }
}
