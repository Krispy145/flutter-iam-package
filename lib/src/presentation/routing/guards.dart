import 'package:flutter/material.dart';

import '../../domain/entities/session.dart';
import '../../domain/services/session_service.dart';

class AuthGuard {
  AuthGuard(this.session);

  final SessionService session;

  bool get canActivate => session.current.isAuthenticated;
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.session,
    required this.signedIn,
    required this.signedOut,
  });

  final SessionService session;
  final Widget signedIn;
  final Widget signedOut;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Session>(
      stream: session.stream,
      initialData: session.current,
      builder: (context, snapshot) {
        final authed = snapshot.data?.isAuthenticated ?? false;
        return authed ? signedIn : signedOut;
      },
    );
  }
}

class RoleGuard {
  RoleGuard({this.requiredRoles = const []});

  final List<String> requiredRoles;

  bool allow(Session session) {
    if (requiredRoles.isEmpty) return session.isAuthenticated;
    final roles = session.claims?['roles'];
    if (roles is List) {
      return requiredRoles.every(roles.contains);
    }
    return false;
  }
}
