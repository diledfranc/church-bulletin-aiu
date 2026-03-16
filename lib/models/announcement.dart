class Announcement {
  final String id;
  final String title;
  final String detail;
  final DateTime date;

  Announcement({
    required this.id,
    required this.title,
    required this.detail,
    required this.date,
  });

  factory Announcement.fromMap(Map<String, dynamic> data, String id) {
    return Announcement(
      id: id,
      title: data['title'] ?? '',
      detail: data['detail'] ?? '',
      date: (data['date'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'detail': detail, 'date': date};
  }
}
