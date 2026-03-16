import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/duty_roster_item.dart';

class DutyRosterService {
  final CollectionReference _rosterRef = FirebaseFirestore.instance.collection(
    'duty_roster',
  );

  // Create
  Future<void> addDutyRosterItem(DutyRosterItem item) async {
    try {
      await _rosterRef.add(item.toMap());
    } catch (e) {
      debugPrint('Error adding duty roster item: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<DutyRosterItem>> getDutyRosterItems() {
    return _rosterRef.orderBy('date').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DutyRosterItem.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Update
  Future<void> updateDutyRosterItem(DutyRosterItem item) async {
    try {
      await _rosterRef.doc(item.id).update(item.toMap());
    } catch (e) {
      debugPrint('Error updating duty roster item: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteDutyRosterItem(String id) async {
    try {
      await _rosterRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting duty roster item: $e');
      rethrow;
    }
  }
}
