import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/sabbath_service.dart';

class SabbathArchiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _servicesRef =>
      _firestore.collection('services');

  DocumentReference<Map<String, dynamic>> get _statusRef =>
      _firestore.collection('settings').doc('program_status');

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _buildServiceTitle(DateTime date) {
    return 'Sabbath ${DateFormat.yMMMd().format(date)}';
  }

  DateTime _nextSabbathDate([DateTime? base]) {
    final now = _toDateOnly(base ?? DateTime.now());
    final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    return now.add(Duration(days: daysUntilSaturday));
  }

  Future<String> createServiceForDate(DateTime date) async {
    final dateOnly = _toDateOnly(date);
    final start = Timestamp.fromDate(dateOnly);
    final end = Timestamp.fromDate(dateOnly.add(const Duration(days: 1)));

    final existing = await _servicesRef
        .where('serviceDate', isGreaterThanOrEqualTo: start)
        .where('serviceDate', isLessThan: end)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final doc = await _servicesRef.add({
      'serviceDate': Timestamp.fromDate(dateOnly),
      'title': _buildServiceTitle(dateOnly),
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  Future<String> ensureActiveService() async {
    final statusDoc = await _statusRef.get();
    if (statusDoc.exists) {
      final data = statusDoc.data();
      final activeServiceId = (data?['activeServiceId'] ?? '') as String;
      if (activeServiceId.isNotEmpty) {
        return activeServiceId;
      }
    }

    final nextSabbath = _nextSabbathDate();
    final serviceId = await createServiceForDate(nextSabbath);
    await setActiveServiceId(serviceId);
    return serviceId;
  }

  Future<void> setActiveServiceId(String serviceId) async {
    await _statusRef.set({
      'activeServiceId': serviceId,
    }, SetOptions(merge: true));
  }

  Stream<String> watchActiveServiceId() {
    return _statusRef.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) {
        return ensureActiveService();
      }

      final activeServiceId =
          (snapshot.data()!['activeServiceId'] ?? '') as String;
      if (activeServiceId.isEmpty) {
        return ensureActiveService();
      }
      return activeServiceId;
    });
  }

  Stream<List<SabbathService>> getServices() {
    return _servicesRef
        .orderBy('serviceDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SabbathService.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<String> createNextSabbathAndActivate() async {
    final serviceId = await createServiceForDate(_nextSabbathDate());
    await setActiveServiceId(serviceId);
    return serviceId;
  }
}
