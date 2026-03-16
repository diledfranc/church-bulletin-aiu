import 'package:cloud_firestore/cloud_firestore.dart';

class SabbathService {
  final String id;
  final DateTime serviceDate;
  final String title;
  final DateTime createdAt;

  SabbathService({
    required this.id,
    required this.serviceDate,
    required this.title,
    required this.createdAt,
  });

  factory SabbathService.fromMap(Map<String, dynamic> data, String id) {
    final serviceDateRaw = data['serviceDate'];
    final createdAtRaw = data['createdAt'];

    return SabbathService(
      id: id,
      serviceDate: serviceDateRaw is Timestamp
          ? serviceDateRaw.toDate()
          : DateTime.now(),
      title: (data['title'] ?? '') as String,
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceDate': Timestamp.fromDate(serviceDate),
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
