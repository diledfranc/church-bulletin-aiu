import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../data/dummy_data.dart'; // Ensure dummy data is imported or pass data

class EventsCalendarScreen extends StatelessWidget {
  const EventsCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming events list is imported or available globally from dummy_data.dart
    // If not, we might need to import it.
    // Let's assume dummy_data.dart exports 'events' list.

    return Scaffold(
      appBar: AppBar(title: const Text('Events Calendar')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat.d().format(event.dateTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      DateFormat.MMM().format(event.dateTime).toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${DateFormat.jm().format(event.dateTime)} • ${event.location}',
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
