import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../data/models/incident.dart';

/// Three step tracker: Submitted, In Progress, Resolved.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  DateTime? _reachedAt(IncidentStatus status) {
    DateTime? latest;
    for (final change in incident.history) {
      if (change.status == status) latest = change.timestamp;
    }
    return latest;
  }

  @override
  Widget build(BuildContext context) {
    const steps = IncidentStatus.values;
    final currentIndex = steps.indexOf(incident.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _Step(
            label: steps[i].label,
            reached: i <= currentIndex,
            date: _reachedAt(steps[i]),
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 11),
                child: Container(
                  height: 2,
                  color: i < currentIndex ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.reached, this.date});

  final String label;
  final bool reached;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached ? AppColors.primary : AppColors.border,
            ),
            child: Icon(
              reached ? Icons.check : Icons.circle,
              size: reached ? 15 : 6,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: reached ? AppColors.text : AppColors.textMuted,
            ),
          ),
          if (date != null)
            Text(
              shortDate(date!),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
