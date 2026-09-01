import 'dart:async';

import 'session_store.dart';
import 'user_session.dart';

class SessionManager {
  SessionManager(this._store);
  final SessionStore _store;
  final _controller = StreamController<UserSession?>.broadcast();
  UserSession? _current;

  UserSession? get current => _current;
  Stream<UserSession?> get changes => _controller.stream;

  Future<UserSession?> restore() async {
    _current = await _store.read();
    return _current;
  }

  Future<void> setSession(UserSession session) async {
    _current = session;
    await _store.save(session);
    _controller.add(session);
  }

  Future<void> clear() async {
    _current = null;
    await _store.clear();
    _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
