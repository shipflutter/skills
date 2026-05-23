import 'package:flutter/material.dart';

import 'auth_models.dart';
import 'auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _service = AuthService();
  final _emailController = TextEditingController(text: 'demo@shipflutter.dev');
  final _passwordController = TextEditingController(text: 'password123');
  final _displayNameController = TextEditingController(text: 'Demo User');
  AuthMode _mode = AuthMode.signIn;
  AuthSubmissionState _state = const AuthSubmissionState();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _state = const AuthSubmissionState(loading: true);
    });

    try {
      final credentials = AuthCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _mode == AuthMode.signUp
            ? _displayNameController.text.trim()
            : null,
      );
      final result = _mode == AuthMode.signIn
          ? await _service.signIn(credentials)
          : await _service.signUp(credentials);
      if (!mounted) return;
      setState(() {
        _state = AuthSubmissionState(result: result);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _state = AuthSubmissionState(
          error: error.toString().replaceFirst('StateError: ', ''),
        );
      });
    }
  }

  Future<void> _submitForgotPassword() async {
    setState(() {
      _state = const AuthSubmissionState(loading: true);
    });

    try {
      final result = await _service.forgotPassword(_emailController.text);
      if (!mounted) return;
      setState(() {
        _state = AuthSubmissionState(resetResult: result);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _state = AuthSubmissionState(
          error: error.toString().replaceFirst('StateError: ', ''),
        );
      });
    }
  }

  bool _canSubmitForgotPassword() {
    final email = _emailController.text.trim();
    return email.contains('@') && email.contains('.') && !email.contains(' ');
  }

  void _setMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _state = const AuthSubmissionState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == AuthMode.signUp;
    final isForgotPassword = _mode == AuthMode.forgotPassword;
    if (isForgotPassword) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
          leading: BackButton(onPressed: () => _setMode(AuthMode.signIn)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Reset your password',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your email and we'll send you instructions to reset your password.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {
                _state = const AuthSubmissionState();
              }),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _state.loading || !_canSubmitForgotPassword()
                  ? null
                  : _submitForgotPassword,
              child: Text(_state.loading ? 'Sending...' : 'Send Reset Link'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _setMode(AuthMode.signIn),
              child: const Text('Remember your password? Sign in'),
            ),
            const SizedBox(height: 24),
            if (_state.error != null)
              Text(_state.error!, style: const TextStyle(color: Colors.red)),
            if (_state.resetResult != null)
              Text(
                _state.resetResult!.message,
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter POC Auth')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SegmentedButton<AuthMode>(
            segments: const [
              ButtonSegment(value: AuthMode.signIn, label: Text('Sign in')),
              ButtonSegment(value: AuthMode.signUp, label: Text('Sign up')),
            ],
            selected: {_mode},
            onSelectionChanged: (value) => _setMode(value.first),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          if (isSignUp) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
          ],
          const SizedBox(height: 24),
          if (!isSignUp) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _setMode(AuthMode.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          FilledButton(
            onPressed: _state.loading ? null : _submit,
            child: Text(
              _state.loading
                  ? 'Working...'
                  : (isSignUp ? 'Create account' : 'Sign in'),
            ),
          ),
          const SizedBox(height: 24),
          if (_state.error != null)
            Text(_state.error!, style: const TextStyle(color: Colors.red)),
          if (_state.result != null) ...[
            Text('User ID: ${_state.result!.userId}'),
            Text('Email: ${_state.result!.email}'),
            Text('Name: ${_state.result!.displayName}'),
          ],
        ],
      ),
    );
  }
}
