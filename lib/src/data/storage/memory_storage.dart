import '../../domain/entities/session.dart';
import '../../domain/ports/token_storage.dart';

class MemoryTokenStorage implements TokenStoragePort {
  Session? _session;

  @override
  Future<void> save(Session session) async => _session = session;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> clear() async => _session = null;
}
