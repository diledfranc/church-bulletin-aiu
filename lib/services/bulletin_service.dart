import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/bulletin_item.dart';

class BulletinService {
  final CollectionReference _itemsRef = FirebaseFirestore.instance.collection(
    'program_items',
  );

  // Create
  Future<void> addBulletinItem(BulletinItem item) async {
    try {
      await _itemsRef.add(item.toMap());
    } catch (e) {
      debugPrint('Error adding bulletin item: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<BulletinItem>> getBulletinItems() {
    return _itemsRef.orderBy('time').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BulletinItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update
  Future<void> updateBulletinItem(BulletinItem item) async {
    try {
      await _itemsRef.doc(item.id).update(item.toMap());
    } catch (e) {
      debugPrint('Error updating bulletin item: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteBulletinItem(String id) async {
    try {
      await _itemsRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting bulletin item: $e');
      rethrow;
    }
  }
}
