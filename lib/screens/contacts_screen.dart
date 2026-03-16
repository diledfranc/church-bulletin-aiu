import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../providers/auth_provider.dart';
import 'edit_contact_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final contactService = ContactService();

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: StreamBuilder<List<Contact>>(
        stream: contactService.getContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const Center(child: Text('No contacts found.'));
          }

          return ListView.builder(
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
                      contact.name.isNotEmpty ? contact.name[0] : '?',
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
                                        EditContactScreen(contact: contact),
                                  ),
                                );
                                if (result != null && result is Contact) {
                                  await contactService.updateContact(result);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Contact'),
                                    content: const Text(
                                      'Are you sure you want to delete this contact?',
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
                                          await contactService.deleteContact(
                                            contact.id,
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
          );
        },
      ),
      floatingActionButton: authProvider.keyCanEdit
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditContactScreen(),
                  ),
                );
                if (result != null && result is Contact) {
                  await contactService.addContact(result);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
