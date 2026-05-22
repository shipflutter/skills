import 'package:flutter_poc_auth/src/auth_models.dart';
import 'package:flutter_poc_auth/src/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signIn returns demo user for valid credentials', () async {
    final service = AuthService();

    final result = await service.signIn(
      const AuthCredentials(
        email: 'demo@shipflutter.dev',
        password: 'password123',
      ),
    );

    expect(result.email, 'demo@shipflutter.dev');
    expect(result.displayName, 'Demo User');
  });

  test('signUp returns new user for valid registration data', () async {
    final service = AuthService();

    final result = await service.signUp(
      const AuthCredentials(
        email: 'new@shipflutter.dev',
        password: 'password123',
        displayName: 'New User',
      ),
    );

    expect(result.email, 'new@shipflutter.dev');
    expect(result.displayName, 'New User');
  });
}
