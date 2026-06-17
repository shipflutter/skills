enum AuthMode { signIn, signUp, forgotPassword }

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

class PasswordResetResult {
  final String email;
  final String message;

  const PasswordResetResult({required this.email, required this.message});
}

class AuthSubmissionState {
  final bool loading;
  final AuthResult? result;
  final PasswordResetResult? resetResult;
  final String? error;

  const AuthSubmissionState({
    this.loading = false,
    this.result,
    this.resetResult,
    this.error,
  });

  AuthSubmissionState copyWith({
    bool? loading,
    AuthResult? result,
    PasswordResetResult? resetResult,
    String? error,
    bool clearResult = false,
    bool clearResetResult = false,
    bool clearError = false,
  }) {
    return AuthSubmissionState(
      loading: loading ?? this.loading,
      result: clearResult ? null : result ?? this.result,
      resetResult: clearResetResult ? null : resetResult ?? this.resetResult,
      error: clearError ? null : error ?? this.error,
    );
  }
}
