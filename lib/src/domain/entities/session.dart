class Session {
  final bool isAuthenticated;
  final String? accessToken;
  final DateTime? accessTokenExpiry;
  final String? idToken;
  final String? refreshToken;
  final Map<String, dynamic>? claims;
  const Session({
    required this.isAuthenticated,
    this.accessToken,
    this.accessTokenExpiry,
    this.idToken,
    this.refreshToken,
    this.claims,
  });
  Session copyWith({
    bool? isAuthenticated,
    String? accessToken,
    DateTime? accessTokenExpiry,
    String? idToken,
    String? refreshToken,
    Map<String, dynamic>? claims,
  }) => Session(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    accessToken: accessToken ?? this.accessToken,
    accessTokenExpiry: accessTokenExpiry ?? this.accessTokenExpiry,
    idToken: idToken ?? this.idToken,
    refreshToken: refreshToken ?? this.refreshToken,
    claims: claims ?? this.claims,
  );
}
