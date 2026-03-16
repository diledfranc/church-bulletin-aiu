import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../data/dummy_data.dart'; // Ensure dummy data is imported

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  contact.name[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.role,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(contact.phoneNumber),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(contact.email),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
