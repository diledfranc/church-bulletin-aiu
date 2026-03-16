import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/bulletin_item.dart';

class BulletinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsRefForService(
    String serviceId,
  ) {
    return _firestore
        .collection('services')
        .doc(serviceId)
        .collection('program_items');
  }

  CollectionReference<Map<String, dynamic>> get _legacyItemsRef =>
      _firestore.collection('program_items');

  DocumentReference<Map<String, dynamic>> get _statusRef =>
      _firestore.collection('settings').doc('program_status');

  // Create
  Future<void> addBulletinItem(String serviceId, BulletinItem item) async {
    try {
      await _itemsRefForService(serviceId).add(item.toMap());
    } catch (e) {
      debugPrint('Error adding bulletin item: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<BulletinItem>> getBulletinItems(String serviceId) {
    return _itemsRefForService(serviceId).orderBy('time').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return BulletinItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Update
  Future<void> updateBulletinItem(String serviceId, BulletinItem item) async {
    try {
      await _itemsRefForService(serviceId).doc(item.id).update(item.toMap());
    } catch (e) {
      debugPrint('Error updating bulletin item: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteBulletinItem(String serviceId, String id) async {
    try {
      await _itemsRefForService(serviceId).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting bulletin item: $e');
      rethrow;
    }
  }

  // --- Current Program Status ---

  Stream<String> getCurrentProgramId(String serviceId) {
    return _statusRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final byService =
            (data['currentProgramByService'] as Map<String, dynamic>?) ?? {};
        return (byService[serviceId] ?? '') as String;
      }
      return '';
    });
  }

  Future<void> updateCurrentProgramId(String serviceId, String id) async {
    try {
      await _statusRef.set({
        'currentProgramByService.$serviceId': id,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating current program ID: $e');
      rethrow;
    }
  }

  // One-time helper to copy existing top-level items into a selected archive.
  Future<void> copyLegacyItemsIfEmpty(String serviceId) async {
    final target = _itemsRefForService(serviceId);
    final hasTargetData = await target.limit(1).get();
    if (hasTargetData.docs.isNotEmpty) {
      return;
    }

    final legacyDocs = await _legacyItemsRef.orderBy('time').get();
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
