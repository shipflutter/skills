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

  @override
  Widget build(BuildContext context) {
    final isSignUp = _mode == AuthMode.signUp;
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
            onSelectionChanged: (value) => setState(() => _mode = value.first),
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
