import 'auth_models.dart';

class AuthService {
  Future<AuthResult> signIn(AuthCredentials credentials) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (credentials.email == 'demo@shipflutter.dev' &&
        credentials.password == 'password123') {
      return const AuthResult(
        userId: 'usr_1001',
        email: 'demo@shipflutter.dev',
        displayName: 'Demo User',
      );
    }
    throw StateError('Invalid email or password.');
  }

  Future<AuthResult> signUp(AuthCredentials credentials) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (credentials.email.isEmpty || credentials.password.length < 8) {
      throw StateError('Use a valid email and at least 8 characters.');
    }
    if (credentials.displayName == null || credentials.displayName!.isEmpty) {
      throw StateError('Display name is required.');
    }
    return AuthResult(
      userId: 'usr_${credentials.email.hashCode.abs()}',
      email: credentials.email,
      displayName: credentials.displayName!,
    );
  }

  Future<PasswordResetResult> forgotPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalizedEmail = email.trim().toLowerCase();
    if (!_isValidEmail(normalizedEmail)) {
      throw StateError('Enter a valid email address.');
    }
    return PasswordResetResult(
      email: normalizedEmail,
      message: 'Reset link sent to $normalizedEmail',
    );
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.') && !email.contains(' ');
  }
}
