import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bulletin_item.dart';
import '../models/sabbath_service.dart';
import '../services/bulletin_service.dart';
import '../services/sabbath_archive_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/sabbath_info_card.dart';
import '../widgets/current_program_card.dart';
import '../widgets/archive_selector_card.dart';
import 'edit_bulletin_item_screen.dart';
import 'sermon_notes_screen.dart';

class BulletinScreen extends StatefulWidget {
  const BulletinScreen({super.key});

  @override
  State<BulletinScreen> createState() => _BulletinScreenState();
}

class _BulletinScreenState extends State<BulletinScreen> {
  final BulletinService _bulletinService = BulletinService();
  final SabbathArchiveService _archiveService = SabbathArchiveService();
  final Map<String, Future<void>> _prepareCache = {};

  String? _selectedServiceId;

  Future<void> _ensureServicePrepared(String serviceId) {
    return _prepareCache.putIfAbsent(
      serviceId,
      () => _bulletinService.copyLegacyItemsIfEmpty(serviceId),
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

  BulletinItem? _resolveCurrentProgramItem(
    List<BulletinItem> items,
    String currentItemId,
  ) {
    if (items.isEmpty) {
      return null;
    }

    for (final item in items) {
      if (item.id == currentItemId) {
        return item;
      }
    }

    return items.first;
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

                return StreamBuilder<List<BulletinItem>>(
                  stream: _bulletinService.getBulletinItems(selectedServiceId),
                  builder: (context, itemSnapshot) {
                    if (itemSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${itemSnapshot.error}'),
                      );
                    }
                    if (itemSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bulletinItems = itemSnapshot.data ?? [];

                    return StreamBuilder<String>(
                      stream: _bulletinService.getCurrentProgramId(
                        selectedServiceId,
                      ),
                      builder: (context, statusSnapshot) {
                        final currentItemId = statusSnapshot.data ?? '';
                        final currentProgramItem = _resolveCurrentProgramItem(
                          bulletinItems,
                          currentItemId,
                        );
                        SabbathService? selectedService;
                        for (final service in services) {
                          if (service.id == selectedServiceId) {
                            selectedService = service;
                            break;
                          }
                        }

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
                              const SabbathInfoCard(),
                              CurrentProgramCard(
                                bulletinItems: bulletinItems,
                                currentItemId: currentItemId,
                                onUpdate: (String newItemId) {
                                  _bulletinService.updateCurrentProgramId(
                                    selectedServiceId,
                                    newItemId,
                                  );
                                },
                                onOpenNotes: authProvider.currentUser == null
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SermonNotesScreen(
                                                  serviceId: selectedServiceId,
                                                  serviceLabel:
                                                      selectedService?.title ??
                                                      'Current Sabbath',
                                                  programItemId:
                                                      currentProgramItem?.id ??
                                                      '',
                                                  programTitle:
                                                      currentProgramItem
                                                          ?.title ??
                                                      'General Note',
                                                ),
                                          ),
                                        );
                                      },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const EditBulletinItemScreen(),
                                            ),
                                          );
                                          if (result != null &&
                                              result is BulletinItem) {
                                            await _bulletinService
                                                .addBulletinItem(
                                                  selectedServiceId,
                                                  result,
                                                );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                              if (bulletinItems.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'No program items in this Sabbath archive.',
                                    ),
                                  ),
                                )
                              else
                                ...bulletinItems.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    final result =
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditBulletinItemScreen(
                                                                  item: item,
                                                                ),
                                                          ),
                                                        );
                                                    if (result != null &&
                                                        result
                                                            is BulletinItem) {
                                                      await _bulletinService
                                                          .updateBulletinItem(
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
                                                          'Delete Item',
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to delete this item?',
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
                                                              await _bulletinService
                                                                  .deleteBulletinItem(
                                                                    selectedServiceId,
                                                                    item.id,
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
