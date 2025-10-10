# flutter_iam

Flutter OIDC/OAuth2 package: login, token refresh, Dio interceptors.

**Status:** scaffolded (initial package layout)  
**Updated:** 06/10/2025

---

## Why this package

- **Easy setup** (few lines to sign in and add an interceptor)
- **SOLID architecture** (ports/adapters, services, controllers)
- **Provider-agnostic** (Okta/Azure today, add others later)
- **Secure by default** (PKCE, secure storage, short token TTL patterns)
- **UI optional** (headless core + small widget helpers)

---

## Installation

This repo is a package; include it via path or git in your app's `pubspec.yaml` during development.

```yaml
dependencies:
  flutter_iam:
    git:
      url: https://github.com/Krispy145/flutter-iam.git
      ref: main
```

---

## Quick start

```dart
import 'package:flutter_iam/flutter_iam.dart';
import 'package:dio/dio.dart';

final iam = IamConfig(
  issuer: Uri.parse('https://login.microsoftonline.com/<tenant>/v2.0'),
  clientId: '<client-id>',
  redirectUri: Uri.parse('com.example.app:/callback'),
  scopes: ['openid','profile','email','offline_access'],
);

// In app code (coming versions will expose IamClient facade)
final dio = Dio(); // dio.interceptors.add(IamAuthInterceptor(...));
```

> Note: In this initial scaffold, provider adapters are stubs; upcoming versions wire full OIDC PKCE.

---

## Package architecture

```
lib/
  src/core/           # config, errors
  src/domain/         # entities, ports (interfaces), services
  src/data/           # provider adapters, storage, http client
  src/presentation/   # optional widgets, routing helpers, controller
example/              # tiny demo app
```

---

## Roadmap

- **v0.1.0 (by 13/10/2025)** — scaffolding, ports/services, secure storage, widgets, example
- **v0.2.0** — Okta/Azure AD PKCE flows, Dio interceptor, route guards
- **v0.3.0** — token rotation, multi-tenant/provider registry, metrics hooks
- **v1.0.0** — docs, hardening, and stability guarantees

---

## Security

- PKCE for SPA/mobile flows
- No tokens in logs
- Strict redirect URIs; handle `state`/nonce
- Short access token TTL, refresh with rotation when supported
- Server-side JWT validation in your backend (this package does not validate JWKS)

---

## License

MIT © Krispy145
