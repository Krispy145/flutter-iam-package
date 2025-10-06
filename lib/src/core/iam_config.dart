class IamConfig {
  final Uri issuer;
  final String clientId;
  final Uri redirectUri;
  final Uri? postLogoutRedirectUri;
  final List<String> scopes;
  final Duration clockSkew;

  const IamConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    this.postLogoutRedirectUri,
    this.scopes = const ['openid','profile','email','offline_access'],
    this.clockSkew = const Duration(seconds: 30),
  });
}
