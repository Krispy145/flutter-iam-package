import 'package:flutter_iam/flutter_iam.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProvider implements AuthProviderPort, PasswordAuthPort {
  FakeProvider({this.loginSession, this.refreshSession, this.loginFailure});

  Session? loginSession;
  Session? refreshSession;
  IamFailure? loginFailure;
  int refreshCalls = 0;

  @override
  Future<IamResult<Session>> login(
    IamConfig config, {
    required String username,
    required String password,
  }) async {
    if (loginFailure != null) return IamResult.err(loginFailure!);
    return IamResult.ok(loginSession!);
  }

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
    refreshCalls += 1;
    if (refreshSession == null) {
      return const IamResult.err(TokenRefreshFailed());
    }
    return IamResult.ok(refreshSession);
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

void main() {
  final config = IamConfig(issuer: Uri.parse('http://127.0.0.1:8000'));

  test('signInWithPassword persists session', () async {
    final session = SessionService();
    final storage = MemoryTokenStorage();
    final fresh = Session(
      isAuthenticated: true,
      accessToken: 'a1',
      refreshToken: 'r1',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      claims: const {'username': 'demo'},
    );
    final provider = FakeProvider(loginSession: fresh);
    final tokens = TokenService(
      config: config,
      provider: provider,
      storage: storage,
    );
    final auth = AuthController(
      config: config,
      provider: provider,
      storage: storage,
      session: session,
      tokens: tokens,
    );

    final result = await auth.signInWithPassword(
      username: 'demo',
      password: 'changeme',
    );
    expect(result.isOk, isTrue);
    expect(session.current.accessToken, 'a1');
    expect((await storage.read())?.accessToken, 'a1');
  });

  test('ensure refreshes when access token is expired', () async {
    final storage = MemoryTokenStorage();
    final provider = FakeProvider(
      refreshSession: Session(
        isAuthenticated: true,
        accessToken: 'a2',
        refreshToken: 'r2',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    final tokens = TokenService(
      config: config,
      provider: provider,
      storage: storage,
    );
    final expired = Session(
      isAuthenticated: true,
      accessToken: 'old',
      refreshToken: 'r1',
      accessTokenExpiry: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    final result = await tokens.ensure(expired);
    expect(result.when(ok: (s) => s.accessToken, err: (_) => null), 'a2');
    expect(provider.refreshCalls, 1);
  });

  test('ensure skips refresh when token is still valid', () async {
    final storage = MemoryTokenStorage();
    final provider = FakeProvider();
    final tokens = TokenService(
      config: config,
      provider: provider,
      storage: storage,
    );
    final valid = Session(
      isAuthenticated: true,
      accessToken: 'a1',
      refreshToken: 'r1',
      accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
    );
    final result = await tokens.ensure(valid);
    expect(result.when(ok: (s) => s.accessToken, err: (_) => null), 'a1');
    expect(provider.refreshCalls, 0);
  });

  test('signOut clears session', () async {
    final session = SessionService();
    final storage = MemoryTokenStorage();
    final provider = FakeProvider();
    final tokens = TokenService(
      config: config,
      provider: provider,
      storage: storage,
    );
    final auth = AuthController(
      config: config,
      provider: provider,
      storage: storage,
      session: session,
      tokens: tokens,
    );
    session.set(
      Session(
        isAuthenticated: true,
        accessToken: 'a1',
        refreshToken: 'r1',
        accessTokenExpiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    await storage.save(session.current);
    await auth.signOut();
    expect(session.current.isAuthenticated, isFalse);
    expect(await storage.read(), isNull);
  });
}
