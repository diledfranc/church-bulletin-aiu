import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _announcementsRefForService(
    String serviceId,
  ) {
    return _firestore
        .collection('services')
        .doc(serviceId)
        .collection('announcements');
  }

  CollectionReference<Map<String, dynamic>> get _legacyAnnouncementsRef =>
      _firestore.collection('announcements');

  // Create
  Future<void> addAnnouncement(
    String serviceId,
    Announcement announcement,
  ) async {
    try {
      await _announcementsRefForService(serviceId).add(announcement.toMap());
    } catch (e) {
      debugPrint('Error adding announcement: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<Announcement>> getAnnouncements(String serviceId) {
    return _announcementsRefForService(
      serviceId,
    ).orderBy('date', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Announcement.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Update
  Future<void> updateAnnouncement(
    String serviceId,
    Announcement announcement,
  ) async {
    try {
      await _announcementsRefForService(
        serviceId,
      ).doc(announcement.id).update(announcement.toMap());
    } catch (e) {
      debugPrint('Error updating announcement: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteAnnouncement(String serviceId, String id) async {
    try {
      await _announcementsRefForService(serviceId).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      rethrow;
    }
  }

  // One-time helper to copy existing top-level announcements into a selected archive.
  Future<void> copyLegacyAnnouncementsIfEmpty(String serviceId) async {
    final target = _announcementsRefForService(serviceId);
    final hasTargetData = await target.limit(1).get();
    if (hasTargetData.docs.isNotEmpty) {
      return;
    }

    final legacyDocs = await _legacyAnnouncementsRef
        .orderBy('date', descending: false)
        .get();
    if (legacyDocs.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final legacyDoc in legacyDocs.docs) {
      final newRef = target.doc();
      batch.set(newRef, legacyDoc.data());
    }
    await batch.commit();
  }
}
