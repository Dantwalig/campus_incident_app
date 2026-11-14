import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';

/// All Firestore access for the `incidents` collection (CRUD).
class IncidentService {
  IncidentService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('incidents');

  // READ: live stream, newest first.
  Stream<List<Incident>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Incident.fromDoc).toList());
  }

  Future<String> create(Incident incident) async {
    final ref = _col.doc();
    await ref.set(incident.toMap());
    return ref.id;
  }

  // UPDATE: reporter edits text while the report is still "submitted".
  Future<void> updateDetails(
    String id, {
    required String title,
    required String description,
  }) {
    return _col.doc(id).update({
      'title': title.trim(),
      'description': description.trim(),
      'updatedAt': Timestamp.now(),
    });
  }

  // UPDATE: staff changes status, appends to the history for the timeline.
  Future<void> updateStatus(
    String id, {
    required IncidentStatus status,
    required String staffName,
    String? note,
  }) {
    final trimmed = note?.trim() ?? '';
    final change = StatusChange(
      status: status,
      changedBy: staffName,
      timestamp: DateTime.now(),
      note: trimmed,
    );
    return _col.doc(id).update({
      'status': status.value,
      'updatedAt': Timestamp.now(),
      if (trimmed.isNotEmpty) 'staffNote': trimmed,
      'statusHistory': FieldValue.arrayUnion([change.toMap()]),
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  /// Open reports in the same category and location, used for the
  /// duplicate warning before submitting.
  Future<List<Incident>> findOpenDuplicates(
    IncidentCategory category,
    String location,
  ) async {
    final snap = await _col
        .where('category', isEqualTo: category.name)
        .where('location', isEqualTo: location)
        .get();
    return snap.docs
        .map(Incident.fromDoc)
        .where((i) => i.status != IncidentStatus.resolved)
        .toList();
  }
}
