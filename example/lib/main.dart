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
  // NOTE: This is only a compile-time wiring demo; providers are stubs in v0.1.0 scaffold.
  final session = SessionService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_iam demo')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This is a scaffold. Providers will be wired in upcoming commits.'),
              const SizedBox(height: 16),
              SignInButton(onPressed: () {}),
              const SizedBox(height: 8),
              SignOutButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
