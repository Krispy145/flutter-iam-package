# Flutter IAM

Flutter OIDC/OAuth2 package: login, token refresh, Dio interceptors.

---

## 📈 Status

- **Status:** scaffolded (initial setup complete)
- **Focus:** Flutter authentication package with OIDC/OAuth2 support
- **Last updated:** 07/10/2025
- **Upcoming integration:** API Showcase and AI Chat RAG apps

---

## 🔑 Highlights

- **Easy Setup** (few lines to sign in and add an interceptor)
- **SOLID Architecture** (ports/adapters, services, controllers)
- **Provider Agnostic** (Okta/Azure today, add others later)
- **Secure by Default** (PKCE, secure storage, short token TTL patterns)
- **UI Optional** (headless core + small widget helpers)
- **Dio Integration** (automatic token refresh and request interceptors)
- **Multi-tenant Support** (handle multiple identity providers)
- **Token Management** (automatic refresh, secure storage, rotation)

---

## 🏗 Architecture Overview

Clean package architecture with separation of concerns:

```
lib/
 ├─ src/core/           # config, errors
 ├─ src/domain/         # entities, ports (interfaces), services
 ├─ src/data/           # provider adapters, storage, http client
 └─ src/presentation/   # optional widgets, routing helpers, controller
```

**Patterns used:**

- `core/` handles configuration and error definitions
- `domain/` contains business logic and interfaces
- `data/` implements concrete adapters and storage
- `presentation/` provides optional UI components
- `example/` demonstrates usage patterns

---

## 📱 What It Demonstrates

- Clean Flutter package architecture
- OIDC/OAuth2 authentication flows
- Secure token management and storage
- Dio HTTP client integration
- Provider-agnostic design patterns
- Production-ready authentication solution

---

## 🚀 Getting Started

```bash
git clone https://github.com/Krispy145/flutter-iam.git
cd flutter-iam
flutter pub get
```

**Add to your app's `pubspec.yaml`:**

```yaml
dependencies:
  flutter_iam:
    git:
      url: https://github.com/Krispy145/flutter-iam.git
      ref: main
```

**Basic usage:**

```dart
import 'package:flutter_iam/flutter_iam.dart';
import 'package:dio/dio.dart';

final iam = IamConfig(
  issuer: Uri.parse('https://login.microsoftonline.com/<tenant>/v2.0'),
  clientId: '<client-id>',
  redirectUri: Uri.parse('com.example.app:/callback'),
  scopes: ['openid','profile','email','offline_access'],
);

// Add auth interceptor to Dio
final dio = Dio();
dio.interceptors.add(IamAuthInterceptor(iam));
```

---

## 🧪 Testing

```bash
flutter test --coverage
```

- Unit tests → Core authentication logic
- Widget tests → UI components and flows
- Integration tests → End-to-end authentication flows
- Security tests → Token handling and storage

---

## 🔒 Security Features

- **PKCE Flow** for SPA/mobile authentication
- **Secure Token Storage** using Flutter's secure storage
- **Token Rotation** with automatic refresh handling
- **State/Nonce Validation** for CSRF protection
- **Strict Redirect URIs** for security
- **No Token Logging** to prevent exposure
- **Short Token TTL** with refresh patterns

---

## 🗓 Roadmap

| Milestone                      | Category               | Target Date | Status     |
| ------------------------------ | ---------------------- | ----------- | ---------- |
| Scaffold package               | Flutter App & Packages | 13/10/2025  | ✅ Done    |
| Core authentication flows      | Flutter App & Packages | 20/10/2025  | ⏳ Pending |
| Okta/Azure AD integration      | Flutter App & Packages | 26/10/2025  | ⏳ Planned |
| Dio interceptor + route guards | Flutter App & Packages | 31/10/2025  | ⏳ Planned |
| Token rotation + multi-tenant  | Flutter App & Packages | 05/11/2025  | ⏳ Planned |
| Documentation + v1.0.0         | Flutter App & Packages | 10/11/2025  | ⏳ Planned |

---

## 📄 License

MIT © Krispy145
