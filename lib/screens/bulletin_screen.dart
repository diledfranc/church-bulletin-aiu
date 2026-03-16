import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bulletin_item.dart';
import '../services/bulletin_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/sabbath_info_card.dart';
import '../widgets/current_program_card.dart';
import 'edit_bulletin_item_screen.dart';

class BulletinScreen extends StatelessWidget {
  const BulletinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bulletinService = BulletinService();

    return StreamBuilder<List<BulletinItem>>(
      stream: bulletinService.getBulletinItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bulletinItems = snapshot.data ?? [];

        return Scaffold(
          body: ListView(
            children: [
              const SabbathInfoCard(),
              const CurrentProgramCard(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Program Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (authProvider.keyCanEdit)
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EditBulletinItemScreen(),
                            ),
                          );
                          if (result != null && result is BulletinItem) {
                            await bulletinService.addBulletinItem(result);
                          }
                        },
                      ),
                  ],
                ),
              ),
              if (bulletinItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No program items yet.')),
                )
              else
                ...bulletinItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  BulletinItem item = entry.value;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.description),
                          if (item.time.isNotEmpty)
                            Text(
                              item.time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: authProvider.keyCanEdit
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditBulletinItemScreen(item: item),
                                      ),
                                    );
                                    if (result != null &&
                                        result is BulletinItem) {
                                      await bulletinService.updateBulletinItem(
                                        result,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Item'),
                                        content: const Text(
                                          'Are you sure you want to delete this item?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(ctx).pop();
                                              await bulletinService
                                                  .deleteBulletinItem(item.id);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
