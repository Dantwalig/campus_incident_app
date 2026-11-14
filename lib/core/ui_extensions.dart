import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import 'theme.dart';

extension IncidentCategoryUi on IncidentCategory {
  IconData get icon {
    switch (this) {
      case IncidentCategory.facilities:
        return Icons.apartment_rounded;
      case IncidentCategory.water:
        return Icons.water_drop_outlined;
      case IncidentCategory.electricity:
        return Icons.bolt_rounded;
      case IncidentCategory.safety:
        return Icons.shield_outlined;
      case IncidentCategory.sanitation:
        return Icons.delete_outline_rounded;
    }
  }
}

extension IncidentStatusUi on IncidentStatus {
  Color get color {
    switch (this) {
      case IncidentStatus.submitted:
        return AppColors.warning;
      case IncidentStatus.inProgress:
        return AppColors.primary;
      case IncidentStatus.resolved:
        return AppColors.success;
    }
  }

  Color get background {
    switch (this) {
      case IncidentStatus.submitted:
        return AppColors.warningSoft;
      case IncidentStatus.inProgress:
        return AppColors.primarySoft;
      case IncidentStatus.resolved:
        return AppColors.successSoft;
    }
  }
}
