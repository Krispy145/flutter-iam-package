sealed class IamFailure {
  final String message;
  const IamFailure(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class AuthCancelled extends IamFailure {
  const AuthCancelled([super.m = 'auth cancelled']);
}

class AuthNetworkError extends IamFailure {
  const AuthNetworkError([super.m = 'network error']);
}

class TokenRefreshFailed extends IamFailure {
  const TokenRefreshFailed([super.m = 'token refresh failed']);
}

class UnsupportedProvider extends IamFailure {
  const UnsupportedProvider([super.m = 'unsupported provider']);
}

class InvalidCredentials extends IamFailure {
  const InvalidCredentials([super.m = 'incorrect username or password']);
}

class IamResult<T> {
  final T? value;
  final IamFailure? failure;
  const IamResult.ok(this.value) : failure = null;
  const IamResult.err(this.failure) : value = null;
  bool get isOk => failure == null;

  R when<R>({
    required R Function(T v) ok,
    required R Function(IamFailure e) err,
  }) {
    if (failure != null) return err(failure!);
    return ok(value as T);
  }
}
