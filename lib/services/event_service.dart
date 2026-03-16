import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventService {
  final CollectionReference _eventsRef = FirebaseFirestore.instance.collection(
    'events',
  );

  // Create
  Future<void> addEvent(Event event) async {
    try {
      await _eventsRef.add(event.toMap());
    } catch (e) {
      debugPrint('Error adding event: $e');
      rethrow;
    }
  }

  // Read
  Stream<List<Event>> getEvents() {
    return _eventsRef.orderBy('dateTime', descending: false).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update
  Future<void> updateEvent(Event event) async {
    try {
      await _eventsRef.doc(event.id).update(event.toMap());
    } catch (e) {
      debugPrint('Error updating event: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteEvent(String id) async {
    try {
      await _eventsRef.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting event: $e');
      rethrow;
    }
  }
}
