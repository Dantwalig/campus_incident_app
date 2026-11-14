import 'package:flutter/material.dart';

import '../../core/ui_extensions.dart';
import '../../data/models/incident.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
