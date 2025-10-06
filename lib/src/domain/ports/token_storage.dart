import '../entities/session.dart';

abstract class TokenStoragePort {
  Future<void> save(Session session);
  Future<Session?> read();
  Future<void> clear();
}
