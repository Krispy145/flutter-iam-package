import 'dart:async';
import '../entities/session.dart';

class SessionService {
  final _ctrl = StreamController<Session>.broadcast();
  Session _current = const Session(isAuthenticated: false);
  Session get current => _current;
  Stream<Session> get stream => _ctrl.stream;

  void set(Session s) {
    _current = s;
    _ctrl.add(s);
  }

  void dispose() => _ctrl.close();
}
