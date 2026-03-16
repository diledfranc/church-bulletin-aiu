import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementService {
  final CollectionReference _announcementsRef = FirebaseFirestore.instance
      .collection('announcements');

  // Create
  Future<void> addAnnouncement(Announcement announcement) async {
    try {
      await _announcementsRef.add(announcement.toMap());
    } catch (e) {
      debugPrint('Error adding announcement: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<Announcement>> getAnnouncements() {
    return _announcementsRef.orderBy('date', descending: false).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return Announcement.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      },
    );
  }

  // Update
  Future<void> updateAnnouncement(Announcement announcement) async {
    try {
      await _announcementsRef.doc(announcement.id).update(announcement.toMap());
    } catch (e) {
      debugPrint('Error updating announcement: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _announcementsRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      rethrow;
    }
  }
}
