import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_note.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  String buildNoteId(String serviceId, String programItemId) {
    final effectiveProgramId = programItemId.isEmpty
        ? 'general'
        : programItemId;
    return '${serviceId}_$effectiveProgramId';
  }

  Future<UserNote?> getNoteForProgram({
    required String userId,
    required String serviceId,
    required String programItemId,
  }) async {
    try {
      final noteId = buildNoteId(serviceId, programItemId);
      final doc = await _notesRef(userId).doc(noteId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserNote.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Error loading note: $e');
      rethrow;
    }
  }

  Future<void> saveNoteForProgram({
    required String userId,
    required String serviceId,
    required String programItemId,
    required String title,
    required String content,
    String contextType = 'sermon',
  }) async {
    final noteId = buildNoteId(serviceId, programItemId);
    final docRef = _notesRef(userId).doc(noteId);
    final now = Timestamp.now();

    try {
      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(docRef);

        if (existing.exists) {
          transaction.update(docRef, {
            'serviceId': serviceId,
            'programItemId': programItemId,
            'title': title,
            'content': content,
            'contextType': contextType,
            'updatedAt': now,
          });
        } else {
          transaction.set(docRef, {
            'serviceId': serviceId,
            'programItemId': programItemId,
            'title': title,
            'content': content,
            'contextType': contextType,
            'createdAt': now,
            'updatedAt': now,
          });
        }
      });
    } catch (e) {
      debugPrint('Error saving note: $e');
      rethrow;
    }
  }

  Stream<List<UserNote>> watchNotesForService({
    required String userId,
    required String serviceId,
  }) {
    return _notesRef(
      userId,
    ).orderBy('updatedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserNote.fromMap(doc.data(), doc.id))
          .where((note) => note.serviceId == serviceId)
          .toList();
    });
  }
}
