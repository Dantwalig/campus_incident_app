import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../data/models/incident.dart';
import '../../data/models/incident_filter.dart';
import '../../providers/incident_provider.dart';
import '../widgets/error_banner.dart';
import '../widgets/incident_filter_bar.dart';
import '../widgets/incident_list.dart';
import '../widgets/summary_tile.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  IncidentFilter _filter = const IncidentFilter();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final all = provider.all;
    final results = _filter.apply(all);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text('Staff Dashboard',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const Text('Review reports and update their status.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryTile(
                  icon: Icons.description_outlined,
                  count: all.length,
                  label: 'Total',
                  color: AppColors.primary,
                  background: AppColors.primarySoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  icon: Icons.error_outline,
                  count: all.countByStatus(IncidentStatus.submitted),
                  label: 'New',
                  color: AppColors.warning,
                  background: AppColors.warningSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  icon: Icons.schedule,
                  count: all.countByStatus(IncidentStatus.inProgress),
                  label: 'In Progress',
                  color: AppColors.info,
                  background: AppColors.infoSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  icon: Icons.check_circle_outline,
                  count: all.countByStatus(IncidentStatus.resolved),
                  label: 'Resolved',
                  color: AppColors.success,
                  background: AppColors.successSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IncidentFilterBar(
            filter: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 12),
          if (provider.error != null) ErrorBanner(provider.error!),
          if (provider.loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            IncidentList(
              incidents: results,
              showReporter: true,
              emptyMessage: 'No reports match your filters',
            ),
        ],
      ),
    );
  }
}
