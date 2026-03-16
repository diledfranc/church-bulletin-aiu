import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistering = false; // Toggle between Login and Register
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AlertDialog(
      title: Text(_isRegistering ? 'Register' : 'Sign In'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            if (_isRegistering)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),

            if (_isRegistering)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'To test roles, use:\n• admin@aiu.edu (Admin)\n• clerk@aiu.edu (Clerk)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isRegistering ? 'Login Instead' : 'Create Account',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  try {
                    if (_isRegistering) {
                      await authProvider.signUp(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _nameController.text.trim(),
                      );
                    } else {
                      await authProvider.signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    setState(() {
                      // Clean up error message
                      String msg = e.toString();
                      if (msg.contains('email-already-in-use')) {
                        msg = 'Email already exists. Please login.';
                      } else if (msg.contains('weak-password')) {
                        msg = 'Password is too weak.';
                      } else if (msg.contains('user-not-found') ||
                          msg.contains('wrong-password')) {
                        msg = 'Invalid email or password.';
                      }
                      _errorMessage = msg;
                      _isLoading = false;
                    });
                  }
                },
                child: Text(_isRegistering ? 'Register' : 'Sign In'),
              ),
            ],
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
