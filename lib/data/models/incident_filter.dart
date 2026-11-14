import 'incident.dart';

/// Immutable description of the search and filter options on a report list.
class IncidentFilter {
  const IncidentFilter({this.query = '', this.status, this.category});

  final String query;
  final IncidentStatus? status;
  final IncidentCategory? category;

  IncidentFilter copyWith({
    String? query,
    IncidentStatus? status,
    IncidentCategory? category,
    bool clearStatus = false,
    bool clearCategory = false,
  }) {
    return IncidentFilter(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  bool matches(Incident incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return incident.title.toLowerCase().contains(q) ||
        incident.description.toLowerCase().contains(q) ||
        incident.location.toLowerCase().contains(q);
  }

  List<Incident> apply(List<Incident> items) =>
      items.where(matches).toList();
}
