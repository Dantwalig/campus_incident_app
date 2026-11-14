import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/models/incident.dart';
import '../data/services/incident_service.dart';
import '../data/services/photo_service.dart';

/// Holds the live list of incidents and every action that changes them.
/// Screens never talk to Firebase directly, they only call this provider.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._service, this._photos);

  final IncidentService _service;
  final PhotoService _photos;

  StreamSubscription<List<Incident>>? _sub;
  List<Incident> _all = const [];
  bool _loading = false;
  bool _busy = false;
  String? _error;

  List<Incident> get all => _all;
  bool get loading => _loading;
  bool get busy => _busy;
  String? get error => _error;

  List<Incident> mine(String uid) =>
      _all.where((i) => i.reporterId == uid).toList();

  Incident? byId(String id) {
    for (final incident in _all) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  /// Starts the realtime Firestore listener. Does not notify synchronously
  /// so it is safe to call from initState.
  void listen() {
    _sub?.cancel();
    _loading = true;
    _error = null;
    _sub = _service.watchAll().listen(
      (items) {
        _all = items;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object _) {
        _loading = false;
        _error = 'Could not load reports. Check your connection.';
        notifyListeners();
      },
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _all = const [];
  }

  Future<List<Incident>> findDuplicates(
    IncidentCategory category,
    String location,
  ) async {
    try {
      return await _service.findOpenDuplicates(category, location);
    } catch (_) {
      return const [];
    }
  }

  Future<bool> submit({
    required AppUser user,
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    File? photo,
    bool anonymous = false,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();
    String? photoUrl;
    try {
      if (photo != null) {
        photoUrl = await _photos.uploadIncidentPhoto(photo);
      }
      final now = DateTime.now();
      final displayName = anonymous ? 'Anonymous' : user.name;
      await _service.create(
        Incident(
          id: '',
          title: title.trim(),
          description: description.trim(),
          category: category,
          location: location,
          status: IncidentStatus.submitted,
          reporterId: user.uid,
          reporterName: displayName,
          isAnonymous: anonymous,
          createdAt: now,
          updatedAt: now,
          photoUrl: photoUrl,
          history: [
            StatusChange(
              status: IncidentStatus.submitted,
              changedBy: displayName,
              timestamp: now,
            ),
          ],
        ),
      );
      return true;
    } on PhotoUploadException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Could not submit the report. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> editIncident(String id, String title, String description) async {
    return _run(
      () => _service.updateDetails(id, title: title, description: description),
      'Could not save your changes.',
    );
  }

  Future<bool> updateStatus(
    String id,
    IncidentStatus status,
    String staffName,
    String? note,
  ) {
    return _run(
      () => _service.updateStatus(
        id,
        status: status,
        staffName: staffName,
        note: note,
      ),
      'Could not update the status. Only staff can do this.',
    );
  }

  Future<bool> deleteIncident(Incident incident) async {
    return _run(
      () => _service.delete(incident.id),
      'Could not delete this report.',
    );
  }

  Future<bool> _run(Future<void> Function() action, String failure) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      _error = failure;
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
