class IamConfig {
  final Uri issuer;
  final String clientId;
  final Uri redirectUri;
  final Uri? postLogoutRedirectUri;
  final List<String> scopes;
  final Duration clockSkew;

  IamConfig({
    required this.issuer,
    this.clientId = 'secure-ai-api',
    Uri? redirectUri,
    this.postLogoutRedirectUri,
    this.scopes = const ['openid', 'profile', 'email', 'offline_access'],
    this.clockSkew = const Duration(seconds: 30),
  }) : redirectUri =
            redirectUri ?? Uri.parse('com.krispy145.flutteriam://callback');

  Uri get loginUrl => issuer.resolve('/v1/auth/login');
  Uri get tokenUrl => issuer.resolve('/v1/auth/token');
  Uri get refreshUrl => issuer.resolve('/v1/auth/refresh');
  Uri get logoutUrl => issuer.resolve('/v1/auth/logout');
  Uri get meUrl => issuer.resolve('/v1/auth/me');
}
