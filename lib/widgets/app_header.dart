import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_dialog.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo from assets
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40, maxWidth: 200),
            child: Image.asset(
              'assets/images/church-logo-white.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if asset is missing (e.g. during development/hot reload before full restart)
                return const Text(
                  'AIU Church',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              if (user == null) {
                showDialog(
                  context: context,
                  builder: (_) => const LoginDialog(),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Signed in as ${user.name}'),
                    content: Text('Role: ${user.role.name}'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          authProvider.signOut();
                          Navigator.pop(context);
                        },
                        child: const Text('Sign Out'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF18345E),
              child: Icon(user != null ? Icons.verified_user : Icons.person),
            ),
          ),
        ],
      ),
    );
  }
}
