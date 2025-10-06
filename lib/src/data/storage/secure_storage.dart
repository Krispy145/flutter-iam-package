import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/session.dart';
import '../../domain/ports/token_storage.dart';

class SecureTokenStorage implements TokenStoragePort {
  final _storage = const FlutterSecureStorage();
  static const _k = 'flutter_iam_session';

  @override
  Future<void> save(Session s) async {
    await _storage.write(key: _k, value: jsonEncode({
      'isAuthenticated': s.isAuthenticated,
      'accessToken': s.accessToken,
      'accessTokenExpiry': s.accessTokenExpiry?.toIso8601String(),
      'idToken': s.idToken,
      'refreshToken': s.refreshToken,
      'claims': s.claims,
    }));
  }

  @override
  Future<Session?> read() async {
    final raw = await _storage.read(key: _k);
    if (raw == null) return null;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return Session(
      isAuthenticated: j['isAuthenticated'] == true,
      accessToken: j['accessToken'],
      accessTokenExpiry: j['accessTokenExpiry'] != null ? DateTime.parse(j['accessTokenExpiry']) : null,
      idToken: j['idToken'],
      refreshToken: j['refreshToken'],
      claims: (j['claims'] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  Future<void> clear() async => _storage.delete(key: _k);
}
