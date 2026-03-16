import 'package:flutter/material.dart';
import '../models/bulletin_item.dart';
import '../data/dummy_data.dart';
import '../widgets/sabbath_info_card.dart';
import '../widgets/current_program_card.dart';

class BulletinScreen extends StatelessWidget {
  const BulletinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SabbathInfoCard(),
        const CurrentProgramCard(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Program Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...bulletinItems.asMap().entries.map((entry) {
          int index = entry.key;
          BulletinItem item = entry.value;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              subtitle: Text(item.description),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}
