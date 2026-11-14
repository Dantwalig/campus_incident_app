import 'package:flutter/material.dart';

import '../../core/cloudinary_url.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../core/ui_extensions.dart';
import '../../data/models/incident.dart';
import '../screens/incident_details_screen.dart';
import 'app_card.dart';
import 'status_badge.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, this.showReporter = false});

  final Incident incident;
  final bool showReporter;

  @override
  Widget build(BuildContext context) {
    final meta = showReporter
        ? '${timeAgo(incident.createdAt)} by ${incident.reporterName}'
        : timeAgo(incident.createdAt);

    return AppCard(
      onTap: () => IncidentDetailsScreen.open(context, incident.id),
      child: Row(
        children: [
          _Thumb(incident: incident),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  incident.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(incident.status),
              const SizedBox(height: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: 56,
      width: 56,
      color: AppColors.primarySoft,
      child: Icon(incident.category.icon, color: AppColors.primary),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: incident.photoUrl == null
          ? fallback
          : Image.network(
              cloudinaryTransform(incident.photoUrl!, CloudinaryTransforms.thumbnail),
              height: 56,
              width: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => fallback,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : fallback,
            ),
    );
  }
}
