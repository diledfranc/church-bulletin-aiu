import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/announcement.dart';
import '../services/announcement_service.dart';
import '../providers/auth_provider.dart';
import 'edit_announcement_screen.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final announcementService = AnnouncementService();

    return Scaffold(
      body: StreamBuilder<List<Announcement>>(
        stream: announcementService.getAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return const Center(child: Text('No announcements found.'));
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final Announcement announcement = announcements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (authProvider.keyCanEdit)
                            Row(
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
                                            EditAnnouncementScreen(
                                              announcement: announcement,
                                            ),
                                      ),
                                    );
                                    if (result != null &&
                                        result is Announcement) {
                                      await announcementService
                                          .updateAnnouncement(result);
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
                                        title: const Text(
                                          'Delete Announcement',
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this announcement?',
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
                                              await announcementService
                                                  .deleteAnnouncement(
                                                    announcement.id,
                                                  );
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.yMMMd().format(announcement.date),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(announcement.detail),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: authProvider.keyCanEdit
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditAnnouncementScreen(),
                  ),
                );
                if (result != null && result is Announcement) {
                  await announcementService.addAnnouncement(result);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
