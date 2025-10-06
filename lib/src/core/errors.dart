sealed class IamFailure {
  final String message;
  const IamFailure(this.message);
  @override
  String toString() => '$runtimeType: $message';
}
class AuthCancelled extends IamFailure { const AuthCancelled([String m='auth cancelled']) : super(m); }
class AuthNetworkError extends IamFailure { const AuthNetworkError([String m='network error']) : super(m); }
class TokenRefreshFailed extends IamFailure { const TokenRefreshFailed([String m='token refresh failed']) : super(m); }
class UnsupportedProvider extends IamFailure { const UnsupportedProvider([String m='unsupported provider']) : super(m); }

class IamResult<T> {
  final T? value;
  final IamFailure? failure;
  const IamResult.ok(this.value) : failure = null;
  const IamResult.err(this.failure) : value = null;
  R when<R>({required R Function(T v) ok, required R Function(IamFailure e) err}) {
    if (failure != null) return err(failure!);
    return ok(value as T);
  }
}
