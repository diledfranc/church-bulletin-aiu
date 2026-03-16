import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bulletin_item.dart';
import '../providers/auth_provider.dart';

class CurrentProgramCard extends StatelessWidget {
  final List<BulletinItem> bulletinItems;
  final String currentItemId;
  final Function(String) onUpdate;
  final VoidCallback? onOpenNotes;

  const CurrentProgramCard({
    super.key,
    required this.bulletinItems,
    required this.currentItemId,
    required this.onUpdate,
    this.onOpenNotes,
  });

  @override
  Widget build(BuildContext context) {
    // Find current item details
    String currentTitle = 'Welcome';
    int currentIndex = -1;

    if (bulletinItems.isNotEmpty) {
      // Find index by ID
      currentIndex = bulletinItems.indexWhere(
        (item) => item.id == currentItemId,
      );
      if (currentIndex != -1) {
        currentTitle = bulletinItems[currentIndex].title;
      } else if (bulletinItems.isNotEmpty) {
        // Default to first item if ID not found or empty
        currentTitle = bulletinItems.first.title;
        // Optionally auto-select first item? No, let's just display it.
      }
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final bool canEdit = authProvider.keyIsClerk || authProvider.keyIsAdmin;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Now it is:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: currentIndex > 0
                          ? () {
                              final newItem = bulletinItems[currentIndex - 1];
                              onUpdate(newItem.id);
                            }
                          : null, // Disable if at start
                    )
                  else
                    const SizedBox(width: 40), // Placeholder for spacing
                  // Program Title
                  Expanded(
                    child: Center(
                      child: Text(
                        currentTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  // Next Button
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed:
                          (currentIndex != -1 &&
                              currentIndex < bulletinItems.length - 1)
                          ? () {
                              final newItem = bulletinItems[currentIndex + 1];
                              onUpdate(newItem.id);
                            }
                          : (currentIndex == -1 && bulletinItems.isNotEmpty)
                          ? () =>
                                onUpdate(
                                  bulletinItems.first.id,
                                ) // Start if nothing selected
                          : null,
                    )
                  else
                    const SizedBox(width: 40), // Placeholder for spacing
                ],
              ),
            ),
            if (onOpenNotes != null && authProvider.currentUser != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onOpenNotes,
                  icon: const Icon(Icons.note_alt_outlined),
                  label: const Text('Open Notes'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
