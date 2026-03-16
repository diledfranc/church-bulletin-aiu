import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
  });

  factory Event.fromMap(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'dateTime': dateTime, 'location': location};
  }
}
