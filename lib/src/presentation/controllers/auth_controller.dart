import '../../core/errors.dart';
import '../../core/iam_config.dart';
import '../../domain/entities/session.dart';
import '../../domain/ports/auth_provider.dart';
import '../../domain/ports/token_storage.dart';
import '../../domain/services/session_service.dart';
import '../../domain/services/token_service.dart';

class AuthController {
  AuthController({
    required this.config,
    required this.provider,
    required this.storage,
    required this.session,
    required this.tokens,
  });

  final IamConfig config;
  final AuthProviderPort provider;
  final TokenStoragePort storage;
  final SessionService session;
  final TokenService tokens;

  Future<void> restore() async {
    final stored = await storage.read();
    if (stored == null || !stored.isAuthenticated) {
      session.set(const Session(isAuthenticated: false));
      return;
    }
    final result = await tokens.ensure(stored);
    await result.when(
      ok: (s) async {
        await storage.save(s);
        session.set(s);
      },
      err: (_) async {
        await storage.clear();
        session.set(const Session(isAuthenticated: false));
      },
    );
  }

  Future<IamResult<Session>> signIn() async {
    return _persist(await provider.startAuth(config));
  }

  Future<IamResult<Session>> signInWithPassword({
    required String username,
    required String password,
  }) async {
    if (provider is PasswordAuthPort) {
      final passwordAuth = provider as PasswordAuthPort;
      return _persist(
        await passwordAuth.login(
          config,
          username: username,
          password: password,
        ),
      );
    }
    return const IamResult.err(
      UnsupportedProvider('Provider does not support password login'),
    );
  }

  Future<IamResult<Session>> _persist(IamResult<Session> result) {
    return result.when(
      ok: (s) async {
        await storage.save(s);
        session.set(s);
        return IamResult.ok(s);
      },
      err: (e) async => IamResult.err(e),
    );
  }

  Future<void> signOut() async {
    final refresh = session.current.refreshToken;
    if (refresh != null) {
      await provider.revoke(config, refreshToken: refresh);
    }
    await storage.clear();
    session.set(const Session(isAuthenticated: false));
  }
}
