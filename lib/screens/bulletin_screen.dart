import 'package:flutter/material.dart';
import '../models/bulletin_item.dart';
import '../data/dummy_data.dart';

class BulletinScreen extends StatelessWidget {
  const BulletinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bulletinItems.length,
      itemBuilder: (context, index) {
        final BulletinItem item = bulletinItems[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.description),
          ),
        );
      },
    );
  }
}
