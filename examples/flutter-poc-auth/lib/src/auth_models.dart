enum AuthMode { signIn, signUp }

class AuthCredentials {
  final String email;
  final String password;
  final String? displayName;

  const AuthCredentials({
    required this.email,
    required this.password,
    this.displayName,
  });
}

class AuthResult {
  final String userId;
  final String email;
  final String displayName;

  const AuthResult({
    required this.userId,
    required this.email,
    required this.displayName,
  });
}

class AuthSubmissionState {
  final bool loading;
  final AuthResult? result;
  final String? error;

  const AuthSubmissionState({this.loading = false, this.result, this.error});

  AuthSubmissionState copyWith({
    bool? loading,
    AuthResult? result,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return AuthSubmissionState(
      loading: loading ?? this.loading,
      result: clearResult ? null : result ?? this.result,
      error: clearError ? null : error ?? this.error,
    );
  }
}
