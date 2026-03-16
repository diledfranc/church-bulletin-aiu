import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactService {
  final CollectionReference _contactsRef = FirebaseFirestore.instance
      .collection('contacts');

  // Create
  Future<void> addContact(Contact contact) async {
    try {
      await _contactsRef.add(contact.toMap());
    } catch (e) {
      debugPrint('Error adding contact: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<Contact>> getContacts() {
    return _contactsRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update
  Future<void> updateContact(Contact contact) async {
    try {
      await _contactsRef.doc(contact.id).update(contact.toMap());
    } catch (e) {
      debugPrint('Error updating contact: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteContact(String id) async {
    try {
      await _contactsRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      rethrow;
    }
  }
}
