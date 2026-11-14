import 'dart:async';
import 'dart:io';

import 'package:campus_incident_app/data/models/app_user.dart';
import 'package:campus_incident_app/data/models/incident.dart';
import 'package:campus_incident_app/data/services/incident_service.dart';
import 'package:campus_incident_app/data/services/photo_service.dart';
import 'package:campus_incident_app/providers/incident_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// In memory stand in for IncidentService so the provider can be tested
/// without Firebase.
class FakeIncidentService implements IncidentService {
  final controller = StreamController<List<Incident>>.broadcast();
  final created = <Incident>[];
  final statusCalls = <Map<String, Object?>>[];
  bool failWrites = false;

  @override
  Stream<List<Incident>> watchAll() => controller.stream;

  @override
  Future<String> create(Incident incident) async {
    if (failWrites) throw Exception('write failed');
    created.add(incident);
    return 'new-id';
  }

  @override
  Future<void> updateDetails(
    String id, {
    required String title,
    required String description,
  }) async {
    if (failWrites) throw Exception('write failed');
  }

  @override
  Future<void> updateStatus(
    String id, {
    required IncidentStatus status,
    required String staffName,
    String? note,
  }) async {
    if (failWrites) throw Exception('permission denied');
    statusCalls.add({
      'id': id,
      'status': status,
      'staffName': staffName,
      'note': note,
    });
  }

  @override
  Future<void> delete(String id) async {
    if (failWrites) throw Exception('write failed');
  }

  @override
  Future<List<Incident>> findOpenDuplicates(
    IncidentCategory category,
    String location,
  ) async =>
      const [];
}

class FakePhotoService implements PhotoService {
  bool fail = false;

  @override
  bool get isConfigured => true;

  @override
  Future<String> uploadIncidentPhoto(File file) async {
    if (fail) throw const PhotoUploadException('Upload failed in test');
    return 'https://example.com/photo.jpg';
  }
}

Incident _incident(String id, String reporterId) {
  final now = DateTime(2026, 11, 1, 9);
  return Incident(
    id: id,
    title: 'Broken light $id',
    description: 'The light in the corridor is broken.',
    category: IncidentCategory.electricity,
    location: 'Block A',
    status: IncidentStatus.submitted,
    reporterId: reporterId,
    reporterName: 'Student',
    isAnonymous: false,
    createdAt: now,
    updatedAt: now,
    history: const [],
  );
}

final _student = AppUser(
  uid: 'u1',
  name: 'Amina',
  email: 'amina@alustudent.com',
  role: UserRole.student,
  createdAt: DateTime(2026, 10, 1),
);

void main() {
  late FakeIncidentService service;
  late FakePhotoService photos;
  late IncidentProvider provider;

  setUp(() {
    service = FakeIncidentService();
    photos = FakePhotoService();
    provider = IncidentProvider(service, photos);
  });

  tearDown(() {
    provider.dispose();
    service.controller.close();
  });

  test('listen publishes stream updates and clears loading', () async {
    provider.listen();
    expect(provider.loading, isTrue);

    service.controller.add([_incident('a', 'u1'), _incident('b', 'u2')]);
    await pumpEventQueue();

    expect(provider.loading, isFalse);
    expect(provider.all.length, 2);
    expect(provider.byId('b')?.reporterId, 'u2');
    expect(provider.byId('missing'), isNull);
  });

  test('mine returns only the reports of one user', () async {
    provider.listen();
    service.controller.add([_incident('a', 'u1'), _incident('b', 'u2')]);
    await pumpEventQueue();

    expect(provider.mine('u1').single.id, 'a');
  });

  test('a stream error sets a friendly message', () async {
    provider.listen();
    service.controller.addError(Exception('offline'));
    await pumpEventQueue();

    expect(provider.error, isNotNull);
    expect(provider.loading, isFalse);
  });

  test('stop clears the list', () async {
    provider.listen();
    service.controller.add([_incident('a', 'u1')]);
    await pumpEventQueue();

    provider.stop();
    expect(provider.all, isEmpty);
  });

  group('submit', () {
    test('creates a submitted report with the first history entry', () async {
      final ok = await provider.submit(
        user: _student,
        title: '  Water leak  ',
        description: 'Water is leaking from the ceiling.',
        category: IncidentCategory.water,
        location: 'Library',
      );

      expect(ok, isTrue);
      final created = service.created.single;
      expect(created.title, 'Water leak');
      expect(created.status, IncidentStatus.submitted);
      expect(created.reporterName, 'Amina');
      expect(created.history.single.status, IncidentStatus.submitted);
      expect(provider.busy, isFalse);
    });

    test('anonymous reports hide the reporter name', () async {
      await provider.submit(
        user: _student,
        title: 'Unsafe stairs',
        description: 'The handrail on the stairs is loose.',
        category: IncidentCategory.safety,
        location: 'Block B',
        anonymous: true,
      );

      final created = service.created.single;
      expect(created.isAnonymous, isTrue);
      expect(created.reporterName, 'Anonymous');
    });

    test('a failed photo upload stops the submission', () async {
      photos.fail = true;
      final ok = await provider.submit(
        user: _student,
        title: 'Broken chair',
        description: 'The chair in room 204 has a broken leg.',
        category: IncidentCategory.facilities,
        location: 'Block A',
        photo: File('photo.jpg'),
      );

      expect(ok, isFalse);
      expect(provider.error, 'Upload failed in test');
      expect(service.created, isEmpty);
    });

    test('a failed write reports an error', () async {
      service.failWrites = true;
      final ok = await provider.submit(
        user: _student,
        title: 'Blocked drain',
        description: 'The drain behind the cafeteria is blocked.',
        category: IncidentCategory.sanitation,
        location: 'Cafeteria',
      );

      expect(ok, isFalse);
      expect(provider.error, isNotNull);
      expect(provider.busy, isFalse);
    });
  });

  group('updateStatus', () {
    test('passes the status, staff name and note to the service', () async {
      final ok = await provider.updateStatus(
        'a',
        IncidentStatus.inProgress,
        'Staff Member',
        'Technician assigned',
      );

      expect(ok, isTrue);
      final call = service.statusCalls.single;
      expect(call['id'], 'a');
      expect(call['status'], IncidentStatus.inProgress);
      expect(call['staffName'], 'Staff Member');
      expect(call['note'], 'Technician assigned');
    });

    test('a rejected update returns false and sets an error', () async {
      service.failWrites = true;
      final ok = await provider.updateStatus(
        'a',
        IncidentStatus.resolved,
        'Someone',
        null,
      );

      expect(ok, isFalse);
      expect(provider.error, contains('Only staff'));
    });
  });
}
