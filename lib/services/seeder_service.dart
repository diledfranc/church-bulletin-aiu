import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/bulletin_item.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import '../models/contact.dart';

class SeederService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedFirestore() async {
    try {
      debugPrint('Seeding database...');

      // Seed Bulletin Items
      final itemsCollection = _firestore.collection('program_items');
      final bulletinItems = [
        BulletinItem(
          id: '',
          title: 'Prelude',
          description: 'Organist',
          time: '10:45 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Welcome & Announcements',
          description: 'Elder on Duty',
          time: '10:55 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Opening Hymn',
          description: 'Hymn #1: Praise to the Lord',
          time: '11:00 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Scripture Reading',
          description: 'Psalm 23',
          time: '11:10 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Prayer',
          description: 'Deacon',
          time: '11:15 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Special Music',
          description: 'Choir',
          time: '11:20 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Sermon',
          description: 'Title: "Faith and Works"',
          time: '11:25 AM',
        ),
        BulletinItem(
          id: '',
          title: 'Closing Hymn',
          description: 'Hymn #5: All Creatures of Our God and King',
          time: '12:15 PM',
        ),
        BulletinItem(
          id: '',
          title: 'Benediction',
          description: 'Pastor',
          time: '12:20 PM',
        ),
      ];

      for (var item in bulletinItems) {
        await itemsCollection.add(item.toMap());
      }
      debugPrint('Program items seeded.');

      // Seed Announcements
      final announcementsCollection = _firestore.collection('announcements');
      final announcements = [
        Announcement(
          id: '',
          title: 'Bible Study',
          detail:
              'Join us for Bible study every Wednesday at 7:00 PM in the main hall.',
          date: DateTime.now().add(const Duration(days: 2)),
        ),
        Announcement(
          id: '',
          title: 'Community Service',
          detail:
              'We will be visiting the local shelter this Saturday. Meet at the church at 9:00 AM.',
          date: DateTime.now().add(const Duration(days: 5)),
        ),
        Announcement(
          id: '',
          title: 'Choir Practice',
          detail: 'Choir practice is held every Thursday at 6:30 PM.',
          date: DateTime.now().add(const Duration(days: 3)),
        ),
      ];

      for (var announcement in announcements) {
        await announcementsCollection.add(announcement.toMap());
      }
      debugPrint('Announcements seeded.');

      // Seed Events
      final eventsCollection = _firestore.collection('events');
      final events = [
        Event(
          id: '',
          title: 'Youth Camp',
          dateTime: DateTime.now().add(const Duration(days: 10)),
          location: 'Campground A',
        ),
        Event(
          id: '',
          title: 'Health Seminar',
          dateTime: DateTime.now().add(const Duration(days: 14)),
          location: 'Fellowship Hall',
        ),
        Event(
          id: '',
          title: 'Pathfinder Club Meeting',
          dateTime: DateTime.now().add(const Duration(days: 7)),
          location: 'Room 101',
        ),
      ];

      for (var event in events) {
        await eventsCollection.add(event.toMap());
      }
      debugPrint('Events seeded.');

      // Seed Contacts
      final contactsCollection = _firestore.collection('contacts');
      final contacts = [
        Contact(
          id: '',
          name: 'Pastor John Doe',
          role: 'Senior Pastor',
          phoneNumber: '+1234567890',
          email: 'pastor.john@example.com',
        ),
        Contact(
          id: '',
          name: 'Jane Smith',
          role: 'Head Elder',
          phoneNumber: '+0987654321',
          email: 'jane.smith@example.com',
        ),
        Contact(
          id: '',
          name: 'Church Office',
          role: 'Administration',
          phoneNumber: '+1122334455',
          email: 'office@example.com',
        ),
      ];

      for (var contact in contacts) {
        await contactsCollection.add(contact.toMap());
      }
      debugPrint('Contacts seeded.');

      debugPrint('Seeding complete.');
    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }
}
