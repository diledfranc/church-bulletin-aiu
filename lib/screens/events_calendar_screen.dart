import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../providers/auth_provider.dart';
import 'edit_event_screen.dart';

class EventsCalendarScreen extends StatelessWidget {
  const EventsCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventService = EventService();

    return Scaffold(
      appBar: AppBar(title: const Text('Events Calendar')),
      body: StreamBuilder<List<Event>>(
        stream: eventService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('No upcoming events.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.d().format(event.dateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            DateFormat.MMM()
                                .format(event.dateTime)
                                .toUpperCase(),
                            style: const TextStyle(fontSize: 10, height: 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${DateFormat.jm().format(event.dateTime)} • ${event.location}',
                  ),
                  trailing: authProvider.keyCanEdit
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditEventScreen(event: event),
                                  ),
                                );
                                if (result != null && result is Event) {
                                  await eventService.updateEvent(result);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Event'),
                                    content: const Text(
                                      'Are you sure you want to delete this event?',
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
                                          await eventService.deleteEvent(
                                            event.id,
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
                      : const Icon(Icons.chevron_right),
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
                    builder: (context) => const EditEventScreen(),
                  ),
                );
                if (result != null && result is Event) {
                  await eventService.addEvent(result);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
