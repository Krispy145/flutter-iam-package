import 'package:dio/dio.dart';

import 'core/iam_config.dart';
import 'data/http/auth_interceptor.dart';
import 'data/http/dio_http_client.dart';
import 'data/providers/password_provider.dart';
import 'data/storage/memory_storage.dart';
import 'data/storage/secure_storage.dart';
import 'domain/ports/auth_provider.dart';
import 'domain/ports/token_storage.dart';
import 'domain/services/session_service.dart';
import 'domain/services/token_service.dart';
import 'presentation/controllers/auth_controller.dart';

/// Wires config, storage, session, tokens, and a Dio client with auth refresh.
class FlutterIam {
  FlutterIam({
    required this.config,
    required AuthProviderPort provider,
    TokenStoragePort? storage,
    Dio? api,
    bool useSecureStorage = true,
  })  : session = SessionService(),
        storage = storage ??
            (useSecureStorage ? SecureTokenStorage() : MemoryTokenStorage()),
        provider = provider,
        api = api ?? Dio(BaseOptions(baseUrl: config.issuer.toString())) {
    tokens = TokenService(
      config: config,
      provider: provider,
      storage: this.storage,
    );
    auth = AuthController(
      config: config,
      provider: provider,
      storage: this.storage,
      session: session,
      tokens: tokens,
    );
    this.api.interceptors.insert(
          0,
          AuthInterceptor(
            session: session,
            tokens: tokens,
            config: config,
            dio: this.api,
          ),
        );
  }

  factory FlutterIam.password({
    required Uri apiBase,
    TokenStoragePort? storage,
    Dio? api,
    bool useSecureStorage = true,
  }) {
    final config = IamConfig(issuer: apiBase);
    return FlutterIam(
      config: config,
      provider: PasswordAuthProvider(DioHttpClient()),
      storage: storage,
      api: api,
      useSecureStorage: useSecureStorage,
    );
  }

  final IamConfig config;
  final AuthProviderPort provider;
  final TokenStoragePort storage;
  final SessionService session;
  final Dio api;
  late final TokenService tokens;
  late final AuthController auth;

  void dispose() => session.dispose();
}
