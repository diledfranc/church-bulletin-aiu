import '../models/bulletin_item.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import '../models/contact.dart';

final List<BulletinItem> bulletinItems = [
  // ... existing content ...
  BulletinItem(title: 'Benediction', description: 'Pastor'),
];

final List<Announcement> announcements = [
  Announcement(
    title: 'Bible Study',
    detail:
        'Join us for Bible study every Wednesday at 7:00 PM in the main hall.',
    date: DateTime.now().add(const Duration(days: 2)),
  ),
  Announcement(
    title: 'Community Service',
    detail:
        'We will be visiting the local shelter this Saturday. Meet at the church at 9:00 AM.',
    date: DateTime.now().add(const Duration(days: 5)),
  ),
  Announcement(
    title: 'Choir Practice',
    detail: 'Choir practice is held every Thursday at 6:30 PM.',
    date: DateTime.now().add(const Duration(days: 3)),
  ),
];

final List<Event> events = [
  Event(
    title: 'Youth Camp',
    dateTime: DateTime.now().add(const Duration(days: 10)),
    location: 'Campground A',
  ),
  Event(
    title: 'Health Seminar',
    dateTime: DateTime.now().add(const Duration(days: 14)),
    location: 'Fellowship Hall',
  ),
  Event(
    title: 'Pathfinder Club Meeting',
    dateTime: DateTime.now().add(const Duration(days: 7)),
    location: 'Room 101',
  ),
];

final List<Contact> contacts = [
  Contact(
    name: 'Pastor John Doe',
    role: 'Senior Pastor',
    phoneNumber: '+1234567890',
    email: 'pastor.john@example.com',
  ),
  Contact(
    name: 'Jane Smith',
    role: 'Head Elder',
    phoneNumber: '+0987654321',
    email: 'jane.smith@example.com',
  ),
  Contact(
    name: 'Church Office',
    role: 'Administration',
    phoneNumber: '+1122334455',
    email: 'office@example.com',
  ),
];
