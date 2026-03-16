import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
          const CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF18345E),
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
