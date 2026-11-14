import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentCategory {
  facilities('Facilities'),
  water('Water'),
  electricity('Electricity'),
  safety('Safety'),
  sanitation('Sanitation');

  const IncidentCategory(this.label);
  final String label;

  static IncidentCategory fromName(String? name) => IncidentCategory.values
      .firstWhere((c) => c.name == name, orElse: () => IncidentCategory.facilities);
}

enum IncidentStatus {
  submitted('submitted', 'Submitted'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved');

  const IncidentStatus(this.value, this.label);
  final String value;
  final String label;

  static IncidentStatus fromValue(String? value) => IncidentStatus.values
      .firstWhere((s) => s.value == value, orElse: () => IncidentStatus.submitted);
}

class StatusChange {
  const StatusChange({
    required this.status,
    required this.changedBy,
    required this.timestamp,
    this.note,
  });

  final IncidentStatus status;
  final String changedBy;
  final DateTime timestamp;
  final String? note;

  factory StatusChange.fromMap(Map<String, dynamic> map) => StatusChange(
        status: IncidentStatus.fromValue(map['status'] as String?),
        changedBy: (map['changedBy'] as String?) ?? 'Unknown',
        timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        note: map['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'status': status.value,
        'changedBy': changedBy,
        'timestamp': Timestamp.fromDate(timestamp),
        if (note != null && note!.isNotEmpty) 'note': note,
      };
}

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
    this.photoUrl,
    this.staffNote,
  });

  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final String location;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusChange> history;
  final String? photoUrl;
  final String? staffNote;

  factory Incident.fromMap(String id, Map<String, dynamic> map) {
    final rawHistory = (map['statusHistory'] as List?) ?? const [];
    return Incident(
      id: id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: IncidentCategory.fromName(map['category'] as String?),
      location: (map['location'] as String?) ?? '',
      status: IncidentStatus.fromValue(map['status'] as String?),
      reporterId: (map['reporterId'] as String?) ?? '',
      reporterName: (map['reporterName'] as String?) ?? 'Unknown',
      isAnonymous: (map['isAnonymous'] as bool?) ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      history: rawHistory
          .map((e) => StatusChange.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      photoUrl: map['photoUrl'] as String?,
      staffNote: map['staffNote'] as String?,
    );
  }

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Incident.fromMap(doc.id, doc.data() ?? {});

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category.name,
        'location': location,
        'status': status.value,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'isAnonymous': isAnonymous,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'statusHistory': history.map((h) => h.toMap()).toList(),
        'photoUrl': photoUrl,
        'staffNote': staffNote,
      };
}

extension IncidentListX on List<Incident> {
  int countByStatus(IncidentStatus status) =>
      where((i) => i.status == status).length;
}
