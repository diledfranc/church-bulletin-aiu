import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/about_screen.dart';
import 'login_dialog.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo - Navigates to About Screen
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40, maxWidth: 200),
              child: Image.asset(
                'assets/images/church-logo-white.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Right side actions
          Row(
            children: [
              // User Profile / Login Icon
              IconButton(
                icon: Icon(
                  user != null ? Icons.account_circle : Icons.login,
                  color: Colors.white,
                ),
                tooltip: user != null ? 'Profile (Tap to Logout)' : 'Login',
                onPressed: () {
                  if (user != null) {
                    // Show logout / profile dialog
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Signed in as ${user.name}'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user.email}'),
                            const SizedBox(height: 8),
                            Text('Role: ${user.role.name.toUpperCase()}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              auth.signOut();
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Show Login/Register dialog
                    showDialog(
                      context: context,
                      builder: (context) => const LoginDialog(),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
