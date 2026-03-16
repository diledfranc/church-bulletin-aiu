import '../models/bulletin_item.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import '../models/contact.dart';
import '../models/duty_roster_item.dart';

final List<BulletinItem> bulletinItems = [
  BulletinItem(
    id: '1',
    title: 'Prelude',
    description: 'Organist',
    time: '10:45 AM',
  ),
  BulletinItem(
    id: '2',
    title: 'Welcome & Announcements',
    description: 'Elder on Duty',
    time: '10:55 AM',
  ),
  BulletinItem(
    id: '3',
    title: 'Opening Hymn',
    description: 'Hymn #1: Praise to the Lord',
    time: '11:00 AM',
  ),
  BulletinItem(
    id: '4',
    title: 'Scripture Reading',
    description: 'Psalm 23',
    time: '11:10 AM',
  ),
  BulletinItem(
    id: '5',
    title: 'Prayer',
    description: 'Deacon',
    time: '11:15 AM',
  ),
  BulletinItem(id: '6', title: 'Special Music', description: 'Church Choir'),
  BulletinItem(id: '7', title: 'Sermon', description: 'Guest Speaker'),
  BulletinItem(
    id: '8',
    title: 'Closing Hymn',
    description: 'Hymn #100: Great is Thy Faithfulness',
  ),
  BulletinItem(id: '9', title: 'Benediction', description: 'Pastor'),
];

final List<Announcement> announcements = [
  Announcement(
    id: '1',
    title: 'Bible Study',
    detail:
        'Join us for Bible study every Wednesday at 7:00 PM in the main hall.',
    date: DateTime.now().add(const Duration(days: 2)),
  ),
  Announcement(
    id: '2',
    title: 'Community Service',
    detail:
        'We will be visiting the local shelter this Saturday. Meet at the church at 9:00 AM.',
    date: DateTime.now().add(const Duration(days: 5)),
  ),
  Announcement(
    id: '3',
    title: 'Choir Practice',
    detail: 'Choir practice is held every Thursday at 6:30 PM.',
    date: DateTime.now().add(const Duration(days: 3)),
  ),
];

final List<Event> events = [
  Event(
    id: '1',
    title: 'Youth Camp',
    dateTime: DateTime.now().add(const Duration(days: 10)),
    location: 'Campground A',
  ),
  Event(
    id: '2',
    title: 'Health Seminar',
    dateTime: DateTime.now().add(const Duration(days: 14)),
    location: 'Fellowship Hall',
  ),
  Event(
    id: '3',
    title: 'Pathfinder Club Meeting',
    dateTime: DateTime.now().add(const Duration(days: 7)),
    location: 'Room 101',
  ),
];

final List<Contact> contacts = [
  Contact(
    id: '1',
    name: 'Pastor John Doe',
    role: 'Senior Pastor',
    phoneNumber: '+1234567890',
    email: 'pastor.john@example.com',
  ),
  Contact(
    id: '2',
    name: 'Jane Smith',
    role: 'Head Elder',
    phoneNumber: '+0987654321',
    email: 'jane.smith@example.com',
  ),
  Contact(
    id: '3',
    name: 'Church Office',
    role: 'Administration',
    phoneNumber: '+1122334455',
    email: 'office@example.com',
  ),
];

final List<DutyRosterItem> dutyRosterItems = [
  DutyRosterItem(
    id: '1',
    role: 'Greeter',
    name: 'Sister Mary',
    date: DateTime.now().add(const Duration(days: 6)), // Next Sabbath
  ),
  DutyRosterItem(
    id: '2',
    role: 'Deacon',
    name: 'Brother James',
    date: DateTime.now().add(const Duration(days: 6)),
  ),
  DutyRosterItem(
    id: '3',
    role: 'Elder',
    name: 'Elder Smith',
    date: DateTime.now().add(const Duration(days: 6)),
  ),
];
