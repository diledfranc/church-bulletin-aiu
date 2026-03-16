class BulletinItem {
  final String id;
  final String title;
  final String description;
  final String time;

  BulletinItem({
    required this.id,
    required this.title,
    required this.description,
    this.time = '',
  });

  factory BulletinItem.fromMap(Map<String, dynamic> data, String id) {
    return BulletinItem(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'description': description, 'time': time};
  }
}
