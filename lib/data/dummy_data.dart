import '../models/bulletin_item.dart';
import '../models/announcement.dart';

final List<BulletinItem> bulletinItems = [
  BulletinItem(title: 'Prelude', description: 'Organist'),
  BulletinItem(title: 'Welcome & Announcements', description: 'Elder on Duty'),
  BulletinItem(
    title: 'Opening Hymn',
    description: 'Hymn #1: Praise to the Lord',
  ),
  BulletinItem(title: 'Scripture Reading', description: 'Psalm 23'),
  BulletinItem(title: 'Prayer', description: 'Deacon'),
  BulletinItem(title: 'Special Music', description: 'Choir'),
  BulletinItem(title: 'Sermon', description: 'Title: "Faith and Works"'),
  BulletinItem(
    title: 'Closing Hymn',
    description: 'Hymn #5: All Creatures of Our God and King',
  ),
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
