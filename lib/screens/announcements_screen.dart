import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/announcement.dart';
import '../models/sabbath_service.dart';
import '../services/announcement_service.dart';
import '../services/sabbath_archive_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/archive_selector_card.dart';
import 'edit_announcement_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final AnnouncementService _announcementService = AnnouncementService();
  final SabbathArchiveService _archiveService = SabbathArchiveService();
  final Map<String, Future<void>> _prepareCache = {};

  String? _selectedServiceId;

  Future<void> _ensureServicePrepared(String serviceId) {
    return _prepareCache.putIfAbsent(
      serviceId,
      () => _announcementService.copyLegacyAnnouncementsIfEmpty(serviceId),
    );
  }

  Future<void> _createOrOpenNextSabbath() async {
    final serviceId = await _archiveService.createNextSabbathAndActivate();
    await _ensureServicePrepared(serviceId);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedServiceId = serviceId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final canBrowseArchives = authProvider.keyCanEdit;

    return StreamBuilder<String>(
      stream: _archiveService.watchActiveServiceId(),
      builder: (context, activeSnapshot) {
        if (activeSnapshot.hasError) {
          return Center(child: Text('Error: ${activeSnapshot.error}'));
        }
        if (activeSnapshot.connectionState == ConnectionState.waiting &&
            !activeSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeServiceId = activeSnapshot.data ?? '';
        if (activeServiceId.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final selectedServiceId = canBrowseArchives
            ? (_selectedServiceId ?? activeServiceId)
            : activeServiceId;

        return FutureBuilder<void>(
          future: _ensureServicePrepared(selectedServiceId),
          builder: (context, prepareSnapshot) {
            if (prepareSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prepareSnapshot.hasError) {
              return Center(child: Text('Error: ${prepareSnapshot.error}'));
            }

            return StreamBuilder<List<SabbathService>>(
              stream: _archiveService.getServices(),
              builder: (context, serviceSnapshot) {
                if (serviceSnapshot.hasError) {
                  return Center(child: Text('Error: ${serviceSnapshot.error}'));
                }

                final services = serviceSnapshot.data ?? <SabbathService>[];

                return StreamBuilder<List<Announcement>>(
                  stream: _announcementService.getAnnouncements(
                    selectedServiceId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final announcements = snapshot.data ?? [];

                    return Scaffold(
                      body: ListView(
                        children: [
                          if (canBrowseArchives)
                            ArchiveSelectorCard(
                              services: services,
                              selectedServiceId: selectedServiceId,
                              activeServiceId: activeServiceId,
                              canEdit: authProvider.keyCanEdit,
                              onChanged: (value) {
                                if (value == null || value.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _selectedServiceId = value;
                                });
                              },
                              onCreateNextSabbath: () async {
                                await _createOrOpenNextSabbath();
                              },
                              onSetActive: () async {
                                await _archiveService.setActiveServiceId(
                                  selectedServiceId,
                                );
                              },
                            ),
                          if (announcements.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No announcements in this Sabbath archive.',
                                ),
                              ),
                            )
                          else
                            ...announcements.map((announcement) {
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              announcement.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                                                              announcement:
                                                                  announcement,
                                                            ),
                                                      ),
                                                    );
                                                    if (result != null &&
                                                        result
                                                            is Announcement) {
                                                      await _announcementService
                                                          .updateAnnouncement(
                                                            selectedServiceId,
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
                                                        title: const Text(
                                                          'Delete Announcement',
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to delete this announcement?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  ctx,
                                                                ).pop(),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              Navigator.of(
                                                                ctx,
                                                              ).pop();
                                                              await _announcementService
                                                                  .deleteAnnouncement(
                                                                    selectedServiceId,
                                                                    announcement
                                                                        .id,
                                                                  );
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                            ),
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
                                          const Icon(
                                            Icons.event,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat.yMMMd().format(
                                              announcement.date,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(announcement.detail),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 80),
                        ],
                      ),
                      floatingActionButton: authProvider.keyCanEdit
                          ? FloatingActionButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditAnnouncementScreen(),
                                  ),
                                );
                                if (result != null && result is Announcement) {
                                  await _announcementService.addAnnouncement(
                                    selectedServiceId,
                                    result,
                                  );
                                }
                              },
                              child: const Icon(Icons.add),
                            )
                          : null,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
