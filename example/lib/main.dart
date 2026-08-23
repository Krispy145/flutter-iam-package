import 'package:flutter/material.dart';
import 'package:flutter_iam/flutter_iam.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  late final FlutterIam iam = FlutterIam.password(
    apiBase: Uri.parse('http://127.0.0.1:8000'),
    useSecureStorage: false,
  );

  @override
  void dispose() {
    iam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_iam demo',
      home: AuthGate(
        session: iam.session,
        signedOut: _LoginPage(iam: iam),
        signedIn: _HomePage(iam: iam),
      ),
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({required this.iam});

  final FlutterIam iam;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _user = TextEditingController(text: 'demo');
  final _pass = TextEditingController(text: 'changeme');
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.iam.auth.signInWithPassword(
      username: _user.text.trim(),
      password: _pass.text,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = result.when(ok: (_) => null, err: (e) => e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Secure AI API demo user: demo / changeme'),
            const SizedBox(height: 16),
            TextField(
              controller: _user,
              decoration: const InputDecoration(labelText: 'Username'),
              enabled: !_busy,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              enabled: !_busy,
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            SignInButton(onPressed: _busy ? () {} : _submit),
          ],
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({required this.iam});

  final FlutterIam iam;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _status = 'Signed in. Tap to call /v1/auth/me';

  Future<void> _callMe() async {
    setState(() => _status = 'Calling /v1/auth/me …');
    try {
      final res = await widget.iam.api.get<Map<String, dynamic>>('/v1/auth/me');
      setState(() => _status = 'me → ${res.data}');
    } catch (e) {
      setState(() => _status = 'error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.iam.session.current.claims?['username'] ?? 'user';
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello $user'),
        actions: [
          SignOutButton(onPressed: widget.iam.auth.signOut),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_status, textAlign: TextAlign.center),
            ),
            ElevatedButton(
              onPressed: _callMe,
              child: const Text('GET /v1/auth/me'),
            ),
          ],
        ),
      ),
    );
  }
}
