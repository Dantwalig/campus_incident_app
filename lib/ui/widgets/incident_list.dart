import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../data/models/incident.dart';
import 'incident_card.dart';

/// Non scrolling column of cards, meant to sit inside a screen's ListView.
class IncidentList extends StatelessWidget {
  const IncidentList({
    super.key,
    required this.incidents,
    this.emptyMessage = 'No reports found',
    this.showReporter = false,
  });

  final List<Incident> incidents;
  final String emptyMessage;
  final bool showReporter;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(emptyMessage, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final incident in incidents)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IncidentCard(incident: incident, showReporter: showReporter),
          ),
      ],
    );
  }
}
