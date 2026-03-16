import 'package:cloud_firestore/cloud_firestore.dart';

class DutyRosterItem {
  final String id;
  final String role;
  final String name;
  final DateTime date;

  DutyRosterItem({
    required this.id,
    required this.role,
    required this.name,
    required this.date,
  });

  factory DutyRosterItem.fromMap(Map<String, dynamic> data, String id) {
    return DutyRosterItem(
      id: id,
      role: data['role'] ?? '',
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'role': role, 'name': name, 'date': Timestamp.fromDate(date)};
  }
}
