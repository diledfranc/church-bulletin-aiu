import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/duty_roster_item.dart';
import '../services/duty_roster_service.dart';
import '../providers/auth_provider.dart';
import 'edit_duty_roster_screen.dart';

class DutyRosterScreen extends StatelessWidget {
  const DutyRosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rosterService = DutyRosterService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duty Roster'),
      ), // App bar for when pushed
      body: StreamBuilder<List<DutyRosterItem>>(
        stream: rosterService.getDutyRosterItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rosterItems = snapshot.data ?? [];

          return Column(
            children: [
              if (authProvider.keyCanEdit)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Duty Assignment'),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditDutyRosterScreen(),
                        ),
                      );
                      if (result != null && result is DutyRosterItem) {
                        await rosterService.addDutyRosterItem(result);
                      }
                    },
                  ),
                ),
              Expanded(
                child: rosterItems.isEmpty
                    ? const Center(child: Text('No duties assigned.'))
                    : ListView.builder(
                        itemCount: rosterItems.length,
                        itemBuilder: (context, index) {
                          final item = rosterItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  item.role.isNotEmpty ? item.role[0] : '?',
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item.role} - ${DateFormat.yMMMd().format(item.date)}',
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
                                                    EditDutyRosterScreen(
                                                      item: item,
                                                    ),
                                              ),
                                            );
                                            if (result != null &&
                                                result is DutyRosterItem) {
                                              await rosterService
                                                  .updateDutyRosterItem(result);
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
                                                  'Delete Assignment',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to delete this assignment?',
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
                                                      await rosterService
                                                          .deleteDutyRosterItem(
                                                            item.id,
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
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
