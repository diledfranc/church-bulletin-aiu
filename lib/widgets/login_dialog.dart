import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AlertDialog(
      title: const Text('Sign In'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              try {
                await authProvider.signIn(
                  _emailController.text,
                  _passwordController.text,
                );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                setState(() {
                  _errorMessage =
                      'Login failed. Check credentials.'; // Simplified error
                  _isLoading = false;
                });
              }
            },
            child: const Text('Sign In'),
          ),
      ],
    );
  }
}
