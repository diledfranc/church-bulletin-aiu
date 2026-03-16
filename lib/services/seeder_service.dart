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

      await seedSabbathArchives();
      await _seedEventsIfEmpty();
      await _seedContactsIfEmpty();

      debugPrint('Seeding complete.');
    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }

  Future<void> seedSabbathArchives({
    int pastWeeks = 6,
    int futureWeeks = 3,
    bool overwriteExisting = false,
  }) async {
    final statusRef = _firestore.collection('settings').doc('program_status');
    final now = DateTime.now();
    final activeSabbath = _nextSabbathDate(now);

    String? activeServiceId;
    final statusUpdate = <String, dynamic>{};

    for (int weekOffset = -pastWeeks; weekOffset <= futureWeeks; weekOffset++) {
      final serviceDate = activeSabbath.add(Duration(days: weekOffset * 7));
      final serviceId = await _createOrGetServiceForDate(serviceDate);

      if (_isSameDate(serviceDate, activeSabbath)) {
        activeServiceId = serviceId;
      }

      final serviceDoc = _firestore.collection('services').doc(serviceId);
      final programRef = serviceDoc.collection('program_items');
      final announcementsRef = serviceDoc.collection('announcements');

      if (overwriteExisting) {
        await _clearCollection(programRef);
        await _clearCollection(announcementsRef);
      }

      final programExisting = await programRef.limit(1).get();
      String? firstProgramId;

      if (programExisting.docs.isEmpty) {
        firstProgramId = await _seedProgramItemsForService(
          serviceId: serviceId,
          serviceDate: serviceDate,
          weekOffset: weekOffset,
        );
      } else {
        firstProgramId = programExisting.docs.first.id;
      }

      final announcementsExisting = await announcementsRef.limit(1).get();
      if (announcementsExisting.docs.isEmpty) {
        await _seedAnnouncementsForService(
          serviceId: serviceId,
          serviceDate: serviceDate,
          weekOffset: weekOffset,
        );
      }

      if (firstProgramId != null && firstProgramId.isNotEmpty) {
        statusUpdate['currentProgramByService.$serviceId'] = firstProgramId;
      }

      debugPrint(
        'Seeded Sabbath archive ${serviceDate.toIso8601String().split('T').first} ($serviceId)',
      );
    }

    if (activeServiceId != null) {
      statusUpdate['activeServiceId'] = activeServiceId;
      await statusRef.set(statusUpdate, SetOptions(merge: true));
    }

    debugPrint('Sabbath archive seeding complete.');
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _nextSabbathDate(DateTime base) {
    final normalized = _toDateOnly(base);
    final daysUntilSaturday = (DateTime.saturday - normalized.weekday) % 7;
    return normalized.add(Duration(days: daysUntilSaturday));
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<String> _createOrGetServiceForDate(DateTime date) async {
    final dateOnly = _toDateOnly(date);
    final start = Timestamp.fromDate(dateOnly);
    final end = Timestamp.fromDate(dateOnly.add(const Duration(days: 1)));

    final existing = await _firestore
        .collection('services')
        .where('serviceDate', isGreaterThanOrEqualTo: start)
        .where('serviceDate', isLessThan: end)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final created = await _firestore.collection('services').add({
      'serviceDate': Timestamp.fromDate(dateOnly),
      'title': _buildServiceTitle(dateOnly),
      'createdAt': Timestamp.now(),
    });

    return created.id;
  }

  String _buildServiceTitle(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Sabbath ${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<String?> _seedProgramItemsForService({
    required String serviceId,
    required DateTime serviceDate,
    required int weekOffset,
  }) async {
    final sermonTitles = [
      'Faith That Works',
      'Hope in the Storm',
      'The Call to Discipleship',
      'Walking in Grace',
      'Living the Word Daily',
      'A Heart for Mission',
      'The Joy of Service',
      'Light for the World',
      'Trusting God in Uncertainty',
    ];

    final scripturePassages = [
      'James 2:17',
      'Psalm 46:1',
      'Matthew 28:19-20',
      'Ephesians 2:8-9',
      'Psalm 119:105',
      'Acts 1:8',
      'Galatians 5:13',
      'Matthew 5:14-16',
      'Proverbs 3:5-6',
    ];

    final hymnNumbers = [15, 22, 34, 58, 76, 91, 103, 118, 126];
    final index = weekOffset.abs() % sermonTitles.length;

    final programItems = [
      BulletinItem(
        id: '',
        title: 'Prelude',
        description: 'Instrumental Meditation',
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
        description: 'Hymn #${hymnNumbers[index]}',
        time: '11:00 AM',
      ),
      BulletinItem(
        id: '',
        title: 'Scripture Reading',
        description: scripturePassages[index],
        time: '11:10 AM',
      ),
      BulletinItem(
        id: '',
        title: 'Pastoral Prayer',
        description: 'Pastor / Elder Team',
        time: '11:15 AM',
      ),
      BulletinItem(
        id: '',
        title: 'Special Music',
        description: 'Worship Team',
        time: '11:20 AM',
      ),
      BulletinItem(
        id: '',
        title: 'Sermon',
        description: sermonTitles[index],
        time: '11:30 AM',
      ),
      BulletinItem(
        id: '',
        title: 'Closing Hymn',
        description: 'Congregation',
        time: '12:15 PM',
      ),
      BulletinItem(
        id: '',
        title: 'Benediction',
        description: 'Pastor',
        time: '12:20 PM',
      ),
    ];

    final programRef = _firestore
        .collection('services')
        .doc(serviceId)
        .collection('program_items');

    String? firstProgramId;
    final batch = _firestore.batch();
    for (int i = 0; i < programItems.length; i++) {
      final docRef = programRef.doc();
      if (i == 0) {
        firstProgramId = docRef.id;
      }
      batch.set(docRef, programItems[i].toMap());
    }
    await batch.commit();

    debugPrint(
      'Program items seeded for ${serviceDate.toIso8601String().split('T').first}',
    );
    return firstProgramId;
  }

  Future<void> _seedAnnouncementsForService({
    required String serviceId,
    required DateTime serviceDate,
    required int weekOffset,
  }) async {
    final index = weekOffset.abs() % 5;
    final announcements = [
      Announcement(
        id: '',
        title: 'Midweek Prayer Meeting',
        detail:
            'Join us on Wednesday at 7:00 PM for prayer and testimony sharing in the main hall.',
        date: serviceDate.subtract(const Duration(days: 3)),
      ),
      Announcement(
        id: '',
        title: 'Sabbath School Fellowship Lunch',
        detail:
            'Potluck lunch follows the service. Bring a dish to share with visitors and members.',
        date: serviceDate,
      ),
      Announcement(
        id: '',
        title: 'Youth Vespers',
        detail:
            'Youth vespers this Friday at 6:30 PM. Theme track ${index + 1}: growing together in Christ.',
        date: serviceDate.subtract(const Duration(days: 1)),
      ),
      Announcement(
        id: '',
        title: 'Community Outreach',
        detail:
            'Outreach activity next Sunday morning. Meet at church by 8:00 AM.',
        date: serviceDate.add(const Duration(days: 1)),
      ),
      Announcement(
        id: '',
        title: 'Prayer Requests',
        detail:
            'Submit prayer requests through the app notes and prayer channels before Friday evening.',
        date: serviceDate.subtract(const Duration(days: 2)),
      ),
    ];

    final announcementsRef = _firestore
        .collection('services')
        .doc(serviceId)
        .collection('announcements');

    final batch = _firestore.batch();
    for (final announcement in announcements) {
      final docRef = announcementsRef.doc();
      batch.set(docRef, announcement.toMap());
    }
    await batch.commit();

    debugPrint(
      'Announcements seeded for ${serviceDate.toIso8601String().split('T').first}',
    );
  }

  Future<void> _clearCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();
    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _seedEventsIfEmpty() async {
    final eventsCollection = _firestore.collection('events');
    final hasEvents = await eventsCollection.limit(1).get();
    if (hasEvents.docs.isNotEmpty) {
      return;
    }

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

    final batch = _firestore.batch();
    for (final event in events) {
      final docRef = eventsCollection.doc();
      batch.set(docRef, event.toMap());
    }
    await batch.commit();
    debugPrint('Events seeded.');
  }

  Future<void> _seedContactsIfEmpty() async {
    final contactsCollection = _firestore.collection('contacts');
    final hasContacts = await contactsCollection.limit(1).get();
    if (hasContacts.docs.isNotEmpty) {
      return;
    }

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

    final batch = _firestore.batch();
    for (final contact in contacts) {
      final docRef = contactsCollection.doc();
      batch.set(docRef, contact.toMap());
    }
    await batch.commit();
    debugPrint('Contacts seeded.');
  }
}
