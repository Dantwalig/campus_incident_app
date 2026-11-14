import 'package:campus_incident_app/data/models/incident.dart';
import 'package:campus_incident_app/data/models/incident_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Incident _sample({
  String title = 'Water shortage',
  IncidentCategory category = IncidentCategory.water,
  IncidentStatus status = IncidentStatus.submitted,
}) {
  final now = DateTime(2026, 10, 15, 10, 24);
  return Incident(
    id: 'abc',
    title: title,
    description: 'No water in the student residence since morning.',
    category: category,
    location: 'Student Residence',
    status: status,
    reporterId: 'u1',
    reporterName: 'Amina',
    isAnonymous: false,
    createdAt: now,
    updatedAt: now,
    history: [
      StatusChange(status: IncidentStatus.submitted, changedBy: 'Amina', timestamp: now),
    ],
  );
}

void main() {
  test('Incident survives a toMap and fromMap round trip', () {
    final original = _sample();
    final copy = Incident.fromMap('abc', original.toMap());
    expect(copy.title, original.title);
    expect(copy.category, IncidentCategory.water);
    expect(copy.status, IncidentStatus.submitted);
    expect(copy.history.length, 1);
    expect(copy.createdAt, original.createdAt);
  });

  test('IncidentStatus maps stored values', () {
    expect(IncidentStatus.fromValue('in_progress'), IncidentStatus.inProgress);
    expect(IncidentStatus.fromValue('unknown'), IncidentStatus.submitted);
  });

  group('IncidentFilter', () {
    final items = [
      _sample(),
      _sample(
        title: 'Broken projector',
        category: IncidentCategory.facilities,
        status: IncidentStatus.resolved,
      ),
    ];

    test('filters by search text', () {
      const filter = IncidentFilter(query: 'projector');
      expect(filter.apply(items).length, 1);
    });

    test('filters by status and category', () {
      const byStatus = IncidentFilter(status: IncidentStatus.resolved);
      expect(byStatus.apply(items).single.title, 'Broken projector');
      const byCategory = IncidentFilter(category: IncidentCategory.water);
      expect(byCategory.apply(items).single.title, 'Water shortage');
    });

    test('empty filter returns everything', () {
      expect(const IncidentFilter().apply(items).length, 2);
    });
  });

  test('countByStatus counts correctly', () {
    final items = [
      _sample(),
      _sample(status: IncidentStatus.resolved),
      _sample(status: IncidentStatus.resolved),
    ];
    expect(items.countByStatus(IncidentStatus.resolved), 2);
  });
}
