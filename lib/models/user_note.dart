import 'package:cloud_firestore/cloud_firestore.dart';

class UserNote {
  final String id;
  final String serviceId;
  final String programItemId;
  final String title;
  final String content;
  final String contextType;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserNote({
    required this.id,
    required this.serviceId,
    required this.programItemId,
    required this.title,
    required this.content,
    required this.contextType,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  factory UserNote.fromMap(Map<String, dynamic> data, String id) {
    return UserNote(
      id: id,
      serviceId: (data['serviceId'] ?? '') as String,
      programItemId: (data['programItemId'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      content: (data['content'] ?? '') as String,
      contextType: (data['contextType'] ?? 'sermon') as String,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }
}
